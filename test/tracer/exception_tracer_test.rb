require_relative "../test_helper"

module Tracer
  class ExceptionTracerTest < TestCase
    include ActivationTests

    private

    def build_tracer
      ExceptionTracer.new(output: @output, colorize: false)
    end
  end

  class ExceptionTracerIntegrationTest < IntegrationTestCase
    def test_exception_tracer_traces_exceptions
      file = write_file("foo.rb", <<~RUBY)
        ExceptionTracer.new.start

        begin
          raise "boom"
        rescue
        end
      RUBY

      out, err = execute_file(file)

      expected_traces = [
        /^#depth:0  #<RuntimeError: boom> raised at .*foo.rb:4/
      ]

      if RUBY_VERSION >= "3.3.0"
        expected_traces << /^#depth:1  #<RuntimeError: boom> rescued at .*foo.rb:5/
      end

      assert_empty(err)
      assert_traces(expected_traces, out)
    end

    def test_exception_tracer_with_header
      file = write_file("foo.rb", <<~RUBY)
        ExceptionTracer.new(header: "tracer-1").start

        begin
          raise "boom"
        rescue
        end
      RUBY

      out, err = execute_file(file)

      expected_traces = [
        /^tracer-1 #depth:0  #<RuntimeError: boom> raised at .*foo.rb:4/
      ]

      if RUBY_VERSION >= "3.3.0"
        expected_traces << /^tracer-1 #depth:1  #<RuntimeError: boom> rescued at .*foo.rb:5/
      end

      assert_empty(err)
      assert_traces(expected_traces, out)
    end
  end
end
