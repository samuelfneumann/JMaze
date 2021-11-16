module JMaze

include("Init.jl")

export wilson!, binarytree!, backtracking!, iterative!, aldousbroder!
export BiasDirection

export Grid

export north, can_move_north, south, can_move_south, west, can_move_west, east, \
    can_move_east, random_neighbour, neighbours, link, unlink, linked
export Cell


end