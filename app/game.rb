
# Copyright (c) Chase Arnold 2012

$VERBOSE = true

require_relative '../lib/lib.rb'
require_relative '../lib/lib_misc.rb'
require_relative '../lib/astar.rb'
require_relative 'map.rb'
require_relative 'gui.rb'
require 'rubygems'
require 'gosu'
include Gosu
include AStar

srand()

class GameWindow < Gosu::Window
  attr_reader :image_hash, :map
  def initialize
    super(1024, 768, false)
    self.caption = 'Turret Defense'
    @image_hash = load_images('../images')
    @map = Map.new(self)
    @gui = Gui.new(self)
  end # End GameWindow Initialize
  
  def load_images(path)
    result = {}
    recursive_search_directory(path).each do |image_path|
      result[image_path.split(File.join(path,''), 2)[1]] = Image.new(self, image_path, true)
    end
    return result
  end
  
  def update
    @map.update()
    @gui.update()
  end # End GameWindow Update
  
  def draw
    clip_to(0,0,1024,768) do
      @map.draw()
      @gui.draw()
      draw_quad(0, 0, 0xff646464, 1024, 0, 0xff646464, 0, 768, 0xff646464, 1024, 768, 0xff646464, 0)
    end
  end # End GameWindow Draw
  
  def button_down(id)
    if id == KbEscape
      close
    elsif id == MsLeft
      @gui.clicked()
    end
  end
  
  def needs_cursor?
    true
  end
end # End GameWindow class


window = GameWindow.new.show
