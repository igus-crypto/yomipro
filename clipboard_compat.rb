# encoding: utf-8

require 'clipboard'

# Compatibility adapter for the former TEXCELL clipboard API.
class ClipBoard
  def initialize(encoding)
    @encoding = Encoding.find(encoding)
  end

  def getText
    Clipboard.paste.encode(@encoding)
  end

  def setText(text)
    Clipboard.copy(text.to_s.encode(Encoding::UTF_8))
  end
end