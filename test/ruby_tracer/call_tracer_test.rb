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
          %r{#depth:2 >  Object#bar at .*/foo\.rb:7},
          %r{#depth:3 >   #<Object:.*>\.foo at .*/foo\.rb:3},
          %r{#depth:3 <   #<Object:.*>\.foo #=> 100 at .*/foo\.rb:5},
          %r{#depth:2 <  Object#bar #=> 100 at .*/foo\.rb:9}
        ],
        out
      )
    end
  end
end
