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

pull_args=()
common_args=()

if [[ "$INPUT_PARALLEL" = true ]] ; then
    common_args+=( "--parallel" )
fi

if [[ $INPUT_MINIMUM_PERC -ne 0 ]] ; then
    pull_args+=( "--minimum-perc=$INPUT_MINIMUM_PERC" )
fi

if [[ "$INPUT_DISABLE_OVERRIDE" = true ]] ; then
    pull_args+=( "--disable-overwrite" )
fi

if [[ "$INPUT_PULL_SOURCES" = true ]] ; then
    pull_args+=( "-s" )
fi

if [[ "$INPUT_PULL_TRANSLATIONS" = true ]] ; then
    pull_args+=( "-a" )
fi

if [[ "$INPUT_USE_GIT_TIMESTAMPS" = true ]] ; then
    pull_args+=( "--use-git-timestamps" )
else
    pull_args+=( "--force" )
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


    if [[ "$INPUT_GIT_UNSHALLOW" != false ]] ; then
        # Git checkout action does a shallow clone. That prevents us to
        # access common history of branches.
        git fetch --unshallow
    fi

    git checkout origin/${MASTER_BRANCH}
    TRANSLATIONS_MERGE_BRANCH="${MASTER_BRANCH}-translations-$(date +%s)"
    git checkout -b ${TRANSLATIONS_MERGE_BRANCH}

    if [[ "$INPUT_PULL_SOURCES" = true ]] || [[ "$INPUT_PULL_TRANSLATIONS" = true ]] ; then
        echo "Pulling most up to date sources and translations"
        tx pull --no-interactive "${common_args[@]}" "${pull_args[@]}"
    else
        echo "WARNING - NOT PULLING ANY STRINGS FROM TRANSIFEX - PUSHING WILL RESULT IN OVERRIDING THE STRINGS IN TRANSIFEX"
    fi

    # Commits latest transifex tranlsations to our local branch
    git add $(echo ${TRANSLATIONS_FOLDER})

    git diff --staged

    # Stashes all of the non needed changes (eg. sometines .tx/config is changed)
    echo "MERGING TRANSIFEX STATE WITH CURRENT COPY!"
    git diff --staged --quiet || git commit -m "Update translations" && git stash && git merge --no-edit origin/$CURRENT_BRANCH

    # and let's push the merged version upstream

    if [[ "$INPUT_PUSH_SOURCES" = true ]] ; then
        tx push -s --no-interactive "${common_args[@]}"
    fi

    if [[ "$INPUT_PUSH_TRANSLATIONS" = true ]] ; then
        tx push -t --no-interactive "${common_args[@]}"
    fi

    if [[ "$INPUT_COMMIT_TO_PR" = true ]] ; then
        echo "COMMITTING TO PR"
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

    if [[ "$INPUT_PULL_SOURCES" = true ]] || [[ "$INPUT_PULL_TRANSLATIONS" = true ]] ; then
        echo "PULLING TRANSLATIONS (with pull_args: $pull_args)"
        tx pull -a --no-interactive "${pull_args[@]}" "${common_args[@]}"
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
