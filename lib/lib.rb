
require 'yaml'


#
# This method puts the messages to the console unless the constant $VERBOSE == false
#
def vputs(string)
  # I don't explicitly say == true so as to allow values other than true/false.
  if $VERBOSE == true || $VERBOSE == nil then puts string end
end


#
# This method searches a directory (defaulting to the current directory) and returns everything it found (unless a filter is applied)
#
def search_directory(folder='.', search_for='*')
  result = []
  if search_for != nil then
    search_for = File.join(folder, search_for)
  else
    search_for = folder
  end
  Dir.glob(search_for).each do |file|
    result << file
  end
  return result
end


vputs "Verbosity is on."
__END__
