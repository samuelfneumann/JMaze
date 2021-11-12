using Random

"""
A single cell in a grid of cells, which can be connected to other cells
"""
mutable struct Cell
    row::Int
    col::Int
    north
    south
    east
    west
    links::Set{Cell}
end

function Cell(r::Integer, c::Integer)::Cell
    c = Cell(r, c, nothing, nothing, nothing, nothing, Set{Cell}())
end

function north(c::Cell)
    c.north
end

function can_move_north(c::Cell)::Bool
    return north(c) !== nothing
end

function south(c::Cell)
    c.south
end

function can_move_south(c::Cell)::Bool
    return south(c) !== nothing
end

function east(c::Cell)
    c.east
end

function can_move_east(c::Cell)::Bool
    return east(c) !== nothing
end

function west(c::Cell)
    c.west
end

function can_move_west(c::Cell)::Bool
    return west(c) !== nothing
end

function random_neighbour(c::Cell, rng::AbstractRNG)::Cell
    if north(c) === nothing && south(c) === nothing && east(c) === nothing &&
        west(c) === nothing
        return nothing
    end

    neighbour = nothing
    while neighbour === nothing
        side = rand(rng, Int) % 4

        if side == 0
            neighbour = north(c)
        elseif side == 1
            neighbour = south(c)
        elseif side == 2
            neighbour = west(c)
        else
            neighbour = east(c)
        end
    end

    return neighbour
end

function neighbours(c::Cell)::Set{Cell}
    out = Set{Cell}()
    if north(c) !== nothing
        push!(out, north(c))
    end
    if south(c) !== nothing
        push!(out, south(c))
    end
    if west(c) !== nothing
        push!(out, west(c))
    end
    if east(c) !== nothing
        push!(out, east(c))
    end
    return out
end

function link(c::Cell, to::Cell)
    push!(c.links, to)
    push!(to.links, c)
end

function unlink(c::Cell, from::Cell)
    pop!(c.links, from)
    pop!(from.links, c)
end

function linked(c::Cell, to::Cell)::Bool
    to ∈ c.links
end

function linked(c::Cell, ::Nothing)::Bool
    false
end

function Base.show(io::IO, c::Cell)
    print(io, "Cell($(c.row), $(c.col))")
end

rng = MersenneTwister(1)
c = Cell(1, 1)
c2 = Cell(2, 2)
c.north = c2
link(c, c2)
println(c)
println(random_neighbour(c, rng))
println(neighbours(c))