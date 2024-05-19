# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2024-05-20

### Added

- Support RHEL8 and CentOS 8
- Add version requirement in `metadata.json` (`>= 6.21.0 < 9.0.0`)

### Changed

- Update structure to work with latest puppet version

## [1.0.3] - 2015-02-04

### Fixed

- do not crash on unexpected rpm output
- improve test coverage

## [1.0.2] - 2015-02-01

### Added

- Add SLES and CentOS as supported operating systems (thanks to Michael Moll
  and Gene Liverman for testing)

### Changed

- If the source parameter specifies a local file that you also manage
  through a puppet file resource, the file resource will be autorequired
  by the rpmkey resource (Thanks to duritong for implementing this)

## [1.0.1] - 2015-01-22

### Changed

- Update metadata.json with tested operating systems

## [1.0.0] - 2015-01-21

### Added

- Initial release for puppet forge
