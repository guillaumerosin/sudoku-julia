using JuMP
import HiGHS

function solve_sudoku(init_sol::AbstractMatrix{Int})
    sudoku = Model(HiGHS.Optimizer)
    set_silent(sudoku)
    @variable(sudoku, x[i = 1:9, j = 1:9, k = 1:9], Bin)
    for i in 1:9
        for j in 1:9
            @constraint(sudoku, sum(x[i, j, k] for k in 1:9) == 1)
        end
    end

    for ind in 1:9
        for k in 1:9
            @constraint(sudoku, sum(x[ind, j, k] for j in 1:9) == 1)
            @constraint(sudoku, sum(x[i, ind, k] for i in 1:9) == 1)
        end
    end

    for i in 1:3:7
        for j in 1:3:7
            for k in 1:9
                @constraint(
                    sudoku,
                    sum(x[r, c, k] for r in i:(i+2), c in j:(j+2)) == 1
                )
            end
        end
    end

    for i in 1:9
        for j in 1:9
            if init_sol[i, j] != 0
                fix(x[i, j, init_sol[i, j]], 1; force = true)
            end
        end
    end

    optimize!(sudoku)

    if !is_solved_and_feasible(sudoku)
        error("Aucune solution trouvée. Statut: ", termination_status(sudoku))
    end

    x_val = value.(x)
    sol = zeros(Int, 9, 9)
    for i in 1:9
        for j in 1:9
            for k in 1:9
                if round(Int, x_val[i, j, k]) == 1
                    sol[i, j] = k
                end
            end
        end
    end
    return sol
end

function affiche_grille(M::AbstractMatrix{Int}; titre = "")
    if !isempty(titre)
        println(titre)
        println(repeat("─", 25))
    end
    for i in 1:9
        row = ""
        for j in 1:9
            v = M[i, j]
            row *= (v == 0 ? "." : string(v)) * " "
            if j in (3, 6)
                row *= "│ "
            end
        end
        println(row)
        if i in (3, 6)
            println("─────────────────────")
        end
    end
end

if isdefined(Main, :PROGRAM_FILE) && !isempty(PROGRAM_FILE) &&
   endswith(basename(PROGRAM_FILE), "sudoku-julia.jl")
    init_sol = [
        5 3 0 0 7 0 0 0 0
        6 0 0 1 9 5 0 0 0
        0 9 8 0 0 0 0 6 0
        8 0 0 0 6 0 0 0 3
        4 0 0 8 0 3 0 0 1
        7 0 0 0 2 0 0 0 6
        0 6 0 0 0 0 2 8 0
        0 0 0 4 1 9 0 0 5
        0 0 0 0 8 0 0 7 9
    ]
    affiche_grille(init_sol; titre = "Grille initiale")
    println()
    sol = solve_sudoku(init_sol)
    affiche_grille(sol; titre = "Solution")
    println()
    println("Matrice solution (9×9):")
    println(sol)
end
