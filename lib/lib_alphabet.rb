

module Alphabet
  def self.new_text(window, message, scale=1)
    return Alphabet::record_image(window, message, scale)
  end
  
  def self.letter_to_index(letter)
    index = letter.ord() - 33
    if index == -1 then
      index = 1000
    elsif index < 0 or index > 93
      index = 93
    end
    return index
  end
  
  def self.record_image(window, message, scale)
    message_array = [[]]
    message_y = 0
    message.each_char do |letter|
      if letter == "\n" then
        message_y += 1
        message_array[message_y] = []
      else
        message_array[message_y] << @@alphabet_tilesheet[Alphabet::letter_to_index(letter)]
      end
    end
    max_width = 0
    message_array.each do |line|
      max_width = line.count if line.count > max_width
    end
    return window.record((max_width * 6) * scale, (8 * message_array.count) * scale) do
      message_array.each_index do |y|
        message_array[y].each_index do |i|
          message_array[y][i].draw(i * (6 * scale), (y * 8) * scale, 0, scale, scale) unless message_array[y][i] == nil
        end
      end
    end
  end
  
  def self.draw_text(text, x, y, z, scale, color = 0xFFFFFFFF)
    text = text.to_s()
    i = 0
    text.gsub!("\n", '\n')
    text.each_char do |letter|
      letter_image = Alphabet::get_alphabet()[Alphabet::letter_to_index(letter)]
      letter_image.draw(x + (i * (6 * scale)), y, z, scale, scale, color) unless letter_image == nil
      i += 1
    end
  end
  
  def self.initialize(window)
    Gosu::enable_undocumented_retrofication()
    @@alphabet_tilesheet = Gosu::Image::load_tiles(window, "#{File.dirname(__FILE__)}/alphabet.png", 5, 7, false)
  end
  
  def self.get_alphabet()
    return @@alphabet_tilesheet
  end
end


__END__
# --- TEST ---

require 'rubygems'
require 'gosu'
include Gosu

$TEXT = "You\nYou shall\nYou shall not\nYou shall not pass!\n#396 Ready for processing...\n$13.37 for that telepad.\n(**)@ (x,y) <x,y> {x,y}\n5 > 3 | 3 < 5"
$SCALE = 3


class GameWindow < Gosu::Window
  def initialize()
    super(640, 640, false)
    self.caption = 'Alpha Test'
    Alphabet::initialize(self)
    @text1 = Alphabet::new_text(self, $TEXT, $SCALE)
  end # End GameWindow Initialize
  
  def update()
  end # End GameWindow Update
  
  def draw()
    #@text1.draw(32,32,0)
    #14.times do |i|
      # No lag, at least on home desktop computer
      #Alphabet::draw_text("Hello World!\n", 32, i * 32, 3)
    #end
  end # End GameWindow Draw
  
  def button_down(id)
    if id == KbEscape
      close
    end
  end
  
  def needs_cursor?
    true
  end
end # End GameWindow class


window = GameWindow.new().show()

