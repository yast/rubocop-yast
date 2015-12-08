# Change Log

## master (unreleased)

## 0.0.7 (2015-12-08)

### Changes

- Added Cucumber features converted from the Zombie Killer spec.
  Some of them are marked as pending because they don't work yet.
- SafeMode config removed, it is always enabled instead.
- StrictMode config added, enabled by default: report all Ops, even if they
  cannot be autocorrected.

## 0.0.6 (2014-12-15)

### New Features

- added `LogVariable` Cop (check for `log` variable assignment)

### Changes

- converted MarkDown test descriptions to Cucumber (removed our specific
  Markdown -> RSpec renderer)

### Fixed Bugs

- `Ops` Cop - fixed crash when using `--auto-gen-config` option
- `Builtins` Cop - fixed crash when parenthesis were missing aroung method argument
