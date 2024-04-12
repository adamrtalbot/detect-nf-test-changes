# detect-nf-test-changes

Detect changes in a Nextflow repo and so you can fire off the appropriate nf-tests.

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

A list of changed directories or files and their immediate dependencies,

```text
'["subworkflows/a/tests/main.nf.test", "modules/b/tests/main.nf.test", "modules/a/tests/main.nf.test"]'
```
