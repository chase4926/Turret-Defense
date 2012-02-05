

class Info_Bar
  def initialize(window)
    @image = window.image_hash['sidebar.png']
    @x = 864
    @y = 64
    @width = 128
    @height = 256
    @target = nil
    @color = Color.new(200, 255, 255, 255)
  end
  
  def set_target(target)
    @target = target
  end
  
  def within?(x, y)
    if @target != nil and x > @x and x < (@x + @width) and y > @y and y < (@y + @height) then
      return true
    else
      return false
    end
  end
  
  def clicked(x, y)
  end
  
  def update()
  end
  
  def draw(window)
    if @target != nil then
      @image.draw(@x, @y, 4, 1, 1, @color)
      #window.draw_quad(@x, @y, @color, @x + @width, @y, @color, @x, @y + @height, @color, @x + @width, @y + @height, @color, 4)
    end
  end
end


class Gui
  def initialize(window)
    @window = window
    @info_bar = Info_Bar.new(@window)
  end
  
  def clicked()
    if @info_bar.within?(@window.mouse_x, @window.mouse_y)
      @info_bar.clicked(@window.mouse_x, @window.mouse_y)
    elsif (turret = @window.map.get_turret_at(@window.mouse_x, @window.mouse_y)).is_a?(Turret) then
      @info_bar.set_target(turret)
    else
      @info_bar.set_target(nil)
    end
  end
  
  def update()
    @info_bar.update()
  end
  
  def draw()
    @info_bar.draw(@window)
  end
end

