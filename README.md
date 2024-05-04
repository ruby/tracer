# Tracer

[![Ruby](https://github.com/ruby/tracer/actions/workflows/main.yml/badge.svg)](https://github.com/ruby/tracer/actions/workflows/main.yml)
[![Gem Version](https://badge.fury.io/rb/tracer.svg)](https://badge.fury.io/rb/tracer)

The `tracer` gem provides helpful tracing utilities to help users observe their program's runtime behaviour.

The currently supported tracers are:

- [`ObjectTracer`](#objecttracer)
- [`IvarTracer`](#ivartracer)
- [`CallTracer`](#calltracer)
- [`ExceptionTracer`](#exceptiontracer)
- [`LineTracer`](#linetracer)

It also comes with experimental [IRB integration](#irb-integration) to allow quick access from REPL.

## Installation

```shell
$ bundle add tracer --group=development,test
```

Or directly add it to your `Gemfile`

```rb
group :development, :test do
  gem "tracer"
end
```

If bundler is not being used to manage dependencies, install the gem by executing:

```shell
$ gem install tracer
```

## Usage

```rb
Tracer.trace(object) { ... } # trace object's activities in the given block
Tracer.trace_call { ... } # trace method calls in the given block
Tracer.trace_exception { ... } # trace exceptions in the given block
```

**Example**

```rb
require "tracer"

obj = Object.new

def obj.foo
  100
end

def bar(obj)
  obj.foo
end

Tracer.trace(obj) { bar(obj) }
 #depth:1  #<Object:0x000000010903c190> is used as a parameter obj of Object#bar at test.rb:13:in `block in <main>'
 #depth:2  #<Object:0x000000010903c190> receives .foo at test.rb:10:in `bar'
```

### `tracer/helper`

If you want to avoid the `Tracer` namespace, you can do `require "tracer/helper"` instead:

```rb
require "tracer/helper"

trace(object) { ... } # trace object's activities in the given block
trace_call { ... } # trace method calls in the given block
trace_exception { ... } # trace exceptions in the given block
```

### Tracer Classes

If you want to have more control over individual traces, you can use individual tracer classes:

#### ObjectTracer

```rb
class User
  def initialize(name) = (@name = name)

  def name() = @name
end

def authorized?(user)
  user.name == "John"
end

user = User.new("John")
tracer = ObjectTracer.new(user)
tracer.start do
  user.name
  authorized?(user)
end

 #depth:3  #<User:0x000000010696cad8 @name="John"> receives #name (User#name) at test.rb:14:in `block in <main>'
 #depth:3  #<User:0x000000010696cad8 @name="John"> is used as a parameter user of Object#authorized? at test.rb:15:in `block in <main>'
 #depth:4  #<User:0x000000010696cad8 @name="John"> receives #name (User#name) at test.rb:8:in `authorized?'
```

#### IvarTracer

> [!Note]
> Ruby 3.0 and below's accessor calls don't trigger TracePoint properly so the result may be inaccurate with those versions.

```rb
require "tracer"

class Cat
  attr_accessor :name
end

cat = Cat.new

tracer = IvarTracer.new(cat, :@name)
tracer.start do
  cat.name = "Kitty"
  cat.instance_variable_set(:@name, "Ketty")
end

#depth:3 Cat#name= sets @name = "Kitty" at test.rb:11
#depth:3 Kernel#instance_variable_set sets @name = "Ketty" at test.rb:12
```

#### ExceptionTracer

```rb
ExceptionTracer.new.start

begin
  raise "boom"
rescue StandardError
  nil
end

#depth:0  #<RuntimeError: boom> raised at test.rb:4
#depth:1  #<RuntimeError: boom> rescued at test.rb:6
```

#### CallTracer

```rb
class User
  def initialize(name) = (@name = name)

  def name() = @name
end

def authorized?(user)
  user.name == "John"
end

user = User.new("John")
tracer = CallTracer.new
tracer.start do
  user.name
  authorized?(user)
end

 #depth:4 >    block at test.rb:13
 #depth:5 >     User#name at test.rb:4
 #depth:5 <     User#name #=> "John" at test.rb:4
 #depth:5 >     Object#authorized? at test.rb:7
 #depth:6 >      User#name at test.rb:4
 #depth:6 <      User#name #=> "John" at test.rb:4
 #depth:6 >      String#== at test.rb:8
 #depth:6 <      String#== #=> true at test.rb:8
 #depth:5 <     Object#authorized? #=> true at test.rb:9
 #depth:4 <    block #=> true at test.rb:16
```

#### LineTracer

```rb
class User
  def initialize(name) = (@name = name)

  def name() = @name
end

def authorized?(user)
  user.name == "John"
end

user = User.new("John")
tracer = LineTracer.new
tracer.start do
  user.name
  authorized?(user)
end

 #depth:4  at test.rb:14
 #depth:4  at test.rb:15
 #depth:5  at test.rb:8
```

### IRB-integration

Once required, `tracer` registers a few IRB commands to help you trace Ruby expressions:

```
trace              Trace the target object (or self) in the given expression. Usage: `trace [target,] <expression>`
trace_call         Trace method calls in the given expression. Usage: `trace_call <expression>`
trace_exception    Trace exceptions in the given expression. Usage: `trace_exception <expression>`
```

**Example**

```rb
# test.rb
require "tracer"

obj = Object.new

def obj.foo
  100
end

def bar(obj)
  obj.foo
end

binding.irb
```

```shell
irb(main):001:0> trace obj, bar(obj)
 #depth:23 #<Object:0x0000000107a86648> is used as a parameter obj of Object#bar at (eval):1:in `<main>'
 #depth:24 #<Object:0x0000000107a86648> receives .foo at test.rb:10:in `bar'
=> 100
irb(main):002:0> trace_call bar(obj)
 #depth:23>                            Object#bar at (eval):1:in `<main>'
 #depth:24>                             #<Object:0x0000000107a86648>.foo at test.rb:10:in `bar'
 #depth:24<                             #<Object:0x0000000107a86648>.foo #=> 100 at test.rb:10:in `bar'
 #depth:23<                            Object#bar #=> 100 at (eval):1:in `<main>'
=> 100
```

## Customization

TBD

## Acknowledgements

A big shout-out to [@ko1](https://github.com/ko1) (Koichi Sasada) for his awesome work on [`ruby/debug`](https://github.com/ruby/debug).
The [tracers in `ruby/debug`](https://github.com/ruby/debug/blob/master/lib/debug/tracer.rb) were an inspiration and laid the groundwork for this project.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test-unit` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ruby/tracer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ruby/tracer/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [2-Clause BSD License](https://opensource.org/licenses/BSD-2-Clause).

## Code of Conduct

Everyone interacting in the Ruby::Tracer project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ruby/tracer/blob/master/CODE_OF_CONDUCT.md).
