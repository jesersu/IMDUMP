fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios build_debug

```sh
[bundle exec] fastlane ios build_debug
```

Build the app for Debug configuration

### ios build_release

```sh
[bundle exec] fastlane ios build_release
```

Build the app for Release configuration

### ios test

```sh
[bundle exec] fastlane ios test
```

Run all unit tests

### ios test_with_coverage

```sh
[bundle exec] fastlane ios test_with_coverage
```

Run tests with code coverage

### ios setup

```sh
[bundle exec] fastlane ios setup
```

Setup project dependencies and secrets

### ios lint

```sh
[bundle exec] fastlane ios lint
```

Run SwiftLint to check code quality

### ios ci

```sh
[bundle exec] fastlane ios ci
```

Run CI checks (lint, test, build)

### ios ci_quick

```sh
[bundle exec] fastlane ios ci_quick
```

Quick CI without linting (for GitHub Actions)

### ios archive

```sh
[bundle exec] fastlane ios archive
```

Create archive for distribution

### ios clean

```sh
[bundle exec] fastlane ios clean
```

Clean build artifacts and derived data

### ios update_dependencies

```sh
[bundle exec] fastlane ios update_dependencies
```

Update project dependencies

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
