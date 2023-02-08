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
        ExceptionTracer.new(colorize: false).start

        raise "boom" rescue nil
      RUBY

      out, err, status = execute_file(file)

      assert_empty(err)
      lines = out.strip.split("\n")
      assert_equal(1, lines.size)
      assert_match(/depth:1  #<RuntimeError: boom> at .*foo.rb:3/, lines.first)
    end
  end
end
