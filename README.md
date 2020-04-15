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

### Simple workflow ( ⚠️ replaces whatever is in Tx / locally with whatever is being pushed / pulled)
**The default action is push sources**. But you can set different actions through env variables.
For example, just define these variables in ENV. If you don't want to push sources, you need to set the
variable to false, because it is defined in the defaults
```
      - name: "Run action"
        with: # Or as an environment variable
            tx_token: ${{ secrets.TX_TOKEN }}
            push_sources: true
            push_translations: true
            pull_sources: false
            pull_translations: true
            minimum_perc: 0
            disable_override: false
```

### Git workflow
Because you might have multiple branches ongoing, and you might not want to override what the other branch has
pushed to transifex, Git workflow offers a solution for handling the diff of transifex remote and the current branch with git.

It will take whatever is in transifex remote into a separate branch, merge your current branch into that
branch (and resolving the diff), and then pushing things back to transifex. That way you have what's in transifex +
all the changes you've made in the current branch. Of course if there are merge conflicts you will need to take manual action.
```
      - name: "Run action"
        with: # Or as an environment variable
            tx_token: ${{ secrets.TX_TOKEN }}
            git_flow: true
            github_token: ${{ secrets.GITHUB_TOKEN }}
            translations_folder: config/locale
            push_translations: true
            push_sources: true
            ...
            minimum_perc: 0
            disable_override: false
```
NOTE: `github_token` and `translations_folder` are required if you use `git_flow`

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
