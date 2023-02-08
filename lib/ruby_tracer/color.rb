# frozen_string_literal: true

module Tracer
  module Color
    CLEAR     = 0
    BOLD      = 1
    UNDERLINE = 4
    REVERSE   = 7
    RED       = 31
    GREEN     = 32
    YELLOW    = 33
    BLUE      = 34
    MAGENTA   = 35
    CYAN      = 36

    class << self
      def colorize(text, seq)
        seq = seq.map { |s| "\e[#{const_get(s)}m" }.join('')
        "#{seq}#{text}#{clear}"
      end

      def clear
        "\e[#{CLEAR}m"
      end
    end

    def colorize(str, seq, colorize: @colorize)
      # don't colorize trace sent into a file
      if @output.is_a?(File) || !colorize
        str
      else
        Color.colorize(str, seq)
      end
    end


    def colorize_cyan(str)
      colorize(str, [:CYAN, :BOLD])
    end

    def colorize_blue(str)
      colorize(str, [:BLUE, :BOLD])
    end

    def colorize_magenta(str)
      colorize(str, [:MAGENTA, :BOLD])
    end
  end
end
