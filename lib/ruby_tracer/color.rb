# frozen_string_literal: true

module Tracer
  module Color
    CLEAR = 0
    BOLD = 1
    UNDERLINE = 4
    REVERSE = 7
    RED = 31
    GREEN = 32
    YELLOW = 33
    BLUE = 34
    MAGENTA = 35
    CYAN = 36

    class << self
      def colorize(text, seq)
        seq = seq.map { |s| "\e[#{const_get(s)}m" }.join("")
        "#{seq}#{text}#{clear}"
      end

      def clear
        "\e[#{CLEAR}m"
      end
    end

    def colorize(str, seq, colorize: @colorize)
      !colorize ? str : Color.colorize(str, seq)
    end

    def colorize_cyan(str)
      colorize(str, %i[CYAN BOLD])
    end

    def colorize_blue(str)
      colorize(str, %i[BLUE BOLD])
    end

    def colorize_magenta(str)
      colorize(str, %i[MAGENTA BOLD])
    end
  end
end
