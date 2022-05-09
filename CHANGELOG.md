# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Allow to change the download distination for assets with flag `--assets-dir=<DIR>`. (#40, @miry)
- Allow to change the uri path for assets inside document with `--assets-base-path=<BASE_PATH>`.
  It help to access assets in case the global assets path or custom directory. (#40, @miry)

## [0.4.1] - 2022-05-02
### Changed
- Update article' url tag to get value from response, instead of from commandline
  arguments (@miry)
- Update the code to use **Context** pattern. Combine in it options, logger and
  settings. (#47, @miry)

### Added
- Allow to specify `MEDUP_GITHUB_API_TOKEN` environment variable to increase
  number of requests to gist. (#47, @miry)

## [0.4.0] - 2022-04-30
### Changed
- Inline gist media as code block inside a result markdown file. (#39, @miry)
- Inline youtube media as link instead of iframe. (#42, @miry)
- Inline twitter media as blockquote instead of iframe. (#44, @miry)
- Inline general embedy media as link with thumbnail image instead of iframe. (#45, @miry)

### Added
- Move most of debug output to logger. Allow to specify the verbosity of output
  with parameter `-v[NUM]`. Previous messages debug messages are appeared
  in `stderr`. (@miry)
- For rich elements with anotations or markups render next to iframe. (@miry)

## [0.3.0] - 2022-04-09
### Changed
- Update command line argument parse view. During error make sure the exit code is 1 (@miry)
- Use `podman` instead of `docker` (#35, @miry)
- Use crystal lang 1.4.0 (@miry)

### Fixed
- Custom domain posts returns excpetions, fixed the problem (@miry)
- Detect downloaded assets' type and add missing extension (#37, @miry)

### Added
- Add integration tests to test command line output (@miry)
- Extract targets(user, publication, single post) base on pattern. Download articles for different targets in same process. (#36, @miry)

## [0.2.1] - 2022-03-27
### Changed
- Use crystal version from shard for Dockerfile (@miry)

### Fixed
- Skip download assets images without option `--assets-images` (@miry)
- Emoji breaks markdown rendering (#34, @miry, @clawfire)

## [0.2.0] - 2022-03-20
### Changed
- Use crystal lang 1.3.2 (#31, @miry)

### Added
- Export posts from a publication with option `--publication=NAME` (#31, @miry, @clawfire)
- Allow to save images to assets folder with option `--assets-images` (#33, @miry, @clawfire)

## [0.1.10] - 2021-04-17
### Added
- Allow to download pure orginal JSON by url (@miry)

### Changed
- Add ISO8601 format date in the result post filename (@miry)
- Use crystal lang 0.36.1 (@miry)
- Use crystal lang 1.0.0 (@miry)
- Update docker image to use alpine instead ubuntu and static linked libs (@miry)

## [0.1.9] - 2020-09-17
### Changed
- Filename sanitization (#19, @miry)
- Embed images to single document (#3, @miry)
- Download posts in 2 concurent processes (#17, @miry)
- Use crystal lang 0.35.1

## [0.1.8] - 2020-05-22
### Changed
- Use crystal lang 0.33.0 for Docker containers
- Use crystal lang 0.34.0

## [0.1.7] - 2020-03-15
### Added
- Process only one article: medup <url> (#24, @miry)

## [0.1.6] - 2020-03-12
### Added
- Add command line argument to allow update overwrite file content (#16, @miry)
- Fix small parsing issues (#25, #27, @miry)

## [0.1.5] - 2020-01-21
### Added
- Markdown: Store subtitle, tags and SEO description information (#7, @miry)
- Markdown: Store authors information (@miry)
- Export user's recommened articles (#2, @miry)
- Don't raise exceptions for paragraph type 2: with images in background, title and alignment (#2, @miry)
- Print error messages to STDERR (#2, @miry)
- Specify import format via command line (#23, @miry)

### Changed
- Create missing subfolders with more than 1 layer (#2, @miry)

## [0.1.4] - 2019-12-28
### Added
- Markdown: Support inline formatting (#6, @miry)

## [0.1.3] - 2019-12-21
### Added
- Create Changelog
- Create Contributing document
- Download iframe components to assets

### Changed
- Use markdown comments for not implemented elements like IFRAME
- Add section to Readme to show exported vs original document view
- Split paragraphs with 2 empty lines

## [0.1.2] - 2019-12-21
### Changed
- Docker base image is ubuntu bionic
- Upgrade supported crystal language to 0.32.1

### Added
- Allow to release via `rake` tasks

## [0.1.1] - 2019-12-21
### Added
- Minimal markdown export format support

## [0.1.0] - 2019-12-04
### Added
- Initialize project structure
- Relase docker image
- Dump Medium posts base on author name

[Unreleased]: https://github.com/miry/medup/compare/v0.4.1...HEAD
[0.4.1]: https://github.commiry/medup/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.commiry/medup/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.commiry/medup/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.commiry/medup/compare/v0.2.0...v0.2.0
[0.2.0]: https://github.commiry/medup/compare/v0.1.10...v0.2.0
[0.1.10]: https://github.commiry/medup/compare/v0.1.9...v0.1.10
[0.1.9]: https://github.commiry/medup/compare/v0.1.8...v0.1.9
[0.1.8]: https://github.commiry/medup/compare/v0.1.7...v0.1.8
[0.1.7]: https://github.commiry/medup/compare/v0.1.6...v0.1.7
[0.1.6]: https://github.commiry/medup/compare/v0.1.5...v0.1.6
[0.1.5]: https://github.commiry/medup/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.commiry/medup/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.commiry/medup/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.commiry/medup/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.commiry/medup/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.commiry/medup/releases/tag/v0.1.0
