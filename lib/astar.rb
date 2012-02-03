
# All credit goes to: Marcin Coles
#

#require 'time'


def special_string_to_array(string)
  result = string.split(',')
  result[0] = result[0].split('[')[1].to_i
  result[1] = result[1].split(']')[0].to_i
  return result
end


module AStar

  class AMap
    attr_reader :nodes
    def initialize(costmap)
      #cost map is a 2D array - eg a 2x2 map is AMap.new([[3,5],[3,2]])
      # the values are the movement cost for the node at those co-ordinates
      #should do some error checking for size of the map, but anyway
      # note that the costmap array is indexed @costmap[y][x], 
      # which is the opposite way to Node(x,y)
      @costmap=costmap
      @height=costmap.size
      @width=costmap.first.size
      @nodes=[]
      @output="\n"
      costmap.each_index do |row|
        costmap[row].each_index do |col|
          @nodes.push(Node.new(col,row,costmap[row][col]))
          @output<<"|#{costmap[row][col]}"
        end
        @output<<"|\n"
      end
    end
    
    def self.results(startx, starty, goalx, goaly, astar_instance)
      start=astar_instance.co_ord(startx.to_i,starty.to_i)
      finish=astar_instance.co_ord(goalx.to_i,goaly.to_i)
      goal=astar_instance.astar(start,finish)
      curr=goal
      result = []
      while curr.parent do # Add each node coords to the the array
        result << special_string_to_array(curr.to_s.split(' ')[0])
        curr=curr.parent
      end
      result << special_string_to_array(curr.to_s.split(' ')[0]) # Add the final node coords to the array
      result.reverse! # Make the array go from start to finish
      return result
    end
    
    def generate_successor_nodes(anode)
      # determine nodes bordering this one - only North,S,E,W for now
      # no boundary condition check, eg if anode.x==-4
      # considers a wall to be a 0 so therefore not allow that to be a neighbour
      north=@costmap[anode.y-1][(anode.x)] unless (anode.y-1)<0 #boundary check for -1
      south=@costmap[anode.y+1][(anode.x)] unless (anode.y+1)>(@height-1)
      east=@costmap[anode.y][(anode.x+1)] unless (anode.x+1)>(@width-1)
      west=@costmap[anode.y][(anode.x-1)] unless (anode.x-1)<0 #boundary check for -1
      
      if (west && west>0) then # not on left edge, so provide a left-bordering node
        newnode=Node.new((anode.x-1),anode.y,@costmap[anode.y][(anode.x-1)])
        yield newnode
      end
      if (east && east>0) then # not on right edge, so provide a right-bordering node
        newnode=Node.new((anode.x+1),anode.y,@costmap[anode.y][(anode.x+1)])
        yield newnode
      end
      if (north && north>0) then # not on left edge, so provide a left-bordering node
        newnode=Node.new(anode.x,(anode.y-1),@costmap[(anode.y-1)][anode.x])
        yield newnode
      end
      if (south && south>0) then # not on right edge, so provide a right-bordering node
        newnode=Node.new(anode.x,(anode.y+1),@costmap[(anode.y+1)][anode.x])
        yield newnode
      end    
    end

    def astar(node_start,node_goal)
      iterations=0
      open=PriorityQueue.new()
      closed=PriorityQueue.new()
      node_start.calc_h(node_goal)
      open.push(node_start)
      while !open.empty? do
        iterations+=1 #keep track of how many times this itersates
        node_current=open.find_best
        if node_current==node_goal then #found the solution
          return node_current 
        end       
        generate_successor_nodes(node_current) do |node_successor|
          #now doing for each successor node of node_current
          node_successor.calc_g(node_current)
          #skip to next node_successor if better one already on open or closed list
          if open_successor=open.find(node_successor) then 
            if open_successor<=node_successor then next end  #need to account for nil result
          end
          if closed_successor=closed.find(node_successor) then
            if closed_successor<=node_successor then next end 
          end
          #still here, then there's no better node yet, so remove any copies of this node on open/closed lists
          open.remove(node_successor)
          closed.remove(node_successor)
          # set the parent node of node_successor to node_current
          node_successor.parent=node_current
          # set h to be the estimated distance to node_goal using the heuristic
          node_successor.calc_h(node_goal)
          # so now we know this is the best copy of the node so far, so put it onto the open list
          open.push(node_successor)
        end
        #now we've gone through all the successors, so the current node can be closed
        closed.push(node_current)
      end
    end
      
    def co_ord(x,y)
      a=Node.new(x,y)
      @nodes.find {|n| n==a}
    end
    
    def to_s
      @output
    end
  end
  
  
  class Node
    #class Node provides a node on a map which can be used for pathfinding. 
    #For Node to work with PriorityQueue and AMap it needs to implement the following
    # <= used for comparing g values
    # == used for finding the same node - using the x,y co-ordinates
    attr_accessor :parent
    attr_reader :x,:y,:g,:h,:m
    
    def initialize(x,y,move_cost=0)
      @x,@y,@m=x,y,move_cost
      @g=@m
      @h=0
    end
    
    def to_s
      #prints the node in the following format [x,y] f:g:h
      "[#{@x},#{@y}] #{@g+@h}:#{@g}:#{@h}"
    end
    
    def <=>(other)
      #can be used for ordering the priority list
      #puts "using <=>" #currently unused - can delete this line if required
      self.f<=>other.f
    end
    
    def <=(other)
      #used for comparing cost so far
      @g<=other.g
    end
     
    def ==(other)
      # nodes are == if x and y are the same - used for finding and removing same node
      return false if other==nil
      return (@x==other.x)&(@y==other.y)
    end
    
    def calc_g(previous)
      #cost so far is total cost of previous step plus the movement cost of this one
      @g=previous.g+@m
    end
    
    def calc_h(goal)
      #using manhattan distance to generate a heuristic value
      @h=(@x-goal.x).abs+(@y-goal.y).abs
    end
    def f
      @g+@h
    end
    def better?(other,tbmul=1.01)
      #which is better, self or other
      #can pass a tie-breaker multiplier (tbmul) if required
      if other==nil then return false end
      if self==other then return false end
      if f<other.f then 
        return true
      #here's the tie-breaker
      elsif f==other.f then
        nf=@g+tbmul*@h
        bf=other.g+tbmul*other.h
        if nf<bf then return true end
      end
      false
    end
      
  end
  
  
  class PriorityQueue
    def initialize(nodes=[])
      @nodes=nodes
      #tie-breaker multiplier (tbmul) is 1+1/(the sqrt of the map size)
      @tbmul=1+1/(Math.sqrt(@nodes.size))
    end
    def method_missing(methodname, *args)
      #if in doubt, act like an array
      @nodes.send(methodname, *args)
    end
    def find_best
      #finds the best node, then pops it out
      best=@nodes.first
      @nodes.each do |node|
        if node.better?(best,@tbmul) then best=node end
      end
      remove(best)
    end
    def find(node)
      #finds a node - requires that node implements ==
      @nodes.find {|x| x==node }
    end
    
    def remove(node)
      #removes a node
      @nodes.delete(find(node))
    end
    
    def to_s
      output = ''
      @nodes.each {|e| output<<"#{e};"}
    end
    
  end
end

