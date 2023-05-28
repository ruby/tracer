# frozen_string_literal: true

require "pp"
require_relative "color"

module Tracer
  class Base
    DIR = __dir__
    M_OBJECT_ID = Object.instance_method(:object_id)
    M_INSPECT = Object.instance_method(:inspect)
    M_CLASS = Object.instance_method(:class)
    M_IS_A = Object.instance_method(:is_a?)
    HOME = ENV["HOME"] ? (ENV["HOME"] + "/") : nil

    include Color

    class LimitedPP
      def self.pp(obj, max)
        out = self.new(max)
        catch out do
          PP.singleline_pp(obj, out)
        end
        out.buf
      end

      attr_reader :buf

      def initialize(max)
        @max = max
        @cnt = 0
        @buf = String.new
      end

      def <<(other)
        @buf << other

        if @buf.size >= @max
          @buf = @buf[0..@max] + "..."
          throw self
        end
      end
    end

    def safe_inspect(obj, max_length: 40)
      LimitedPP.pp(obj, max_length)
    rescue NoMethodError => e
      klass, oid = M_CLASS.bind_call(obj), M_OBJECT_ID.bind_call(obj)
      if obj == (r = e.receiver)
        "#<#{klass.name}#{oid} does not have \#inspect>"
      else
        rklass, roid = M_CLASS.bind_call(r), M_OBJECT_ID.bind_call(r)
        "#<#{klass.name}:#{roid} contains #<#{rklass}:#{roid} and it does not have #inspect>"
      end
    rescue Exception => e
      "<#inspect raises #{e.inspect}>"
    end

    def pretty_path(path)
      return "#<none>" unless path

      case
      when path.start_with?(dir = RbConfig::CONFIG["rubylibdir"] + "/")
        path.sub(dir, "$(rubylibdir)/")
      when Gem.path.any? { |gp| path.start_with?(dir = gp + "/gems/") }
        path.sub(dir, "$(Gem)/")
      when HOME && path.start_with?(HOME)
        path.sub(HOME, "~/")
      else
        path
      end
    end

    attr_reader :header

    def initialize(
      output: STDOUT,
      pattern: nil,
      colorize: nil,
      depth_offset: 0,
      header: nil
    )
      @name = self.class.name
      @type = @name.sub(/Tracer\z/, "")
      @output = output
      @depth_offset = depth_offset
      @colorize = colorize || colorizable?
      @header = header

      if pattern
        @pattern = Regexp.compile(pattern)
      else
        @pattern = nil
      end

      @tp = setup_tp
    end

    def key
      [@type, @pattern, @into].freeze
    end

    def to_s
      s = "#{@name} #{description}"
      s += " with pattern #{@pattern.inspect}" if @pattern
      s
    end

    def description
      "(#{@tp.enabled? ? "enabled" : "disabled"})"
    end

    def start(&block)
      puts "PID:#{Process.pid} #{self}" if @output.is_a?(File)

      if block
        @tp.enable(&block)
      else
        @tp.enable
        self
      end
    end

    def stop
      @tp.disable
    end

    def started?
      @tp.enabled?
    end

    def stopped?
      !started?
    end

    def skip?(tp)
      skip_internal?(tp) || skip_with_pattern?(tp)
    end

    def skip_with_pattern?(tp)
      @pattern && !tp.path.match?(@pattern)
    end

    def skip_internal?(tp)
      tp.path.match?(DIR)
    end

    def out(tp, msg = nil, depth: caller.size - 1, location: nil)
      location ||= "#{tp.path}:#{tp.lineno}"
      if header
        str = +"#{header} "
      else
        str = +""
      end
      str << "\#depth:#{"%-2d" % depth}#{msg} at #{colorize("#{location}", [:GREEN])}"

      puts str
    end

    def puts(msg)
      @output.puts msg
      @output.flush
    end

    def minfo(tp)
      return "block{}" if tp.event == :b_call

      klass = tp.defined_class

      if klass.singleton_class?
        "#{tp.self}.#{tp.method_id}"
      else
        "#{klass}\##{tp.method_id}"
      end
    end

    def colorizable?
      no_color = (nc = ENV["NO_COLOR"]).nil? || nc.empty?
      @output.is_a?(IO) && @output.tty? && no_color
    end
  end
end
