
# Copyright (c) Chase Arnold 2012

$VERBOSE = true

require_relative 'lib/lib.rb'
require_relative 'lib/lib_misc.rb'
require_relative 'lib/astar.rb'
require 'rubygems'
require 'gosu'
include Gosu
include AStar

srand()

class GameWindow < Gosu::Window
  def initialize
    super(1024, 768, false)
    self.caption = 'Turret Defense'
    @map = Map.new(self)
  end # End GameWindow Initialize
  
  def update
    @map.update(mouse_x, mouse_y)
  end # End GameWindow Update
  
  def draw
    clip_to(0,0,1024,768) do
      @map.draw(self)
      draw_quad(0, 0, 0xff646464, 1024, 0, 0xff646464, 0, 768, 0xff646464, 1024, 768, 0xff646464, 0)
    end
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


class Turret
  attr_reader :x, :y, :angle
  def initialize(image, x, y)
    @x, @y = x, y
    @angle = rand(360)
    @fov = 30
    @range = 256
    @speed = 2
    @image = image
  end
  
  def update_aim(target_x, target_y)
    if distance(@x, @y, target_x, target_y) <= @range then
      @angle = angle_smoother(@angle, Gosu::angle(@x, @y, target_x, target_y), @speed)
    end
  end
  
  def update()
  end
  
  def draw(window)
    window.draw_line(@x, @y, Color::RED, @x + offset_x(@angle + @fov, @range), @y + offset_y(@angle + @fov, @range), Color::NONE, 1.5)
    window.draw_line(@x, @y, Color::RED, @x + offset_x(@angle - @fov, @range), @y + offset_y(@angle - @fov, @range), Color::NONE, 1.5)
    @image.draw_rot(@x, @y, 2, @angle)
  end
end


class Enemy_Spawner
  attr_reader :cell_x, :cell_y
  def initialize(cell_x, cell_y, map)
    @map = map
    @cell_x, @cell_y = cell_x, cell_y
    @path = find_path()
    case @map.theme
      when 0 # cold B no R
        @enemy_color = Color::RED
      when 1 # warm R no G
        @enemy_color = Color::GREEN
      when 2 # vibrant G no B
        @enemy_color = Color::BLUE
    end
  end
  
  def find_path()
    index = 0
    current_distance = distance(@cell_x, @cell_y, @map.enemy_exit_array[0].cell_x, @map.enemy_exit_array[0].cell_y)
    @map.enemy_exit_array.each_index do |i|
      next if i == 0 # First one is already recorded, so skip it
      distance = distance(@cell_x, @cell_y, @map.enemy_exit_array[i].cell_x, @map.enemy_exit_array[i].cell_y)
      if distance < current_distance then
        index = i
        current_distance = distance
      end
    end
    return AMap.results(@cell_x, @cell_y, @map.enemy_exit_array[index].cell_x, @map.enemy_exit_array[index].cell_y, AMap.new(convert_to_pricemap(@map.tile_array)))
  end
  
  def spawn_enemy()
    @map.add_enemy(@cell_x * 32, @cell_y * 32, @path, @enemy_color)
  end
  
  def convert_to_pricemap(wall_layer)
    result = Array.new(wall_layer.count){Array.new(wall_layer[0].count){0}}
    wall_layer.each_index do |y|
      wall_layer[y].each_index do |x|
        if wall_layer[y][x] == '#' then
          result[y][x] = 100000 # So insanely high, it never climbs walls
        else
          result[y][x] = 1
        end
      end
    end
    return result
  end
end


class Enemy_Exit
  attr_reader :cell_x, :cell_y
  def initialize(cell_x, cell_y)
    @cell_x, @cell_y = cell_x, cell_y
  end
  
  def draw()
  end
end


class Enemy
  def initialize(x, y, path, image, color)
    @x, @y, @path = x, y, path
    @cell = []
    next_node()
    @image = image
    @color = color
  end
  
  def next_node()
    if @path[0] != nil then
      @cell = @path.shift
    end
  end
  
  def update()
    if @x == (@cell[0]*32) and @y == (@cell[1]*32) then
      next_node()
    end
    @x = smoother(@x, @cell[0]*32, 1)
    @y = smoother(@y, @cell[1]*32, 1)
  end
  
  def draw()
    @image.draw(@x, @y, 1, 1, 1, @color)
  end
end


class Map
  attr_reader :tile_array, :enemy_exit_array, :theme
  def initialize(window)
    @window = window
    @tile_array = Array.new(24){Array.new(32)}
    @image_hash = load_images()
    @theme = 0
    @map_image = nil
    @enemy_spawner_array = []
    @enemy_exit_array = []
    @enemy_array = []
    @turret_array = []
    load_map()
  end
  
  def add_enemy(x, y, path, color)
    @enemy_array << Enemy.new(x, y, path, @image_hash['enemy.png'], color)
  end
  
  def load_images()
    result = {}
    search_directory('images').each do |image_path|
      result[image_path.split('/').last] = Image.new(@window, image_path, true)
    end
    return result
  end
  
  def load_map()
    @theme = random(0,2)
    @map_image = nil
    file_contents = file_read('map.txt')
    x,y = 0,0
    file_contents.each_line do |line|
      line.each_char do |char|
        case char
          when '#'
            @tile_array[y][x] = char
          when 'T'
            @turret_array << Turret.new(@image_hash['turret.png'], x*32, y*32)
          when 'S'
            @enemy_spawner_array << [x,y]
          when 'E'
            @enemy_exit_array << Enemy_Exit.new(x, y)
        end
        x += 1
      end
      x = 0
      y += 1
    end
    @enemy_spawner_array.each_index do |i|
      @enemy_spawner_array[i] = Enemy_Spawner.new(@enemy_spawner_array[i][0], @enemy_spawner_array[i][1], self)
      @enemy_spawner_array[i].spawn_enemy() # FIXME: Just for testing
    end
  end
  
  def save_map()
    File.open('map.txt','w+') do |file|
      file.print @tile_string_array
    end
  end
  
  def update(mouse_x, mouse_y)
    @turret_array.each do |turret|
      turret.update()
      turret.update_aim(mouse_x, mouse_y)
    end
    @enemy_array.each do |enemy|
      enemy.update()
    end
  end
  
  def draw(window)
    # Map draws ---
    if @map_image.is_a?(Gosu::Image) then
      @map_image.draw(0, 0, 1)
    else
      @map_image = window.record(1024, 768) do
        @tile_array.each_index do |y|
          @tile_array[y].each_index do |x|
            if @tile_array[y][x] == '#' then
              case @theme
                when 0 # cold
                  color = Color.new(255, 0, random(50,255), random(50,255))
                when 1 # warm
                  color = Color.new(255, random(50,255), 0, random(50,255))
                when 2 # vibrant
                  color = Color.new(255, random(50,255), random(50,255), 0)
              end
              @window.draw_quad(x*32, y*32, color, (x*32)+32, y*32, color, x*32, (y*32)+32, color, (x*32)+32, (y*32)+32, color, 1)
              @image_hash['wall.png'].draw(x*32, y*32, 2)
            end
          end
        end
      end
    end
    # ---
    # Other draws ---
    @turret_array.each do |turret|
      turret.draw(@window)
    end
    @enemy_array.each do |enemy|
      enemy.draw()
    end
    # ---
  end
end


window = GameWindow.new.show