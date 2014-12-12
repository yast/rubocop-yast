rubocop-yast
============

[![Gem Version](https://badge.fury.io/rb/rubocop-yast.svg)](http://badge.fury.io/rb/rubocop-yast)
[![Dependency Status](https://gemnasium.com/yast/rubocop-yast.svg)](https://gemnasium.com/yast/rubocop-yast)
[![Travis Build](https://travis-ci.org/yast/rubocop-yast.svg?branch=master)](https://travis-ci.org/yast/rubocop-yast)
[![Coverage Status](https://img.shields.io/coveralls/yast/rubocop-yast.svg)](https://coveralls.io/r/yast/rubocop-yast?branch=master)
[![Code Climate](https://codeclimate.com/github/yast/rubocop-yast/badges/gpa.svg)](https://codeclimate.com/github/yast/rubocop-yast)
[![Inline docs](http://inch-ci.org/github/yast/rubocop-yast.svg?branch=master)](http://inch-ci.org/github/yast/rubocop-yast)


This is a plugin for [RuboCop](https://github.com/bbatsov/rubocop)
a Ruby static code analyzer. It was inspired by [Rubocop-Rspec](https://github.com/nevir/rubocop-rspec)
and [YCP Zombie Killer](https://github.com/yast/zombie-killer).

The goal is to create a Rubocop plugin which can check for
[YaST](http://yast.github.io/) specific issues. Optionally it should allow to
covert some ugly code parts introduced by the automatic code conversion done by
[YCP Killer](https://github.com/yast/ycp-killer) (conversion from YCP to Ruby).

Check [the test descriptions](spec/builtins_spec.md) to see the examples of offense
detection and code conversion.

*The plugin is currently in early development, always manually check the chages
done by the plugin! It can eat your code... ;-)*


Installation
------------

The plugin is published at [rubygems.org](https://rubygems.org/gems/rubocop-yast),
you can install it using the `gem` command:

```shell
sudo gem install rubocop-yast
```

You can also install the latest development version directly from the Git repository,
see [Building a Gem](#building-a-gem) section below.

Usage
-----

You need to manually load the Yast plugin into RuboCop to run the extra checks.
There are two options:

- Use `--require rubocop-yast` command line option when invoking `rubocop`
- Enable the plugin in `.rubocop.yml` file:
```yaml
require:
 - rubocop-yast
```

See the [RuboCop documentation](https://github.com/bbatsov/rubocop#loading-extensions).

Configuration
-------------

You can configure Rubocop-Yast the same way as the standard RuboCop checks
(see the [RuboCop configuration](https://github.com/bbatsov/rubocop#configuration)):

```yaml
# Check for obsolete Builtins.* calls
Yast/Builtins:
  Enabled: true

# Check for obsolete Ops.* calls
Yast/Ops:
  Enabled: true
  # in the safe mode only safe places are reported and fixed
  SafeMode: true
```

Development
-----------

### Prerequisites

For development you need some extra development gems. The best way is to install them with [Bundler](http://bundler.io/). To avoid a possible collision with system gems (esp. RSpec,
Yast still uses version 2.14 while rubocop-yast uses 3.1) it is recommended
to install the gems into a local subdirectory using:

```shell
bundle install --path vendor/bundle
```

### Source Directories

* [`config/default.yml`](config/default.yml) contains the default Cop configurations
* [`lib/rubocop/cop/yast`](lib/rubocop/yast) contains Yast Cops (the checks which are called
  from the main rubocop script)
* [`lib/rubocop/yast`](lib/rubocop/yast) contains libraries used by the Cops
* [`spec`](spec) contains tests, some tests are automatically generated from a MarkDown
  documentation

### Running Tests

```
bundle exec rake
```
 
By default the tests check the code coverage, if it is below 95% the test fails although
there was no test failure.
 
### Autocorrecting Rubocop Issues
 
```
bundle exec rake rubocop:auto_correct
```
 
You can also load the plugin itself to verify that plugin loading works correctly.
(Plugin loading is not covered by tests as it needs the base Rubocop framework.)

```
bundle exec rubocop -r rubocop-yast
```

### Building a Gem

```
bundle exec rake build
```

This builds `pkg/rubocop-yast-<version>.gem` gem file, it can be installed locally using
```
sudo gem install --local pkg/rubocop-yast-<version>.gem
```

### Publishing the Gem to Rubygems.org

Increase the version in [`lib/rubocop/yast/version.rb`](lib/rubocop/yast/version.rb) file
and then run:

```
bundle exec rake release
```

