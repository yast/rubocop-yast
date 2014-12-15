# Change Log

## master (unreleased)

## 0.0.6 (15/12/2014)

### New Features

- added `LogVariable` Cop (check for `log` variable assignment)

### Changes

- converted MarkDown test descriptions to Cucumber (removed our specific
  Markdown -> RSpec renderer)

### Fixed Bugs

- `Ops` Cop - fixed crash when using `--auto-gen-config` option
- `Builtins` Cop - fixed crash when parenthesis were missing aroung method argument
