struct Grid{T}
    data::Matrix{T}
end

function create_grid()
    blocks = [Grid{BitVector}(reshape([trues(9) for _ in 1:9], 3, 3)) for _ in 1:9]
    return Grid{Grid{BitVector}}(reshape(blocks, 3, 3))
end


sudoku = createSudoku()
set!(sudoku::Grid{Grid{BitVector}}, row::Int, column::Int, value::Int, value::Int)
    areaRow, areaCol = div ent 3
    cellRow, cellCol = ((row-1) % 3)+1, ((column-1) % 3)+1

    for i in 1:3, j in 1:3
        sudoku.data[areaRow, areaCol].data[i, j][value] = false
        sudoku.data[i, areaCol].data[j, cellCol][value] = false
        sudoku.data[areaRow, i].data[cellRow, j][value] = false
    end
    
   
    for i in 1:9
        sudoku.data[areaRow, areaCol].data[cellRow, cellCol][i] = false
    end
    sudoku.data[areaRow, areaCol].data[cellRow, cellCol][value] = true
    
end

sudoku = createSudoku()
set!(sudoku, 3,6,4)
println(sudoku.data[3,6].data[2,3])



