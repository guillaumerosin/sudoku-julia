# =============================================================================
# GRILLE À COMPLÉTER — Modifie la matrice ci-dessous (0 = case vide, 1-9 = chiffre donné)
# =============================================================================

ma_grille = [
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

# =============================================================================

include("sudoku-julia.jl")

function affiche_grille_jeu(grille::AbstractMatrix{Int}, grille_init::AbstractMatrix{Int}; titre = "Sudoku")
    println(titre)
    println(repeat("─", 29))
    for i in 1:9
        row = ""
        for j in 1:9
            v = grille[i, j]
            s = (v == 0 ? "." : string(v))
            # Chiffres de départ entre parenthèses
            if grille_init[i, j] != 0
                s = "(" * s * ")"
            else
                s = " " * s * " "
            end
            row *= s
            if j in (3, 6)
                row *= "│"
            end
        end
        println(row)
        if i in (3, 6)
            println("─────────────┼─────────────┼─────────────")
        end
    end
    println()
    println("(n) = chiffre de départ (non modifiable)")
end

function est_valide(grille::AbstractMatrix{Int}, i::Int, j::Int, n::Int)::Bool
    # Ligne
    for c in 1:9
        (c != j && grille[i, c] == n) && return false
    end
    # Colonne
    for r in 1:9
        (r != i && grille[r, j] == n) && return false
    end
    # Bloc 3×3
    r0 = 3 * div(i - 1, 3) + 1
    c0 = 3 * div(j - 1, 3) + 1
    for r in r0:(r0+2)
        for c in c0:(c0+2)
            (r != i || c != j) && grille[r, c] == n && return false
        end
    end
    return true
end

function grille_complete(grille::AbstractMatrix{Int})::Bool
    for i in 1:9, j in 1:9
        grille[i, j] == 0 && return false
    end
    return true
end

function jouer()
    grille = copy(ma_grille)
    grille_init = copy(ma_grille)

    println()
    println("  Commandes:")
    println("    ligne colonne chiffre  → placer un chiffre (ex: 1 2 5)")
    println("    e ligne colonne       → effacer une case (ex: e 1 2)")
    println("    s ou solution          → afficher la solution")
    println("    q ou quitter           → quitter")
    println()

    while true
        affiche_grille_jeu(grille, grille_init)
        if grille_complete(grille)
            # Vérifier que tout est valide
            ok = true
            for i in 1:9, j in 1:9
                if !est_valide(grille, i, j, grille[i, j])
                    ok = false
                    break
                end
            end
            if ok
                println("🎉 Félicitations, grille correcte !")
                break
            end
        end

        print("> ")
        line = readline()
        isempty(strip(line)) && continue
        parts = split(strip(line))

        if lowercase(parts[1]) in ("q", "quitter")
            println("Au revoir.")
            break
        end

        if lowercase(parts[1]) in ("s", "solution")
            try
                sol = solve_sudoku(grille_init)
                println("\n--- Solution ---")
                affiche_grille(sol; titre = "")
                println()
            catch e
                println("Erreur: ", e)
            end
            continue
        end

        if lowercase(parts[1]) == "e"
            if length(parts) != 3
                println("Usage: e ligne colonne")
                continue
            end
            i = tryparse(Int, parts[2])
            j = tryparse(Int, parts[3])
            if i === nothing || j === nothing || i < 1 || i > 9 || j < 1 || j > 9
                println("Ligne et colonne doivent être entre 1 et 9.")
                continue
            end
            if grille_init[i, j] != 0
                println("Case de départ, on ne peut pas l'effacer.")
                continue
            end
            grille[i, j] = 0
            println("Case ($i,$j) effacée.")
            continue
        end

        if length(parts) != 3
            println("Usage: ligne colonne chiffre (ex: 2 3 7)")
            continue
        end
        i = tryparse(Int, parts[1])
        j = tryparse(Int, parts[2])
        n = tryparse(Int, parts[3])
        if i === nothing || j === nothing || n === nothing
            println("Entrez trois nombres (ligne, colonne, chiffre).")
            continue
        end
        if i < 1 || i > 9 || j < 1 || j > 9
            println("Ligne et colonne entre 1 et 9.")
            continue
        end
        if n < 1 || n > 9
            println("Chiffre entre 1 et 9.")
            continue
        end
        if grille_init[i, j] != 0
            println("Case de départ, tu ne peux pas la modifier.")
            continue
        end
        if !est_valide(grille, i, j, n)
            println("Ce chiffre n'est pas valide ici (déjà en ligne, colonne ou bloc).")
            continue
        end
        grille[i, j] = n
        println("($i,$j) = $n")
    end
end

jouer()
