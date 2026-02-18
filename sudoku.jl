using Random
using Gtk

function empty_grid()
    return zeros(Int, 9, 9)
end

function example_puzzle()
    grid = empty_grid()

    puzzle = [
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

    grid[:, :] = puzzle
    return grid
end

function print_sudoku(grid)
    for i in 1:9
        if i == 1 || i == 4 || i == 7
            println("+-------+-------+-------+")
        end
        for j in 1:9
            if j == 1 || j == 4 || j == 7
                print("| ")
            end
            val = grid[i, j]
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

function is_valid(grid, row, col, num)
    # Ligne
    for j in 1:9
        if grid[row, j] == num
            return false
        end
    end

    # Colonne
    for i in 1:9
        if grid[i, col] == num
            return false
        end
    end

    # Sous-grille 3x3
    start_row = 3 * ((row - 1) ÷ 3) + 1
    start_col = 3 * ((col - 1) ÷ 3) + 1
    for i in start_row:(start_row + 2)
        for j in start_col:(start_col + 2)
            if grid[i, j] == num
                return false
            end
        end
    end

    return true
end

# Trouve une case vide (0). Retourne (0, 0) s'il n'y en a plus.
function find_empty(grid)
    for i in 1:9
        for j in 1:9
            if grid[i, j] == 0
                return i, j
            end
        end
    end
    return 0, 0
end

# Résout la grille par backtracking (modifie grid sur place)
function solve_sudoku!(grid)
    row, col = find_empty(grid)
    if row == 0
        return true  # plus de cases vides -> solution trouvée
    end

    for num in shuffle(1:9)
        if is_valid(grid, row, col, num)
            grid[row, col] = num
            if solve_sudoku!(grid)
                return true
            end
            grid[row, col] = 0
        end
    end

    return false
end

# Génère une grille complète aléatoire
function generate_full_grid()
    grid = empty_grid()
    solve_sudoku!(grid)
    return grid
end

# Crée un puzzle à partir d'une grille complète en enlevant des cases
function make_puzzle(full_grid; empty_cells=45)
    puzzle = copy(full_grid)
    positions = [(i, j) for i in 1:9 for j in 1:9]
    positions = shuffle(positions)

    count = 0
    for (i, j) in positions
        if count >= empty_cells
            break
        end
        puzzle[i, j] = 0
        count += 1
    end

    return puzzle
end

# Vérifie si la grille est complètement remplie (aucun 0)
function is_complete(grid)
    return all(grid .!= 0)
end

# Boucle de jeu pour que l'utilisateur joue au Sudoku
function play_sudoku(initial_grid)
    grid = copy(initial_grid)
    fixed = initial_grid .!= 0  # cases qu'on ne peut pas modifier

    while true
        println()
        print_sudoku(grid)

        if is_complete(grid)
            println("Félicitations, vous avez complété le Sudoku !")
            break
        end

        println("Entrez un coup : 'ligne colonne valeur' (ex: 1 3 9),")
        println("ou '0 0 0' pour quitter, ou 'ligne colonne 0' pour effacer une case.")
        print("> ")
        input = readline()

        parts = split(input)
        if length(parts) != 3
            println("Format invalide, réessayez.")
            continue
        end

        row = parse(Int, parts[1])
        col = parse(Int, parts[2])
        val = parse(Int, parts[3])

        if row == 0 && col == 0 && val == 0
            println("Fin de la partie.")
            break
        end

        if !(1 <= row <= 9 && 1 <= col <= 9 && 0 <= val <= 9)
            println("Valeurs hors limites (doivent être entre 1 et 9, ou 0).")
            continue
        end

        if fixed[row, col]
            println("Vous ne pouvez pas modifier cette case (pré-remplie).")
            continue
        end

        if val == 0
            grid[row, col] = 0
            continue
        end

        if is_valid(grid, row, col, val)
            grid[row, col] = val
        else
            println("Coup invalide selon les règles du Sudoku.")
        end
    end
end

# Interface graphique simple avec Gtk
function run_gui(initial_grid)
    grid = copy(initial_grid)

    win = GtkWindow("Sudoku", 450, 450)
    grid_widget = GtkGrid()

    buttons = Matrix{GtkButton}(undef, 9, 9)

    function update_button(i, j)
        val = grid[i, j]
        label = val == 0 ? "." : string(val)
        set_gtk_property!(buttons[i, j], :label, label)
    end

    for i in 1:9, j in 1:9
        btn = GtkButton(".")
        buttons[i, j] = btn

        # Placement dans la grille (indices 1-based pour GtkGrid via setindex!)
        grid_widget[i, j] = btn

        # Met l'affichage du bouton en accord avec la grille initiale
        update_button(i, j)

        # Quand on clique : on fait tourner la valeur 0→1→2→...→9→0
        signal_connect(btn, "clicked") do _
            current = grid[i, j]
            new_val = (current + 1) % 10  # 0..9
            grid[i, j] = new_val
            update_button(i, j)
        end
    end

    push!(win, grid_widget)
    showall(win)

    # Lance la boucle principale Gtk (bloque jusqu'à fermeture de la fenêtre)
    Gtk.gtk_main()
end

# Fonction principale
function main()
    println("=== Sudoku en Julia ===")
    println("1) Jouer au Sudoku d'exemple (console)")
    println("2) Générer un Sudoku aléatoire (console)")
    println("3) Interface graphique (Sudoku aléatoire)")
    print("Votre choix (1/2/3) : ")
    choice = readline()

    if choice == "1"
        puzzle = example_puzzle()
        play_sudoku(puzzle)
    elseif choice == "2"
        full = generate_full_grid()
        puzzle = make_puzzle(full; empty_cells=45)
        println("\nUn nouveau Sudoku a été généré :")
        play_sudoku(puzzle)
    elseif choice == "3"
        full = generate_full_grid()
        puzzle = make_puzzle(full; empty_cells=45)
        println("\nInterface graphique en cours de lancement...")
        run_gui(puzzle)
    else
        println("Choix invalide, au revoir.")
    end
end

# Lance le programme si le fichier est exécuté
main()