rubocop-yast
============

[![Gem Version](https://badge.fury.io/rb/rubocop-yast.svg)](http://badge.fury.io/rb/rubocop-yast)
[![Dependency Status](https://gemnasium.com/lslezak/rubocop-yast.svg)](https://gemnasium.com/lslezak/rubocop-yast)
[![Travis Build](https://travis-ci.org/lslezak/rubocop-yast.svg?branch=master)](https://travis-ci.org/lslezak/rubocop-yast)
[![Coverage Status](https://img.shields.io/coveralls/lslezak/rubocop-yast.svg)](https://coveralls.io/r/lslezak/rubocop-yast?branch=master)
[![Code Climate](https://codeclimate.com/github/lslezak/rubocop-yast/badges/gpa.svg)](https://codeclimate.com/github/lslezak/rubocop-yast)
[![Inline docs](http://inch-ci.org/github/lslezak/rubocop-yast.svg?branch=master)](http://inch-ci.org/github/lslezak/rubocop-yast)


This is a plugin for [RuboCop](https://github.com/bbatsov/rubocop)
a Ruby static code analyzer. It was inspired by [Rubocop-Rspec](https://github.com/nevir/rubocop-rspec)
and [YCP Zombie Killer](https://github.com/yast/zombie-killer).

The goal is to create a Rubocop plugin which can check for
[YaST](http://yast.github.io/) specific issues. Optionally it should allow to
covert some ugly code parts introduced by the automatic code conversion done by
[YCP Killer](https://github.com/yast/ycp-killer) (conversion from YCP to Ruby).

Check [the test descriptions](spec/builtins_spec) to see the examples of offense
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


