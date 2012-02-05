
require 'yaml'

#
# Returns true if the directory exists (convenience method)
#
def directory_exists?(directory)
  File.directory? directory
end


=begin
#
# Does a recursive search of a directory
#
def old_recursive_search_directory(directory, path_so_far=nil)
  result = []
  search_directory(directory).each do |path|
    if File.directory?(path) then
      if path_so_far == nil then
        next_path_so_far = path.split('/').last
      else
        next_path_so_far = "#{path_so_far}/#{path.split('/').last}"
      end
      recursive_search_directory(path, next_path_so_far).each do |n|
        result << n
      end
    else
      if path_so_far == nil then
        result << path.split('/').last
      else
        result << "#{path_so_far}/#{path.split('/').last}"
      end
    end
  end
  return result
end
=end


#
# Does a recursive search of a directory
#
def recursive_search_directory(directory, path_so_far=nil)
  result = Dir.glob(File.join(directory, '**/*'))
  result.each_index do |i|
    result[i] = nil if File.directory?(result[i])
  end
  result.compact!
  return result
end


#
# Does a block of code verbosely regardless of the state of the $VERBOSE variable
#
def verbosely()
  if $VERBOSE == true then
    reset = true
  else
    reset = false
  end
  $VERBOSE = true
  yield
  $VERBOSE = reset
end


#
# Does a block of code non-verbosely regardless of the state of the $VERBOSE variable
#
def non_verbosely()
  if $VERBOSE == true then
    reset = true
  else
    reset = false
  end
  $VERBOSE = false
  yield
  $VERBOSE = reset
end


#
# Returns the number at nth place in the fibonacci sequence that starts at start_number
#
def fib(start_number, n)
  curr = start_number
  succ = start_number
  n.times do
    curr, succ = succ, curr + succ
  end
  return curr
end


#
# Returns a 2d array full of ' ' elements
#
def create_2d_array(width, height)
  return Array.new(height){Array.new(width){' '}}
end


#
# Returns a 3d array full of ' ' elements
#
def create_3d_array(width, height, depth)
  return Array.new(depth){create_2d_array(width, height)}
end


#
# Returns a random number between min and max
#
def random(min, max)
  srand()
  return (min..max).to_a.sort_by{rand}.pop
end


#
# Returns a random floating point integer between min and max
#
def randomfloat(min, max, seed=nil) # Why do I need this?
  a = random(min, max, seed)
  a = a.to_f / 10.to_f
  return a
end


#
# Returns the contents of an entire file read into a string
#
def file_read(file)
  vputs "Reading file #{file}"
  if not File.exists?(file) then
    vputs "That file doesn't exist: #{file.inspect}"
    return ''
  end
  f = File.open(file, 'r')
    string = f.read
  f.close
  return string
end


#
# Returns the contents of a yaml file
#
def yamlfileread(file)
  if not File.exists?(file) then
    vputs "That file doesn't exist: #{file.inspect}"
    return ''
  end
  return YAML::load( File.open(file, 'r') )
end


#
# Creates a file with filename file, and fills it with file_contents
#
def create_file(file, file_contents)
  vputs "Creating file: #{file}"
  begin
    File.open(file, 'w+') do |f|  # open file for update
      f.print file_contents       # write file_contents to the file
    end                           # file is automatically closed
  rescue Exception
  end
end


#
# Returns a number from number as close to target_number as rate will allow
#
def smoother(number, target_number, rate)
  rate = rate.abs
  if (number - target_number).abs > rate then
    if number < target_number then
      return (number + rate)
    else # number > target_number
      return (number - rate)
    end
  else
    return target_number
  end
end


#
# Returns an angle from angle as close to target_angle as rate will allow
#
def angle_smoother(angle, target_angle, rate)
  # Fix the angles
  angle %= 360 #=# Geany, fix your syntax highlighting!
  target_angle %= 360 #=
  # Calculate the change
  if angle < 180 then
    change = angle * -1
  elsif angle == 180 then
    change = 180
  else # angle > 180
    change = 360 - angle
  end
  # Get the transitioned target angle
  target_angle = (target_angle + change) % 360
  # Calculate the new angle, depending on rate, and return it
  if target_angle < 180 then # cw
    angle = 0
  elsif target_angle == 180 then # random
    if rand(2) == 0 then
      angle = 360
    else
      angle = 0
    end
  else # ccw
    angle = 360
  end
  return (smoother(angle, target_angle, rate) - change) % 360
end


#
# Used for line of sight, not made by me
#
def get_line(x0,y0,x1,y1)
  points = []
  steep = ((y1-y0).abs) > ((x1-x0).abs)
  if steep
    x0,y0 = y0,x0
    x1,y1 = y1,x1
  end
  if x0 > x1
    x0,x1 = x1,x0
    y0,y1 = y1,y0
  end
  deltax = x1-x0
  deltay = (y1-y0).abs
  error = (deltax / 2).to_i
  y = y0
  ystep = nil
  if y0 < y1
    ystep = 1
  else
    ystep = -1
  end
  for x in x0..x1
    if steep
      points << {:x => y, :y => x}
    else
      points << {:x => x, :y => y}
    end
    error -= deltay
    if error < 0
      y += ystep
      error += deltax
    end
  end
  return points
end


__END__
