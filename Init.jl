using Random

include("Grid.jl")

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


g = Grid(10, 10)
rng = Random.MersenneTwister(1)
wilson!(g, rng)
println(g)
println(g[1, 2])
println(g[1, 1].links)
println(g[1, 2].links)
println(g[1, 3].links)
println(g[2, 3].links)
