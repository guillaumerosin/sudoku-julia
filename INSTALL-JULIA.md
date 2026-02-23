# Installer Julia sur Debian

Le paquet `julia` n’est pas disponible dans les dépôts par défaut de Debian. Deux options :

## Option 1 : Binaire officiel (recommandé)

1. Télécharger le binaire Linux depuis https://julialang.org/downloads/  
   (choisir "Generic Linux on x86_64", archive .tar.gz)

2. Extraire et installer :
   ```bash
   cd ~/Downloads   # ou le dossier où est le .tar.gz
   mkdir -p julia-install
   tar -zxvf julia-*-linux-x86_64.tar.gz -C julia-install --strip-components=1
   sudo mv julia-install /opt/julia
   ```

3. Ajouter Julia au PATH :
   ```bash
   echo 'export PATH="/opt/julia/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

4. Vérifier :
   ```bash
   julia --version
   ```

## Option 2 : Snap (si snapd est installé)

```bash
sudo snap install julia --classic
```

Ensuite, lancer le script :

```bash
cd ~/prog/sudoku-julia
julia sudoku-julia.jl
```

La première exécution peut prendre du temps (téléchargement des paquets JuMP et HiGHS).
