# detect-nf-test-changes

Detect changes in a Nextflow repo and so you can fire off the appropriate nf-tests.

> [!WARNING] 
> This actions is under extremely rapid development. We'll do a release when it's reached some sort of stability. YOU HAVE BEEN WARNED.

## Overview

This action scans a Nextflow repository for changes between two branches and identifies any available tests that cover those changes. Furthermore, it will find anything that depdends on the changes and identify those files as well.

## Example

### Minimal example

This is a typical use case for a pull request which will compare the target and base branch and return a list of files

```yaml
steps:
- uses: actions/checkout@v4
- uses: adamrtalbot/detect-nf-test
  with:
    head: ${{ github.sha }}
    base: ${{ github.base_ref }}
```

### Ignoring paths

You may want to ignore paths such as docs, strings etc. To do this, specify a list of strings separated by spaces. This supports globbing so use `*` to match multiple.

Note: specifying a filename (e.g. `main.nf`) will match all instances of `main.nf`, regardless of directory. If you wish to match a path in the root of the directory use a relative path (`./main.nf`).

```yaml
steps:
- uses: actions/checkout@v4
- uses: adamrtalbot/detect-nf-test
  with:
    head: ${{ github.sha }}
    base: ${{ github.base_ref }}
    ignored: ".git/* .gitpod.yml .prettierignore .prettierrc.yml *.md *.png modules.json pyproject.toml tower.yml"
```

### Returning different test components

You may wish to only test a process, function, workflow or pipeline. You can do this by specifying which you would like in `types`.

```yaml
steps:
- uses: actions/checkout@v4
- uses: adamrtalbot/detect-nf-test
  with:
    head: ${{ github.sha }}
    base: ${{ github.base_ref }}
    types: 'workflow pipeline'
```

### Returning the directory

You may wish to return the parent directory instead of the exact test file. You can do this by specifying the number of parent directories you wish to return. E.g., use 0 (default) to return the nf-test file. Use 1 to return the parent directory, use 2 to return the parent of that directory (and so on).

```yaml
steps:
- uses: actions/checkout@v4
- uses: adamrtalbot/detect-nf-test
  with:
    head: ${{ github.sha }}
    base: ${{ github.base_ref }}
    n_parents: '2'
```

### Include additional rules

You may want to include an additional rule to match indirect paths. For example, if you modify a Github workflow in `.github/workflows/` you may wish to test all nf-test files. To do this, create an additional 'include' file in yaml format. This should include a set of key-value pairs. If a file specified by a value is matched the key will be returned as an output. For example, the following `include.yaml` will return the tests in the entire repo if `nextflow.config` changes and the tests in the `tests` directory if `main.nf` is modified.

Note: This will still respect the `types` parameter.

```yaml
".":
  - ./nf-test.config
  - ./nextflow.config
tests:
  - ./main.nf
```

```yaml
steps:
- uses: actions/checkout@v4
- uses: adamrtalbot/detect-nf-test
  with:
    head: ${{ github.sha }}
    base: ${{ github.base_ref }}
    include: include.yaml
```

### Directories instead of files

You may require the enclosing directory instead of the files. You can use the input returntype to change this to 'dir'.

```yaml
steps:
- uses: actions/checkout@v4
- uses: adamrtalbot/detect-nf-test
  with:
    head: ${{ github.sha }}
    base: ${{ github.base_ref }}
    returntype: 'dir'
```

## Outputs

A list of changed directories or files and their immediate dependencies is returned under the variable `components`. 

```text
'["subworkflows/a/tests/main.nf.test", "modules/b/tests/main.nf.test", "modules/a/tests/main.nf.test"]'
```

To use within a job, access the variable `steps.<step>.outputs.components`. Note it is a string, but is valid JSON so can be used with the Github expression `fromJson`. See below for an example:

```yaml
jobs:
  nf-test-changes:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Detect changes after module A update
        id: detect_changes
        uses: adamrtalbot/detect-nf-test
        with:
          head: dev
          base: main

      - name: check if valid
        run:
          echo ${{ steps.detect_changes.outputs.components }}
```

To use the output in a subsequent job, you must export it in the job outputs:

```yaml
jobs:
  nf-test-changes:
    runs-on: ubuntu-latest
    outputs:
      # Export changed files as `changes`
      changes: ${{ steps.detect_changes.outputs.components }}
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Detect changes after module A update
        id: detect_changes
        uses: adamrtalbot/detect-nf-test
        with:
          head: dev
          base: main

      - name: check if valid
        run:
          echo ${{ steps.detect_changes.outputs.components }}

  # Use output in subsequent job
  test:
    nf-test:
    runs-on: ubuntu-latest
    name: nf-test
    needs: [nf-test-changes]
    if: ( needs.nf-test-changes.outputs.changes != '[]' )
    strategy:
      matrix:
        path: ["${{ fromJson(needs.nf-test-changes.outputs.changes) }}"]
```

## Authors

The Python script was written by @adamrtalbot and @CarsonJM before being translated into a Github Action by @adamrtalbot. @sateeshperi and @mashehu provided feedback, advice and emotional support.