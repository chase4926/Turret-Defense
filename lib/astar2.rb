
# All credit goes to: Daniel Martin <martin snowplow.org>
# Taken from ruby quiz #98 (comments taken out), and modified to serve purposes
#


require 'enumerator'

class PriorityQueue
  def initialize
    @list = []
  end
  def add(priority, item)
    @list << [priority, @list.length, item]
    @list.sort!
    self
  end
  def <<(pritem)
    add(*pritem)
  end
  def next
    @list.shift[2]
  end
  def empty?
    @list.empty?
  end
end

class Astar
  def find_path(array_2d, start_array, goal_array)
    @terrain = array_2d
    @start = start_array # [y,x]
    @goal = goal_array # [y,x]
    if do_find_path
      return @path
    else
      return nil
    end
  end

  def do_find_path
    been_there = {}
    pqueue = PriorityQueue.new
    pqueue << [1,[@start,[],1]]
    while !pqueue.empty?
      spot,path_so_far,cost_so_far = pqueue.next
      next if been_there[spot]
      newpath = [path_so_far, spot]
      if (spot == @goal)
        @path = []
        newpath.flatten.each_slice(2) {|i,j| @path << [i,j]}
        return @path
      end
      been_there[spot] = 1
      spotsfrom(spot).each {|newspot|
        next if been_there[newspot]
        tcost = @terrain[newspot[0]][newspot[1]]
        newcost = cost_so_far + tcost
        pqueue << [newcost + estimate(newspot), [newspot,newpath,newcost]]
      }
    end
    return nil
  end

  def estimate(spot)
    [(spot[0] - @goal[0]).abs, (spot[1] - @goal[1]).abs].max
  end
  
  def spotsfrom(spot)
    retval = []
    vertadds = [0,1]
    horizadds = [0,1]
    if (spot[0] > 0) then vertadds << -1; end
    if (spot[1] > 0) then horizadds << -1; end
    vertadds.each{|v| horizadds.each{|h|
        if (v != 0 or h != 0) then
          ns = [spot[0]+v,spot[1]+h]
          if (@terrain[ns[0]] and @terrain[ns[0]][ns[1]]) then
            retval << ns
          end
        end
      }}
    retval
  end
end

