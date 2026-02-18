# Sudoku as a custom Grid: 3×3 matrix of blocks, each block is a Grid of 3×3 cells.
# So Sudoku = Grid{Grid{Int}} with 81 cells total.

using Random

"""
    mutable struct Grid{T}
        data::Matrix{T}   # 3×3 matrix
    end
"""
mutable struct Grid{T}
    data::Matrix{T}
end

# Constructor: 3×3 matrix
Grid{T}(::UndefInitializer) where T = Grid{T}(Matrix{T}(undef, 3, 3))
Grid(data::AbstractMatrix) = Grid{eltype(data)}(Matrix(data))

# Full Sudoku type: 3×3 grid of 3×3 blocks (each block is Grid{Int})
const SudokuGrid = Grid{Grid{Int}}

# Build an empty Sudoku (9 blocks, each 3×3 of zeros)
function empty_sudoku()
    blocks = Matrix{Grid{Int}}(undef, 3, 3)
    for i in 1:3, j in 1:3
        blocks[i, j] = Grid{Int}(zeros(Int, 3, 3))
    end
    return Grid{Grid{Int}}(blocks)
end

# Global row,col (1-9) -> block indices (1-3) and cell indices (1-3)
block_and_cell(row, col) = ((row - 1) ÷ 3 + 1, (col - 1) ÷ 3 + 1), ((row - 1) % 3 + 1, (col - 1) % 3 + 1)

function get_cell(s::SudokuGrid, row::Int, col::Int)
    (bi, bj), (ci, cj) = block_and_cell(row, col)
    return s.data[bi, bj].data[ci, cj]
end

function set_cell!(s::SudokuGrid, row::Int, col::Int, val::Int)
    (bi, bj), (ci, cj) = block_and_cell(row, col)
    s.data[bi, bj].data[ci, cj] = val
end

# Copy a 9×9 matrix into the Sudoku Grid structure
function sudoku_from_matrix(M::AbstractMatrix{Int})
    @assert size(M) == (9, 9)
    s = empty_sudoku()
    for i in 1:9, j in 1:9
        set_cell!(s, i, j, M[i, j])
    end
    return s
end

# Sample Sudoku (facile) - source style: https://sudoku.com/fr/facile/
const SAMPLE_MATRIX = [
    5 3 0 0 7 0 0 0 0;
    6 0 0 1 9 5 0 0 0;
    0 9 8 0 0 0 0 6 0;
    8 0 0 0 6 0 0 0 3;
    4 0 0 8 0 3 0 0 1;
    7 0 0 0 2 0 0 0 6;
    0 6 0 0 0 0 2 8 0;
    0 0 0 4 1 9 0 0 5;
    0 0 0 0 8 0 0 7 9
]

function sample_sudoku()
    return sudoku_from_matrix(SAMPLE_MATRIX)
end

function print_sudoku(s::SudokuGrid)
    for i in 1:9
        if i == 1 || i == 4 || i == 7
            println("+-------+-------+-------+")
        end
        for j in 1:9
            if j == 1 || j == 4 || j == 7
                print("| ")
            end
            val = get_cell(s, i, j)
            if val == 0
                print(". ")
            else
                print("$(val) ")
            end
        end
        println("|")
    end
    println("+-------+-------+-------+")
end

# Check if placing num at (row, col) is valid
function is_valid(s::SudokuGrid, row::Int, col::Int, num::Int)
    # Row
    for j in 1:9
        get_cell(s, row, j) == num && return false
    end
    # Column
    for i in 1:9
        get_cell(s, i, col) == num && return false
    end
    # Block (already encoded in Grid structure)
    (bi, bj), _ = block_and_cell(row, col)
    block = s.data[bi, bj]
    for ci in 1:3, cj in 1:3
        block.data[ci, cj] == num && return false
    end
    return true
end

function find_empty(s::SudokuGrid)
    for i in 1:9, j in 1:9
        get_cell(s, i, j) == 0 && return i, j
    end
    return 0, 0
end

function is_complete(s::SudokuGrid)
    for i in 1:9, j in 1:9
        get_cell(s, i, j) == 0 && return false
    end
    return true
end

