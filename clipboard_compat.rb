# encoding: utf-8

require 'clipboard'

# Adapt the modern clipboard gem to the old TEXCELL API used by the macros.
# The TEXCELL library already defines ClipBoard#getText and #setText, so leave
# that implementation intact when the Clipboard module is not available.
if defined?(::Clipboard) && ::Clipboard.respond_to?(:paste) && ::Clipboard.respond_to?(:copy)
  class ClipBoard
    def initialize(encoding)
      @encoding = Encoding.find(encoding)
    end

    def getText
      ::Clipboard.paste.encode(@encoding)
    end

    def setText(text)
      ::Clipboard.copy(text.to_s.encode(Encoding::UTF_8))
    end
  end
elsif !defined?(::ClipBoard)
  raise LoadError, "clipboard library did not define Clipboard or ClipBoard"
end
