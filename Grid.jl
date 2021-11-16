using Random

include("Cell.jl")

mutable struct Grid
    rows::Int
    cols::Int
    cells::Matrix{Cell}
end

function Grid(rows::Integer, cols::Integer)::Grid
    cells = Matrix{Cell}(undef, rows, cols)

    g = Grid(rows, cols, cells)

    # Create the grid
    for r = 1:rows
        for c = 1:cols
            cells[r, c] = Cell(r, c)
        end
    end

    # Set neighbouring cells
    for r = 1:rows, c = 1:cols
        cell = cells[r, c]

        if 1 < r <= rows
            cell.north = cells[r-1, c]
        end
        if 0 < r < rows
            cell.south = cells[r+1, c]
        end
        if 1 < c <= cols
            cell.west = cells[r, c-1]
        end
        if 0 < c < cols
            cell.east = cells[r, c+1]
        end
    end

    g.cells = cells
    g
end

function Base.length(g::Grid)::Int
    g.rows * g.cols
end

function Base.getindex(g::Grid, i::Int)::Cell
    g.cells[i]
end

function Base.getindex(g::Grid, i::Vararg{Int, 2})::Cell
    g.cells[i...]
end

function Base.firstindex(::Grid)::Tuple{Int, Int}
    (1, 1)
end

function Base.lastindex(g::Grid)::Tuple{Int, Int}
    (g.rows, g.cols)
end

function Base.show(io::IO, g::Grid)
    print(io, "+")

    for _ = 1:g.cols
        print(io, "---+")
    end
    print(io, "\n")

    for r = 1:g.rows
        top = "|"
        bottom = "+"
        for c = 1:g.cols
            body = "   "
            cell = g.cells[r, c]

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

