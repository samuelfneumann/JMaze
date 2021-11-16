using Random

include("Cell.jl")
include("Grid.jl")
include("Init.jl")

mutable struct Player
    in::Cell
end

function moveeast!(p::Player)
    if can_move_east(p.in)
        p.in = east(p.in)
    end
end

function movewest!(p::Player)
    if can_move_west(p.in)
        p.in = west(p.in)
    end
end

function movenorth!(p::Player)
    if can_move_north(p.in)
        p.in = north(p.in)
    end
end

function movesouth!(p::Player)
    if can_move_south(p.in)
        p.in = south(p.in)
    end
end

struct Maze
    g::Grid
    goal::Cell
    start::Cell
    p::Player
    onehot::Bool
end

function Maze(rows::Integer, cols::Integer, goalrow::Integer, goalcol::Integer,
    startrow::Integer, startcol::Integer, initgrid!, onehot::Bool=false,
    seed::Integer=1)::Maze
    g = Grid(rows, cols)
    rng = MersenneTwister(UInt(seed))
    initgrid!(g, rng)

    # Get the goal cell
    goalrow < 1 && throw(BoundsError(g, goalrow))
    goalcol < 1 && throw(BoundsError(g, goalcol))
    goal = g[goalrow, goalcol]

    # Get the starting cell
    startrow < 1 && throw(BoundsError(g, startrow))
    startcol < 1 && throw(BoundsError(g, startcol))
    start = g[startrow, startcol]

    p = Player(start)
    Maze(g, goal, start, p, onehot)
end

function setcell(m::Maze, row::Integer, col::Integer)
    cell = m.g[row, col]
    m.player.in = cell
end

function atgoal(m::Maze)::Bool
    m.p.in == m.goal
end

function step!(m::Maze, action::Integer)
    if action < 0 || action > 4
        error("action should be in [1, 4] but got $action")
    end

    if action == 0
        movenorth!(m.p)
    elseif action == 1
        movesouth!(m.p)
    elseif action == 2
        movewest!(m.p)
    else
        moveeast!(m.p)
    end

    done = atgoal(m)
    reward = done ? 0.0 : -1.0

    return obs(m), reward, done
end

function reset!(m::Maze)
    m.player = Player(m.start)
    obs(m)
end

function Base.show(io::IO, m::Maze)
    print(io, "+")

    for _ = 1:m.g.cols
        print(io, "---+")
    end
    print(io, "\n")

    for r = 1:m.g.rows
        top = "|"
        bottom = "+"
        for c = 1:m.g.cols
            cell = m.g.cells[r, c]

            if cell == m.p.in
                body = " x "
            elseif cell == m.goal
                body = " ⚐ "
            else
                body = "   "
            end

            if linked(cell, east(cell))
                eastbound = " "
            else
                eastbound = "|"
            end

            top = string(top, body, eastbound)

            if linked(cell, south(cell))
                southbound = "   "
            else
                southbound = "---"
            end

            corner = "+"
            bottom = string(bottom, southbound, corner)
        end

        print(io, string(top, "\n", bottom, "\n"))
    end
end

function play(m::Maze)
    while !atgoal(m)
        print(stdout, "\x1b[3;J\x1b[H\x1b[2J")
        println(m)
        print("Action [W S A D; Q - Quit]: ")

        line = readline()
        line = uppercase(line)
        if line == "W"
            movenorth!(m.p)
        elseif line == "S"
            movesouth!(m.p)
        elseif line == "D"
            moveeast!(m.p)
        elseif line == "A"
            movewest!(m.p)
        else
            print("Action [W S A D; Q - Quit]: ")
        end
    end
    print(stdout, "\x1b[3;J\x1b[H\x1b[2J")
    println(m)
    println("You won!")
end


function obs(m::Maze)
    if m.onehot
        return onehot(m)
    end

    Float64[m.player.in.col, m.player.in.row]
end

function onehot(m::Maze)::Vector{UInt8}
    onehot = zeros(Uint8, (m.g.rows, m.g.cols))
    onehot[m.player.in.row, m.player.in.col] = 1
    reshape(onehot, length(g))
end

m = Maze(10, 10, 10, 10, 1, 1, wilson!)
play(m)