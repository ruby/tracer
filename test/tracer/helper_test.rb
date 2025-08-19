require_relative "../test_helper"

module Tracer
  class HelperIntegrationTest < IntegrationTestCase
    def test_trace_exception
      file = write_file("foo.rb", <<~RUBY)
        require "tracer/helper"

        trace_exception do
          raise "boom" rescue nil
        end
      RUBY

      out, err = execute_file(file)

      expected_traces = [
        /^#depth:1  #<RuntimeError: boom> raised at .*foo.rb:4/
      ]

      if RUBY_VERSION >= "3.3.0"
        expected_traces << /^#depth:\d+  #<RuntimeError: boom> rescued at .*foo.rb:4/
      end

      assert_empty(err)
      assert_traces(expected_traces, out)
    end

    def test_trace_call
      file = write_file("foo.rb", <<~RUBY)
        require "tracer/helper"

        obj = Object.new

        def obj.foo
          100
        end

        def bar(obj)
          obj.foo
        end

        trace_call do
          bar(obj)
        end
      RUBY

      out, err = execute_file(file)

      assert_empty(err)
      assert_traces(
        [
          %r{#depth:1 >      Object#bar at .*/foo\.rb:14},
          %r{#depth:2 >       #<Object:.*>\.foo at .*/foo\.rb:10},
          %r{#depth:2 <       #<Object:.*>\.foo #=> 100 at .*/foo\.rb:10},
          %r{#depth:1 <      Object#bar #=> 100 at .*/foo\.rb:14}
        ],
        out
      )
    end

    def test_trace
      file = write_file("foo.rb", <<~RUBY)
        require "tracer/helper"

        obj = Object.new

        def obj.foo
          100
        end

        def bar(obj)
          obj.foo
        end

        trace(obj) do
          bar(obj)
        end
      RUBY

      out, err = execute_file(file)

      assert_empty(err)
      assert_traces(
        [
          /#depth:1  #<Object:.*> is used as a parameter obj of Object#bar at .*foo\.rb:14/,
          /#depth:2  #<Object:.*> receives .foo at .*foo\.rb:10/
        ],
        out
      )
    end
  end
end
