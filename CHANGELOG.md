# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## 0.8.0 - 2019-01-16

- Preliminary back-end changes to enable dynamic tile server
- Preliminary back-end changes to enable local analysis uploads

## [0.7.0] - 2018-06-14

### Added

- Async Batch job creation via Admin UI using Django Q running as an ECS task
- S3 caching for state OSM downloads from Geofabrik to reduce chance of throttling
- Google Analytics for basic site hit tracking

### Changed

- Upgrade Django to 1.11.13 LTS
- Upgrade application third-party Django dependencies
- Improve robustness of Neighborhood boundary simplification algorithm by checking simplified
  geom area against original geom area

### Fixed

- Improper handling of AWS_REGION variable in development environments
- Invalid string formatting of single-digit UTM zones
