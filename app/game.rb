
# Copyright (c) Chase Arnold 2012
#
# Email: chase4926 @ gmail.com
#

$VERBOSE = true

require_relative '../lib/lib.rb'
require_relative '../lib/lib_misc.rb'
require_relative '../lib/lib_medialoader.rb'
require_relative '../lib/astar.rb'
require_relative 'map.rb'
require_relative 'gui.rb'
require 'rubygems'
require 'gosu'
include Gosu
include AStar

srand()

class GameWindow < Gosu::Window
  attr_reader :map
  def initialize()
    super(1024, 768, false)
    self.caption = 'Turret Defense'
    Media::initialize(self, '../images', '../sounds', '../tilesets')
    @map = Map.new(self)
    @gui = Gui.new(self)
  end # End GameWindow Initialize
  
  def update()
    @map.update()
    @gui.update()
  end # End GameWindow Update
  
  def draw()
    clip_to(0,0,1024,768) do
      @map.draw()
      @gui.draw()
      #draw_quad(0, 0, 0xff646464, 1024, 0, 0xff646464, 0, 768, 0xff646464, 1024, 768, 0xff646464, -10)
    end
  end # End GameWindow Draw
  
  def button_down(id)
    if id == KbEscape
      close()
    elsif id == MsLeft
      @gui.clicked()
    end
  end
  
  def needs_cursor?()
    return true
  end
end # End GameWindow class


window = GameWindow.new().show()
