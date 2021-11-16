using Random
using DataStructures

include("Grid.jl")

@enum BiasDirection NW=1 NE=2 SW=3 SE=4

"""
    wilson!(g::Grid, rng::AbstractRNG)

Initializes a maze with Wilson's algorithm
"""
function wilson!(g::Grid, rng::AbstractRNG)
    free = reshape(copy(g.cells), length(g))

    index = abs(rand(rng, Int)) % length(g) + 1
    deleteat!(free, index)

    while length(free) > 0
        path = wilson_walk(free, rng)

        prev = nothing
        for cell ∈ path
            if prev !== nothing
                prevIndex = findfirst(x->x==prev, free)
                link(prev, cell)
                deleteat!(free, prevIndex)
            end
            prev = cell
        end
    end
end

"""
    wilson_walk(free::Vector{Cell}, rng::AbstractRNG)::Vector{Cell}

Takes a random walk to generate paths for Wilson's algorithm.
"""
function wilson_walk(free::Vector{Cell}, rng::AbstractRNG)::Vector{Cell}
    index = abs(rand(rng, Int)) % length(free) + 1
    cell = free[index]

    path::Vector{Cell} = []
    push!(path, cell)

    while cell ∈ free
        neighbour = random_neighbour(cell, rng)
        # println(neighbour, length(free))

        exists = neighbour ∈ path
        at = findfirst(x->x==neighbour, path)
        if exists && at != length(path)
            path = path[begin:at[1]]
        else
            push!(path, neighbour)
        end

        cell = neighbour
    end

    path
end

"""
    binarytree!(g::Grid, rng::AbstractRNG, b::BiasDirection=NW)

Initialize a grid with the binary tree maze initialization algorithm
"""
function binarytree!(g::Grid, rng::AbstractRNG, b::BiasDirection=NW)
    f1, f2 = bias(b)

    for r = 1:g.rows, c = 1:g.cols
        cell = g[r, c]
        neighbours::Vector{Cell} = []

        if f1(cell) !== nothing
            push!(neighbours, f1(cell))
        end
        if f2(cell) !== nothing
            push!(neighbours, f2(cell))
        end

        if length(neighbours) > 0
            index = abs((rand(rng, Int) % length(neighbours))) + 1
            neighbour_cell = neighbours[index]
            link(cell, neighbour_cell)
        end
    end
end

"""
    iterative!(g::Grid, rng::AbstractRNG)

Initialize a grid with the iterative maze initialization algorithm
"""
function iterative!(g::Grid, rng::AbstractRNG)
    s = Stack{Cell}()
    visited = Set{Cell}()

    # Choose a random starting cell
    r = abs(rand(rng, Int) % length(g.rows)) + 1
    c = abs(rand(rng, Int) % length(g.cols)) + 1
    current_cell = g[r, c]

    push!(s, current_cell)

    while length(s) > 0
        # Choose a random unvisited neighbour
        neighbour_cells::Vector{Cell} = []
        current_cell = pop!(s)
        for cell in neighbours(current_cell)
            if cell === nothing
                continue
            end

            if !(cell in visited)
                push!(neighbour_cells, cell)
            end
        end

        if length(neighbour_cells) > 0
            push!(s, current_cell)
            index = abs(rand(rng, Int) % length(neighbour_cells)) + 1
            neighbour_cell = neighbour_cells[index]
            link(neighbour_cell, current_cell)
            push!(visited, neighbour_cell)
            push!(s, neighbour_cell)
        end
    end
end

"""
    aldousbroder!(g::Grid, rng::AbstractRNG)

Initiailzes a maze with the Aldous-Broder algorithm
"""
function aldousbroder!(g::Grid, rng::AbstractRNG)
    visited = Set{Cell}()

    # Choose a random starting cell
    r = abs(rand(rng, Int)) % length(g.rows) + 1
    c = abs(rand(rng, Int)) % length(g.rows) + 1
    current_cell = g[r, c]

    push!(visited, current_cell)

    while length(visited) < length(g)
        neighbour_cell = random_neighbour(current_cell, rng)

        if neighbour_cell ∉ visited
            link(current_cell, neighbour_cell)
            push!(visited, neighbour_cell)
        end
        current_cell = neighbour_cell
    end
end

"""
    backtracking!(g::Grid, rng::AbstractRNG)

Initiailzes a maze with the recursive backtracking algorithm
"""
function backtracking!(g::Grid, rng::AbstractRNG)
    s = Stack{Cell}()
    visited = Set{Cell}()

    # Choose a random starting cell
    r = abs(rand(rng, Int)) % length(g.rows) + 1
    c = abs(rand(rng, Int)) % length(g.cols) + 1
    current_cell = g[r, c]

    push!(s, current_cell)

    while length(s) > 0
        neighbour_cells::Vector{Cell} = []
        for cell ∈ neighbours(current_cell)
            if cell === nothing
                continue
            end

            if cell ∉ visited
                push!(neighbour_cells, cell)
            end
        end

        if length(neighbour_cells) == 0
            # If all neighbours have been visited, we are done with this
            # cell and we backtrack to a previous cell
            current_cell = pop!(s)
        else
            # An univisted neighbour was found, move to that cell and mark
            # it as the current cell
            index = abs(rand(rng, Int)) % length(neighbour_cells) + 1
            neighbour_cell = neighbour_cells[index]
            link(neighbour_cell, current_cell)
            push!(visited, neighbour_cell)
            push!(s, neighbour_cell)
            current_cell = neighbour_cell
        end
    end
end

"""
    bias(b::BiasDirection)

Returns two functions indicating the biases to use for the binary
tree maze initialization algorithm.
"""
function bias(b::BiasDirection)
    if b == NW
        return north, west
    elseif b == NE
        return north, east
    elseif b == SW
        return south, west
    else
        return south, east
    end
end