function solve_sudoku!(s::SudokuGrid)
    row, col = find_empty(s)
    row == 0 && return true
    for num in shuffle(1:9)
        if is_valid(s, row, col, num)
            set_cell!(s, row, col, num)
            if solve_sudoku!(s)
                return true
            end
            set_cell!(s, row, col, 0)
        end
    end
    return false
end

# Jouer au Sudoku dans le terminal : on tape "ligne colonne valeur" à chaque coup
function play_sudoku(initial::SudokuGrid)
    s = empty_sudoku()
    for i in 1:9, j in 1:9
        set_cell!(s, i, j, get_cell(initial, i, j))
    end
    fixed = [get_cell(initial, i, j) != 0 for i in 1:9, j in 1:9]

    while true
        println()
        print_sudoku(s)
        if is_complete(s)
            println("Félicitations, vous avez complété le Sudoku !")
            break
        end
        println("Coup : tapez 'ligne colonne valeur' (ex: 1 3 9),")
        println("       'ligne colonne 0' pour effacer, '0 0 0' pour quitter.")
        print("> ")
        line = readline()
        parts = split(line)
        if length(parts) != 3
            println("Format invalide. Exemple : 2 5 7")
            continue
        end
        row = try parse(Int, parts[1]) catch; 0 end
        col = try parse(Int, parts[2]) catch; 0 end
        val = try parse(Int, parts[3]) catch; 0 end
        if row == 0 && col == 0 && val == 0
            println("Fin de partie.")
            break
        end
        if !(1 <= row <= 9 && 1 <= col <= 9 && 0 <= val <= 9)
            println("Ligne et colonne : 1 à 9. Valeur : 0 (effacer) ou 1 à 9.")
            continue
        end
        if fixed[row, col]
            println("Case pré-remplie, vous ne pouvez pas la modifier.")
            continue
        end
        if val == 0
            set_cell!(s, row, col, 0)
            continue
        end
        if is_valid(s, row, col, val)
            set_cell!(s, row, col, val)
        else
            println("Coup invalide (règles du Sudoku).")
        end
    end
end

# Parse user input: 9 lines of 9 digits (0 for empty), space or comma separated
function read_sudoku_from_input()
    println("Entrez 9 lignes de 9 chiffres (0 = vide), séparés par des espaces.")
    M = zeros(Int, 9, 9)
    for i in 1:9
        line = readline()
        parts = split(replace(line, ',' => ' '))
        nums = [parse(Int, x) for x in parts]
        @assert length(nums) == 9 "Ligne $i : il faut 9 chiffres."
        for j in 1:9
            M[i, j] = nums[j]
        end
    end
    return sudoku_from_matrix(M)
end

function main()
    println("=== Sudoku (Grid 3×3 de blocs 3×3) ===\n")
    println("1) Résoudre la grille d'exemple")
    println("2) Résoudre ma grille (saisir 9 lignes × 9 chiffres, 0 = vide)")
    println("3) Jouer avec la grille d'exemple (dans le terminal)")
    println("4) Jouer avec ma grille")
    print("Choix (1/2/3/4) : ")
    choice = strip(readline())

    if choice == "1"
        sudoku = sample_sudoku()
        println("\nGrille d'exemple :")
        print_sudoku(sudoku)
        println("\nRésolution en cours...")
        if solve_sudoku!(sudoku)
            println("Solution :")
            print_sudoku(sudoku)
        else
            println("Aucune solution trouvée.")
        end
    elseif choice == "2"
        sudoku = read_sudoku_from_input()
        println("\nVotre grille :")
        print_sudoku(sudoku)
        println("\nRésolution en cours...")
        if solve_sudoku!(sudoku)
            println("Solution :")
            print_sudoku(sudoku)
        else
            println("Aucune solution trouvée.")
        end
    elseif choice == "3"
        sudoku = sample_sudoku()
        println("\nJouez ! Ligne et colonne de 1 à 9 (1 = en haut à gauche).")
        play_sudoku(sudoku)
    elseif choice == "4"
        sudoku = read_sudoku_from_input()
        println("\nJouez !")
        play_sudoku(sudoku)
    else
        println("Choix invalide. Relancez et tapez 1, 2, 3 ou 4.")
    end
end

main()
