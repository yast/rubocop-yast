Builtins Cop
============

Table Of Contents
-----------------

1. Description
1. Builtins.time()
1. Builtins.getenv()
1. Logging

Description
-----------

This Cop is designed to check for `Builtins` call presence. These calls were
added by YCP Killer to ensure 100% compatibily of the translated Ruby code
with the old YCP.

But these calls should not be used in the new code, native Ruby methods should
be used instead of these wrappers.

The Cop can autocorrect some trivial or easy translatable builtins.

Generic Tests
-------------

It reports y2milestone builtin as offense

**Offense**

```ruby
Builtins.y2milestone("foo")
```

It finds builtin in explicit Yast namespace

**Offense**

```ruby
Yast::Builtins.y2milestone("foo")
```

It finds builtin in explicit ::Yast namespace

**Offense**

```ruby
::Yast::Builtins.y2milestone("foo")
```

Builtins in the ::Builtins name space are ignored

**Accepted**

```ruby
::Builtins.y2milestone("foo")
```

Builtins in non Yast name space are ignored

**Accepted**

```ruby
Foo::Builtins.y2milestone("foo")
```

lsort(), crypt and gettext builtins are allowed

**Accepted**

```ruby
Builtins.lsort(["foo"])
Builtins.crypt("foo")
Builtins.dgettext("domain", "foo")
```

It does not change unknown builtins

**Unchanged**

```ruby
Builtins.foo()
```


Builtins.time()
---------------

Is trivially converted to `::Time.now.to_i`

**Original**

```ruby
Builtins.time()
```

**Translated**

```ruby
::Time.now.to_i
```

Builtins.getenv()
-----------------

With string literal parameter is translated to ENV equivalent

**Original**

```ruby
Builtins.getenv("foo")
```

**Translated**

```ruby
ENV["foo"]
```

Variable as parameter is preserved.

**Original**

```ruby
foo = bar
Builtins.getenv(foo)
```

**Translated**

```ruby
foo = bar
ENV[foo]
```

Any other statement is preserved.

**Original**

```ruby
Builtins.getenv(Ops.add(foo, bar))
```

**Translated**

```ruby
ENV[Ops.add(foo, bar)]
```

Logging
--------

It translates `y2debug` to `log.debug`

**Original**

```ruby
Builtins.y2debug("foo")
```

**Translated**

```ruby
include Yast::Logger
log.debug "foo"
```

It translates `y2milestone` to `log.info`

**Original**

```ruby
Builtins.y2milestone("foo")
```

**Translated**

```ruby
include Yast::Logger
log.info "foo"
```

It translates `y2warning` to `log.warn`

**Original**

```ruby
Builtins.y2warning("foo")
```

**Translated**

```ruby
include Yast::Logger
log.warn "foo"
```

It translates `y2error` to `log.error`

**Original**

```ruby
Builtins.y2error("foo")
```

**Translated**

```ruby
include Yast::Logger
log.error "foo"
```

It translates `y2security` to `log.error`

**Original**

```ruby
Builtins.y2security("foo")
```

**Translated**

```ruby
include Yast::Logger
log.error "foo"
```

It translates `y2internal` to `log.fatal`

**Original**

```ruby
Builtins.y2internal("foo")
```

**Translated**

```ruby
include Yast::Logger
log.fatal "foo"
```

It adds the include statement only once

**Original**

```ruby
Builtins.y2milestone("foo")
Builtins.y2milestone("foo")
```

**Translated**

```ruby
include Yast::Logger
log.info \"foo\"
log.info \"foo\"
```

It converts YCP sformat to Ruby interpolation

**Original**

```ruby
Builtins.y2milestone("foo: %1", foo)
```

**Translated**

```ruby
include Yast::Logger
log.info "foo: #{foo}"
```

It converts %% in the format string to simple %.

**Original**

```ruby
Builtins.y2milestone("foo: %1%%", foo)
```

**Translated**

```ruby
include Yast::Logger
log.info "foo: #{foo}%"
```

It replaces repeated % placeholders in the format string

**Original**

```ruby
Builtins.y2warning("%1 %1", foo)
```

**Translated**

```ruby
include Yast::Logger
log.warn "#{foo} #{foo}"
```

The % placeholders do not need to start from 1

**Original**

```ruby
Builtins.y2warning("%2 %2", foo, bar)
```

**Translated**

```ruby
include Yast::Logger
log.warn "#{bar} #{bar}"
```

The % placeholders do not need to be in ascending order

**Original**

```ruby
Builtins.y2warning("%2 %1", foo, bar)
```

**Translated**

```ruby
include Yast::Logger
log.warn "#{bar} #{foo}"
```

It keep the original statements in interpolated string

**Original**

```ruby
Builtins.y2warning("%1", foo + bar)
```

**Translated**

```ruby
include Yast::Logger
log.warn "#{foo + bar}"
```

It adds logger include to the class definition

**Original**

```ruby
class Foo
  Builtins.y2error('foo')
end
```

**Translated**

```ruby
class Foo
  include Yast::Logger

  log.error "foo"
end
```

It adds logger include with correct indentation

**Original**

```ruby
  class Foo
    Builtins.y2error('foo')
  end
```

**Translated**

```ruby
  class Foo
    include Yast::Logger

    log.error "foo"
  end
```

It does not add the logger include if already present

**Original**

```ruby
class Foo
  include Yast::Logger
  Builtins.y2error('foo')
end
```

**Translated**

```ruby
class Foo
  include Yast::Logger
  log.error "foo"
end
```

It adds the logger include after the parent class name if present

**Original**

```ruby
class Foo < Bar
  Builtins.y2error('foo')
end
```

**Translated**

```ruby
class Foo < Bar
  include Yast::Logger

  log.error "foo"
end
```

It adds logger include once to a derived class in a module

**Original**

```ruby
module Yast
  class TestClass < Module
    def test
      Builtins.y2error("foo")
      Builtins.y2debug("foo")
    end
  end
end
```

**Translated**

```ruby
module Yast
  class TestClass < Module
    include Yast::Logger

    def test
      log.error "foo"
      log.debug "foo"
    end
  end
end
```

It converts the single quoted format string to double quoted

**Original**

```ruby
Builtins.y2milestone('foo: %1', foo)
```

**Translated**

```ruby
include Yast::Logger
log.info "foo: #{foo}"
```

It escapes double quotes and interpolations

**Original**

```ruby
Builtins.y2milestone('"#{foo}"')
```

**Translated**

```ruby
include Yast::Logger
log.info "\\"\\#{foo}\\""
```

It does not convert logging with backtrace

**Unchanged**

```ruby
Builtins.y2milestone(-1, "foo")
```

It does not convert code with a local variable 'log'

**Original**

```ruby
log = 1
Builtins.y2milestone("foo")
```

<!--

Template
--------

It translates.

**Original**

```ruby
```

**Translated**

```ruby
```

It does not translate.

**Unchanged**

```ruby
```
-->