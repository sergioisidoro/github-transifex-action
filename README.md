# Github Transifex Action 🌎💬⚙️

**⚠️ New versions might have breaking changes.**

Please pin your git action version instead of using `latest`, so that breaking changes do not break your workflow ([see bellow](https://github.com/sergioisidoro/github-transifex-action#docker-image)) You can also use the version `edge` for the current unreleased version (master branch) of this action**

## What does this action do?

- For now it just pushes the source strings to Transifex, as long as you configure the `TX_TOKEN` to the enviroment of the job.

## Usage

Define a workflow in `.github/workflows/transifex.yml` (or add a job if you already have defined workflows).

:bulb: Read more about [Configuring a workflow](https://help.github.com/en/articles/configuring-a-workflow).

```yaml
on:
  pull_request:
    types: [labeled]

name: "Translations Sync"

jobs:
  push-strings-to-transifex:
    if: github.event.label.name == 'Ready for translations'
    name: push-strings-to-transifex

    runs-on: ubuntu-latest

    steps:
      - name: "Checkout"
        uses: actions/checkout@master

      - name: "Run action"
        with:
            TX_TOKEN: ${{ secrets.TX_TOKEN }}
        uses: docker://sergioisidoro/github-transifex-action:latest
```


## What commands are supported?
Because you might have multiple branches ongoing, and you might not want to override what the other branch have
pushed to transifex, this action offers a solution for handling the diff of transifex remote and the current branch with git.

1. It will pull things from transifex remote into a separate branch,
2. merge your current branch into the branch with the transifex content (and resolving the diff)
4. Push things back to transifex
5. Commit the state into your PR

That way you have what's in transifex + all the changes you've made in the current branch.
Of course if there are merge conflicts you will need to take manual action.

## Important note

⚠️ If you have `pull_sources: false` or `pull_translations: false` this action will not pull things from transifex. This means that if you use any of the push commands, that action will override transifex content without using the merging functionality of this action. These inputs have default true to prevent accidental overrides.

## Use cases
Here are the most common use cases for this action

NOTE: `github_token` and `translations_folder` are required if you use `git_flow`
### Push to transifex without messing with strings pushed from other PRs:
```
      - name: "Merge and push to transifex"
        with: # Or as an environment variable
            tx_token: ${{ secrets.TX_TOKEN }}
            git_flow: true
            github_token: ${{ secrets.GITHUB_TOKEN }}
            translations_folder: config/locale
            pull_translations: true
            pull_sources: true
            push_translations: true
            push_sources: true
```
### Pull the entire current state from Transifex and commit to the PR:
```
      - name: "Pull from transifex and commit to the PR"
        with: # Or as an environment variable
            tx_token: ${{ secrets.TX_TOKEN }}
            git_flow: true
            github_token: ${{ secrets.GITHUB_TOKEN }}
            translations_folder: config/locale
            pull_translations: true
            pull_sources: true
            commit_to_pr: true
```
### Reset Transifex with what you currently have in your branch (DANGER)
```
      - name: "Reset Transifex with current state"
        with: # Or as an environment variable
            tx_token: ${{ secrets.TX_TOKEN }}
            git_flow: true
            github_token: ${{ secrets.GITHUB_TOKEN }}
            translations_folder: config/locale
            pull_translations: false
            pull_sources: false
            push_translations: true
            push_sources: true
```

### Simple workflow ( DEPRECATED ! )
DEPRECATED -  This action does not require a git token, or a translation folder input. But it can only push sources and translations without merging the transifex state. It does not support commit to the PR, and push command will override anything in Transifex with the current state of the pull request. 

Support for simple workflow will be removed on the next releases.
```
      - name: "Run action"
        with: # Or as an environment variable
            git_flow: false
            tx_token: ${{ secrets.TX_TOKEN }}
            push_sources: true
            push_translations: true
            disable_override: false
```

### Supported inputs and options.
See [the action input description](https://github.com/sergioisidoro/github-transifex-action/blob/master/action.yml#L17) for a full understanding of what the action supports
### Docker image

As Docker images are automatically built and pushed on a merge to `master` or when a new tag is created in this repository, the recommended way to use this GitHub action is to reference the pre-built Docker image directly, as seen above.

:bulb: The Docker image can also be executed directly by running

```
$ docker run --interactive --rm --tty --workdir=/app --volume ${PWD}:/app sergioisidoro/github-transifex-action:latest
```

For more information, see the [Docker Docs: Docker run reference](https://docs.docker.com/engine/reference/run/).

Instead of using the latest pre-built Docker image, you can also specify a Docker image tag (which corresponds to the tags [released on GitHub](https://github.com/ergebnis/github-action-template/releases)):

```diff
 on:
   pull_request:
   push:
     branches:
       - master
     tags:
       - "**"

 name: "Continuous Integration"

 jobs:
   github-action-template:
     name: github-action-template

     runs-on: ubuntu-latest

     steps:
       - name: "Checkout"
         uses: actions/checkout@master

       - name: "Run action"
-        uses: docker://sergioisidoro/github-transifex-action:latest
+        uses: docker://sergioisidoro/github-transifex-action:1.2.3
```

## Changelog

Please have a look at [`CHANGELOG.md`](CHANGELOG.md).

## Contributing


### TODO:
- Passing the resource as an argument

Please have a look at [`CONTRIBUTING.md`](.github/CONTRIBUTING.md).

## Code of Conduct

Please have a look at [`CODE_OF_CONDUCT.md`](.github/CODE_OF_CONDUCT.md).

## License

This package is licensed using the MIT License.

## Authors and Contributors
- @smaisidoro
- @rGaillard
