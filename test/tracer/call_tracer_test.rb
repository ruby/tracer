require_relative "../test_helper"

module Tracer
  class CallTracerTest < TestCase
    include ActivationTests

    private

    def build_tracer
      CallTracer.new(output: @output)
    end
  end

  class CallTracerIntegrationTest < IntegrationTestCase
    def test_object_tracer_traces_method_calls
      file = write_file("foo.rb", <<~RUBY)
        obj = Object.new

        def obj.foo
          100
        end

        def bar(obj)
          obj.foo
        end

        CallTracer.new.start

        bar(obj)
      RUBY

      out, err = execute_file(file)

      assert_empty(err)
      assert_traces(
        [
          %r{^#depth:0 >  Object#bar at .*/foo\.rb:13},
          %r{^#depth:1 >   #<Object:.*>\.foo at .*/foo\.rb:8},
          %r{^#depth:1 <   #<Object:.*>\.foo #=> 100 at .*/foo\.rb:8},
          %r{^#depth:0 <  Object#bar #=> 100 at .*/foo\.rb:13}
        ],
        out
      )
    end

    def test_object_tracer_with_header
      file = write_file("foo.rb", <<~RUBY)
        obj = Object.new

        def obj.foo
          100
        end

        def bar(obj)
          obj.foo
        end

        CallTracer.new(header: "tracer-1").start

        bar(obj)
      RUBY

      out, err = execute_file(file)

      assert_empty(err)
      assert_traces(
        [
          %r{^tracer-1 #depth:0 >  Object#bar at .*/foo\.rb:13},
          %r{^tracer-1 #depth:1 >   #<Object:.*>\.foo at .*/foo\.rb:8},
          %r{^tracer-1 #depth:1 <   #<Object:.*>\.foo #=> 100 at .*/foo\.rb:8},
          %r{^tracer-1 #depth:0 <  Object#bar #=> 100 at .*/foo\.rb:13}
        ],
        out
      )
    end
  end
end
