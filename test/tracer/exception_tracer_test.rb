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

        raise "boom" rescue nil
      RUBY

      out, err = execute_file(file)

      assert_empty(err)
      assert_traces([/^#depth:0  #<RuntimeError: boom> at .*foo.rb:3/], out)
    end

    def test_exception_tracer_with_header
      file = write_file("foo.rb", <<~RUBY)
        ExceptionTracer.new(header: "tracer-1").start

        raise "boom" rescue nil
      RUBY

      out, err = execute_file(file)

      assert_empty(err)
      assert_traces([/^tracer-1 #depth:0  #<RuntimeError: boom> at .*foo.rb:3/], out)
    end
  end
end
