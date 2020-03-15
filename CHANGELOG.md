# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
