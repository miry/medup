# Releasing

## Before You Begin

Ensure your local workstation is configured to be able to
[Sign commits](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits).

## Local Release Preparation

### Checkout latest code

Make sure local and remote state are sync:

```shell
$ git checkout master
$ git pull origin master
$ git push origin master
```

### Test

Make sure all test pass and docs are updated

```shell
$ rake fmt test build test:e2e
```

There are some extra steps to check that everything else is working as expected

* Container
  ```shell
  $ rake container:build
  ```
* Demo
  ```shell
  $ rm -fr demo
  $ rake demo:serve
  $ open localhost:4000
  ```

### Bump release

* Update [CHANGELOG.md](CHANGELOG.md):
  - Add a new version header at the top of the document,
    just after `# [Unreleased]`
  - Update links at bottom of changelog
* Bump version in [shard.yml](shard.yml).
* Bump version in [src/medup/version.cr](src/medup/version.cr).

### Commit and tag

Create a release commit and tag

```shell
$ export RELEASE_VERSION=x.y.z
$ git commit -a -S -m "Release v${RELEASE_VERSION}"
$ git tag -s "v${RELEASE_VERSION}"
```

### Push

```shell
$ git push origin master
$ git push origin master --tags
```

## Github Release

Create a new release in Github:
- Title should equal to tag name. Example: `v0.1.3`
- Description should have a text from Changelog

## Update Homebrew versions

- Update [homebrew-medup](https://github.com/miry/homebrew-medup/blob/master/Formula/medup.rb)
manifest
  1. Update `version` string to your released version;
  1. Update `url` with new release tag;
  1. Update `sha256` from release archive file;

- Do a manual check of installing command line via brew
  1. While in the homebrew-medup directory...
     ```shell
     $ brew install ./medup.rb --debug
     ```
     Note: it's normal to get some errors when homebrew attempts to load the file
     as a Cask instead of a formula, just make sure that it still gets installed.
  1. Check installed version
     ```shell
     $ medup --version
     ```
- Commit and push changes to master branch
