require_relative "../test_helper"

module Tracer
  class IvarTracerTest < TestCase
    include ActivationTests

    def build_tracer
      stub_object = Object.new
      IvarTracer.new(stub_object, :@foo, output: @output)
    end
  end

  class IvarTracerIntegrationTest < IntegrationTestCase
    def test_ivar_tracer_traces_attr_accessor_changes
      # Ruby 3.0 and below's attr_accessor calls don't trigger TracePoint properly
      omit if RUBY_VERSION < "3.1"

      file = write_file("foo.rb", <<~RUBY)
        class Foo
          attr_accessor :bar
        end

        obj = Foo.new

        IvarTracer.new(obj, :@bar).start

        obj.bar = 100
      RUBY

      out, err = execute_file(file)

      assert_empty(err)
      assert_traces(
        [%r{^#depth:0 Foo#bar= sets @bar = 100 at .*/foo\.rb:9}],
        out
      )
    end

    def test_ivar_tracer_traces_method_changes
      file = write_file("foo.rb", <<~RUBY)
        class Foo
          def bar=(value)
            @bar = value
          end
        end

        obj = Foo.new

        IvarTracer.new(obj, :@bar).start

        obj.bar = 100
      RUBY

      out, err = execute_file(file)

      assert_empty(err)
      assert_traces(
        [%r{^#depth:0 Foo#bar= sets @bar = 100 at .*/foo\.rb:11}],
        out
      )
    end

    def test_ivar_tracer_with_header
      file = write_file("foo.rb", <<~RUBY)
        class Foo
          def bar=(value)
            @bar = value
          end
        end

        obj = Foo.new

        IvarTracer.new(obj, :@bar, header: "trace-foo@bar").start

        obj.bar = 100
      RUBY

      out, err = execute_file(file)

      assert_empty(err)
      assert_traces(
        [%r{^trace-foo@bar #depth:0 Foo#bar= sets @bar = 100 at .*/foo\.rb:11}],
        out
      )
    end

    def test_ivar_tracer_works_with_basic_object
      file = write_file("foo.rb", <<~RUBY)
        class Foo < BasicObject
          def bar=(value)
            @bar = value
          end
        end

        obj = Foo.new

        IvarTracer.new(obj, :@bar).start

        obj.bar = 100
      RUBY

      out, err = execute_file(file)

      assert_empty(err)
      assert_traces(
        [%r{^#depth:0 Foo#bar= sets @bar = 100 at .*/foo\.rb:11}],
        out
      )
    end
  end
end
