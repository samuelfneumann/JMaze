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
            neighbourCell = neighbours[index]
            link(cell, neighbourCell)
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
    currentCell = g[r, c]

    push!(s, currentCell)

    while length(s) > 0
        # Choose a random unvisited neighbour
        neighboursCells::Vector{Cell} = []
        currentCell = pop!(s)
        for cell in neighbours(currentCell)
            if cell === nothing
                continue
            end

            if !(cell in visited)
                push!(neighboursCells, cell)
            end
        end

        if length(neighboursCells) > 0
            push!(s, currentCell)
            index = abs(rand(rng, Int) % length(neighboursCells)) + 1
            neighbourCell = neighboursCells[index]
            link(neighbourCell, currentCell)
            push!(visited, neighbourCell)
            push!(s, neighbourCell)
        end
    end
end

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

g = Grid(10, 10)
rng = Random.MersenneTwister(1)
iterative!(g, rng)
println(g)
println(g[1, 2])
println(g[1, 1].links)
println(g[1, 2].links)
println(g[1, 3].links)
println(g[2, 3].links)
