

class Turret
  attr_reader :x, :y, :angle
  def initialize(image, x, y)
    @x, @y = x, y
    @angle = @target_angle = rand(360)
    @fov = 30
    @range = 256
    @speed = 2
    @image = image
  end
  
  def within?(x, y)
    if distance(@x, @y, x, y) < 20 then
      return true
    else
      return false
    end
  end
  
  def update_aim(target_x, target_y)
    if distance(@x, @y, target_x, target_y) <= @range then
      @target_angle = Gosu::angle(@x, @y, target_x, target_y)
    end
  end
  
  def fire(recoil)
    if rand(2) == 0 then
      @angle += recoil
    else
      @angle -= recoil
    end
    # TODO: Spawn bullets here
  end
  
  def update()
    @angle = angle_smoother(@angle, @target_angle, @speed)
  end
  
  def draw(window)
    window.draw_line(@x, @y, Color::RED, @x + offset_x(@angle + @fov, @range), @y + offset_y(@angle + @fov, @range), Color::NONE, 1.5)
    window.draw_line(@x, @y, Color::RED, @x + offset_x(@angle - @fov, @range), @y + offset_y(@angle - @fov, @range), Color::NONE, 1.5)
    @image.draw_rot(@x, @y, 2, @angle)
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
      when 3 # christmas W
        @enemy_color = Color::WHITE
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


class Map
  attr_reader :tile_array, :enemy_exit_array, :theme
  def initialize(window)
    @window = window
    @tile_array = Array.new(24){Array.new(32)}
    @theme = 0
    @map_image = nil
    @map_image_background = nil
    @enemy_spawner_array = []
    @enemy_exit_array = []
    @enemy_array = []
    @turret_array = []
    load_map()
  end
  
  def get_turret_at(x, y)
    @turret_array.each do |turret|
      return turret if turret.within?(x, y)
    end
  end
  
  def add_enemy(x, y, path, color)
    @enemy_array << Enemy.new(x, y, path, Media::get_image('enemy.png'), color)
  end
  
  def load_map()
    #@theme = random(0,2)
    # Christmas update funsies
    @theme = 3
    @map_image = nil
    file_contents = file_read('../maps/map.txt')
    x = 0
    y = 0
    file_contents.each_line do |line|
      line.each_char do |char|
        case char
          when '#'
            @tile_array[y][x] = char
          when 'T'
            @turret_array << Turret.new(Media::get_image('turret.png'), x*32, y*32)
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
    
    record_map_images()
  end
  
  def save_map()
    File.open('map.txt','w+') do |file|
      file.print @tile_string_array
    end
  end
  
  def update()
    @turret_array.each do |turret|
      turret.update()
    end
    @enemy_array.each do |enemy|
      enemy.update()
    end
  end
  
  def get_theme_color()
    case @theme
      when 0 # cold
        return Color.new(255, 0, random(100,255), random(100,255))
      when 1 # warm
        return Color.new(255, random(100,255), 0, random(100,255))
      when 2 # vibrant
        return Color.new(255, random(100,255), random(100,255), 0)
      when 3 # christmas
        if rand(2) == 0 then
          return Color.new(255, random(100,255), 0, 0)
        else
          return Color.new(255, 0, random(100,255), 0)
        end
    end
  end
  
  def record_map_images()
    # Foreground
    @map_image = @window.record(1024, 768) do
      @tile_array.each_index do |y|
        @tile_array[y].each_index do |x|
          if @tile_array[y][x] == '#' then
            color = get_theme_color()
            @window.draw_quad(x*32, y*32, color, (x*32)+32, y*32, color, x*32, (y*32)+32, color, (x*32)+32, (y*32)+32, color, 1)
            Media::get_image('wall.png').draw(x*32, y*32, 2)
          end
        end
      end
    end
    # Background
    @map_image_background = @window.record(1024, 768) do
      @tile_array.each_index do |y|
        @tile_array[y].each_index do |x|
          color = get_theme_color()
          @window.draw_quad(x*32, y*32, color, (x*32)+32, y*32, color, x*32, (y*32)+32, color, (x*32)+32, (y*32)+32, color, 1)
          Media::get_image('wall.png').draw(x*32, y*32, 2)
        end
      end
      @window.draw_quad(0, 0, 0xc8000000, 1024, 0, 0xc8000000, 0, 768, 0xc8000000, 1024, 768, 0xc8000000, 3)
    end
  end
  
  def draw()
    # Map draws ---
    @map_image.draw(0, 0, 1)
    @map_image_background.draw(0, 0, 0)
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

