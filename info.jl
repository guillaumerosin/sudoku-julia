struct Grid{T}
    data::Matrix{T}
end

function create_grid()
    blocks = [Grid{BitVector}(reshape([trues(9) for _ in 1:9], 3, 3)) for _ in 1:9]
    return Grid{Grid{BitVector}}(reshape(blocks, 3, 3))
end

function set!(sudoku::Grid{Grid{BitVector}}, row::Int, column::Int, value::Int)
    areaRow = (row - 1) ÷ 3 + 1
    areaCol = (column - 1) ÷ 3 + 1
    cellRow = (row - 1) % 3 + 1
    cellCol = (column - 1) % 3 + 1

    for i in 1:3, j in 1:3
        sudoku.data[areaRow, areaCol].data[i, j][value] = false
    end

    for c in 1:9
        ar, ac = (row - 1) ÷ 3 + 1, (c - 1) ÷ 3 + 1
        cr, cc = (row - 1) % 3 + 1, (c - 1) % 3 + 1
        sudoku.data[ar, ac].data[cr, cc][value] = false
    end

    for r in 1:9
        ar, ac = (r - 1) ÷ 3 + 1, (column - 1) ÷ 3 + 1
        cr, cc = (r - 1) % 3 + 1, (column - 1) % 3 + 1
        sudoku.data[ar, ac].data[cr, cc][value] = false
    end

    for i in 1:9
        sudoku.data[areaRow, areaCol].data[cellRow, cellCol][i] = false
    end
    sudoku.data[areaRow, areaCol].data[cellRow, cellCol][value] = true
end

function print_grid(g::Grid{Grid{BitVector}})
    for row in 1:9
        if row == 1 || row == 4 || row == 7
            println("+-------+-------+-------+")
        end
        for col in 1:9
            if col == 1 || col == 4 || col == 7
                print("| ")
            end
            areaRow = (row - 1) ÷ 3 + 1
            areaCol = (col - 1) ÷ 3 + 1
            cellRow = (row - 1) % 3 + 1
            cellCol = (col - 1) % 3 + 1
            bv = g.data[areaRow, areaCol].data[cellRow, cellCol]
            n = count(bv)
            if n == 1
                print(findfirst(bv), " ")
            else
                print(". ")
            end
        end
        println("|")
        if row == 3 || row == 6 || row == 9
            println("+-------+-------+-------+")
        end
    end
end

sudoku = create_grid()
println("Grille vide :")
print_grid(sudoku)

set!(sudoku, 3, 6, 4)
println("\nAprès set!(sudoku, 3, 6, 4) :")
print_grid(sudoku)

# Case (3,6) : bloc (1,2), cellule (3,2)
areaRow, areaCol = 1, 2
cellRow, cellCol = 3, 2
println("\nCase (3,6) : ", sudoku.data[areaRow, areaCol].data[cellRow, cellCol])