#!/bin/bash

# exit when any command fails
set -e
if [[ $INPUT_DEBUG ]] ; then
    set -x
fi
echo "STARTING TRANSIFEX ACTION..."

CURRENT_BRANCH=${INPUT_CURRENT_BRANCH:-$GITHUB_HEAD_REF}
MASTER_BRANCH=${INPUT_MASTER_BRANCH:-master}
REMOTE=${INPUT_REMOTE:-origin}
TRANSLATIONS_FOLDER=${INPUT_TRANSLATIONS_FOLDER}
SKIP_PUSH_COMMIT=${INPUT_SKIP_PUSH_COMMIT}

COMMITER_EMAIL=${INPUT_COMMITER_EMAIL:-'git-action@transifex.com'}
COMMITTER_NAME=${INPUT_COMMITTER_NAME:-'Transifex Github action'}

export TX_TOKEN=${INPUT_TX_TOKEN:-$TX_TOKEN}

# Because transifex overrides whatever is in remote with what's currently in
# our branch, we will do the following:
# 1 - Checkout master (or whatever base branch)
# 2 - Get what's in transifex
# 3 - Use commit to the staging area
# 4 - Use git merge with fast-forward only so we merge the differences
# 5 - Push the merge result to transifex

args=()
common_args=()

if [[ "$INPUT_PARALLEL" = true ]] ; then
    common_args+=( "--parallel" )
fi

if [[ $INPUT_MINIMUM_PERC -ne 0 ]] ; then
    args+=( "--minimum-perc=$INPUT_MINIMUM_PERC" )
fi

if [[ "$INPUT_DISABLE_OVERRIDE" = true ]] ; then
    args+=( "--disable-overwrite" )
fi


if [[ "$INPUT_GIT_FLOW" = true ]] ; then
    echo "USING GIT MERGE FLOW"

    [[ -z "${INPUT_GITHUB_TOKEN}" ]] && {
        echo 'Missing input "github_token: ${{ secrets.GITHUB_TOKEN }}".';
        exit 1;
    };

    echo "Setting up git repo"
    git config --global user.email "${COMMITTER_EMAIL}"
    git config --global user.name "${COMMITTER_NAME}"
    remote_repo="https://${GITHUB_ACTOR}:${INPUT_GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

    # Git checkout action does a shallow clone. That prevents us to
    # access common history of branches.
    git fetch --unshallow

    git checkout ${MASTER_BRANCH}
    TRANSLATIONS_MERGE_BRANCH="${MASTER_BRANCH}-translations-$(date +%s)"
    git checkout -b ${TRANSLATIONS_MERGE_BRANCH}

    echo "Pulling most up to date sources and translations"
    # Unfortunately we need to use force because transifex thinks the checked out
    # files are newer than in Transifex, so they get ignored. See issue:
    # https://github.com/transifex/transifex-client/issues/22
    tx pull -a -s --no-interactive --force "${common_args[@]}" "${args[@]}"

    # Commits latest transifex tranlsations to our local branch
    git add $(echo ${TRANSLATIONS_FOLDER})

    git diff --staged

    # Stashes all of the non needed changes (eg. sometines .tx/config is changed)
    git diff --staged --quiet || git commit -m "Update translations" && git stash && git merge --no-edit $CURRENT_BRANCH

    # and let's push the merged version upstream
    if [[ "$INPUT_PUSH_SOURCES" = true ]] && [[ "$INPUT_PUSH_TRANSLATIONS" = true ]] ; then
        tx push -s -t --no-interactive "${common_args[@]}"
    else
        if [[ "$INPUT_PUSH_SOURCES" = true ]] ; then
            tx push -s --no-interactive "${common_args[@]}"
        fi

        if [[ "$INPUT_PUSH_TRANSLATIONS" = true ]] ; then
            tx push -t --no-interactive "${common_args[@]}"
        fi
    fi

    if [[ "$INPUT_PULL_SOURCES" = true ]] || [[ "$INPUT_PULL_TRANSLATIONS" = true ]] ; then
        # Stashes all of the non needed changes (eg. sometines .tx/config is changed)
        git stash
        git checkout $CURRENT_BRANCH
        git checkout ${TRANSLATIONS_MERGE_BRANCH} -- $TRANSLATIONS_FOLDER
        git add $(echo ${TRANSLATIONS_FOLDER})
        git diff --staged --quiet || git commit -m "Update translations from Transifex"

        if [[ "$SKIP_PUSH_COMMIT" = true ]] ; then
            echo "SKIPPING PUSH!"
        else
            git push "${remote_repo}" HEAD:${CURRENT_BRANCH}
        fi
    fi
else
    echo "USING OVERRIDE FLOW"
    if [[ "$INPUT_PULL_SOURCES" = true ]] ; then
        echo "PULLING SOURCES"
        tx pull -s --force --no-interactive "${common_args[@]}"
    fi

    if [[ "$INPUT_PULL_TRANSLATIONS" = true ]] ; then
        echo "PULLING TRANSLATIONS (with args: $args)"
        tx pull -a --force --no-interactive "${args[@]}" "${common_args[@]}"
    fi

    if [[ "$INPUT_PUSH_SOURCES" = true ]] ; then
        echo "PUSHING SOURCES"
        tx push -s --no-interactive "${common_args[@]}"
    fi

    if [[ "$INPUT_PUSH_TRANSLATIONS" = true ]] ; then
        echo "PUSHING TRANSLATIONS"
        tx push -t --no-interactive "${common_args[@]}"
    fi
fi
