

module Media
  @@images_hash = {}
  @@sounds_hash = {}
  @@tilesets_hash = {}
  
  def self.get_sound(key)
    return @@sounds_hash[key]
  end
  
  def self.get_image(key)
    return @@images_hash[key]
  end
  
  def self.get_tileset(key)
    return @@tilesets_hash[key]
  end
  
  def self.get_graphic(key)
    image = self.get_image(key)
    tileset = self.get_tileset(key)
    if image then
      return [image]
    elsif tileset then
      return tileset
    end
  end
  
  def self.get_tileset_list(start_of_key='')
    result = []
    @@tilesets_hash.each_key do |key|
      if key.start_with?(start_of_key)
        result << key
      end
    end
    return result
  end
  
  def self.load_images(window, path)
    recursive_search_directory(path).each do |image_path|
      if image_path.split('.').last() == 'png' then
        @@images_hash[image_path.split(File.join(path,''), 2)[1]] = Image.new(window, image_path, true)
      end
    end
  end
  
  def self.load_sounds(window, path, samples_folder='samples', songs_folder='songs')
    samples_folder = File.join(path, samples_folder)
    songs_folder = File.join(path, songs_folder)
    
    if File.directory?(samples_folder) then
      # Load samples
      recursive_search_directory(samples_folder).each do |sample_path|
        @@sounds_hash[sample_path.split(File.join(path,''), 2)[1]] = Sample.new(window, sample_path)
      end
    elsif $VERBOSE then
      puts "'#{samples_folder}' directory not found, no samples were loaded"
    end
    
    if File.directory?(songs_folder) then
      # Load songs
      recursive_search_directory(songs_folder).each do |song_path|
        @@sounds_hash[song_path.split(File.join(path,''), 2)[1]] = Song.new(window, song_path)
      end
    elsif $VERBOSE then
      puts "'#{songs_folder}' directory not found, no songs were loaded"
    end
  end
  
  def self.load_tilesets(window, path)
    search_directory(path).each do |folder|
      size = folder.split('/').last().split('x', 2)
      size[0] = size[0].to_i()
      size[1] = size[1].to_i()
      if size[0] > 0 and size[1] > 0 then
        recursive_search_directory(folder).each do |tileset_path|
          @@tilesets_hash[tileset_path.split(File.join(path,''), 2)[1]] = Gosu::Image.load_tiles(window, tileset_path, size[0], size[1], true)
        end
      end
    end
  end
  
  def self.initialize(window, images_directory, sounds_directory, tilesets_directory)
    if File.directory?(images_directory) then
      # Load images
      self.load_images(window, images_directory)
    elsif $VERBOSE then
      puts "'#{images_directory}' directory not found, images were not loaded!"
    end
    if File.directory?(sounds_directory) then
      # Load sounds
      self.load_sounds(window, sounds_directory)
    elsif $VERBOSE then
      puts "'#{sounds_directory}' directory not found, sounds were not loaded!"
    end
    if File.directory?(tilesets_directory) then
      # Load tilesets
      self.load_tilesets(window, tilesets_directory)
    elsif $VERBOSE then
      puts "'#{tilesets_directory}' directory not found, tilesets were not loaded!"
    end
  end
end


__END__
# --- TEST ---

$VERBOSE = true

require 'rubygems'
require 'gosu'
include Gosu


class GameWindow < Gosu::Window
  def initialize()
    super(256, 256, false)
    self.caption = 'Media Loader test'
    Media::initialize(self, 'images', 'sounds')
    Media::get_sound('songs/song1.ogg').play()
    @image = Media::get_image('wall.png')
    @angle = rand(360)
  end # End GameWindow Initialize
  
  def update()
    @angle += 2
  end # End GameWindow Update
  
  def draw()
    10.times do
      @image.draw_rot(rand(128) + 48, rand(128) + 48, 0, @angle)
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


window = GameWindow.new().show()

