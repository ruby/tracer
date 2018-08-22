# Tracer

Outputs a source level execution trace of a Ruby program.

It does this by registering an event handler with Kernel#set_trace_func for processing incoming events.  It also provides methods for filtering unwanted trace output (see Tracer.add_filter, Tracer.on, and Tracer.off).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tracer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tracer

## Usage

Consider the following Ruby script

```
  class A
    def square(a)
      return a*a
    end
  end

  a = A.new
  a.square(5)
```

Running the above script using <code>ruby -r tracer example.rb</code> will output the following trace to STDOUT (Note you can also explicitly <code>require 'tracer'</code>)

```
  #0:<internal:lib/rubygems/custom_require>:38:Kernel:<: -
  #0:example.rb:3::-: class A
  #0:example.rb:3::C: class A
  #0:example.rb:4::-:   def square(a)
  #0:example.rb:7::E: end
  #0:example.rb:9::-: a = A.new
  #0:example.rb:10::-: a.square(5)
  #0:example.rb:4:A:>:   def square(a)
  #0:example.rb:5:A:-:     return a*a
  #0:example.rb:6:A:<:   end
   |  |         | |  |
   |  |         | |   ---------------------+ event
   |  |         |  ------------------------+ class
   |  |          --------------------------+ line
   |   ------------------------------------+ filename
    ---------------------------------------+ thread
```

Symbol table used for displaying incoming events:

```
+}+:: call a C-language routine
+{+:: return from a C-language routine
+>+:: call a Ruby method
+C+:: start a class or module definition
+E+:: finish a class or module definition
+-+:: execute code on a new line
+^+:: raise an exception
+<+:: return from a Ruby method
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ruby/tracer.

## License

The gem is available as open source under the terms of the [2-Clause BSD License](https://opensource.org/licenses/BSD-2-Clause).
