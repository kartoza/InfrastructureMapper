" SPDX-FileCopyrightText: Tim Sutton
" SPDX-License-Identifier: MIT
"
" Project-specific Neovim WhichKey bindings for InfrastructureMapper.
" All schema-lifecycle operations live under <leader>p (for "project").
"
" Sourced automatically when Neovim is launched from the repo root and
" 'exrc' is enabled in your global config (set exrc / vim.o.exrc = true).
"
" If you use which-key.nvim, the keymaps below show up automatically in the
" popup once <leader>p is held.

" --- Schema lifecycle ---
nnoremap <silent> <leader>pb :!nix run .#build-gpkg<CR>
nnoremap <silent> <leader>pB :!nix run .#build-gpkg -- --crs EPSG:32735<CR>
nnoremap <silent> <leader>pm :!nix run .#migrate-pg -- gis<CR>
nnoremap <silent> <leader>pg :!nix run .#migrate-gpkg -- gpkg/KartozaInfrastructureMapper.gpkg<CR>
nnoremap <silent> <leader>pd :!nix run .#docs<CR>
nnoremap          <leader>pr :!nix run .#release -- --bump patch --commit<CR>

" --- QA / formatting ---
nnoremap <silent> <leader>pl :!nix develop --command sqlfluff lint sql/<CR>
nnoremap <silent> <leader>pf :!nix develop --command sqlfluff fix sql/<CR>
nnoremap <silent> <leader>pk :!nix develop --command black --check --diff .<CR>
nnoremap <silent> <leader>pK :!nix develop --command black .<CR>
nnoremap <silent> <leader>pi :!nix develop --command markdownlint '**/*.md'<CR>

" --- Navigation to canonical docs ---
nnoremap <silent> <leader>ps :edit SPECIFICATION.md<CR>
nnoremap <silent> <leader>pR :edit README.md<CR>
nnoremap <silent> <leader>pv :edit VERSION<CR>
nnoremap <silent> <leader>pu :edit sql/migrations/pg/UNRELEASED.sql<CR>
nnoremap <silent> <leader>pU :edit sql/migrations/gpkg/UNRELEASED.sql<CR>

" --- Postgres lifecycle ---
nnoremap <silent> <leader>p1 :!./start_pg.sh<CR>
nnoremap <silent> <leader>p0 :!./stop_pg.sh<CR>

" --- WhichKey descriptions (recognised by which-key.nvim) ---
if exists('g:loaded_which_key') || exists('g:which_key_map')
  let g:which_key_map = get(g:, 'which_key_map', {})
  let g:which_key_map.p = {
    \ 'name': '+project',
    \ 'b': 'build GPKG (4326 default)',
    \ 'B': 'build GPKG (UTM 35S)',
    \ 'm': 'migrate PG (gis)',
    \ 'g': 'migrate GPKG',
    \ 'd': 'regenerate Schema Reference docs',
    \ 'r': 'release (patch bump + commit)',
    \ 'l': 'sqlfluff lint',
    \ 'f': 'sqlfluff fix',
    \ 'k': 'black --check',
    \ 'K': 'black (apply)',
    \ 'i': 'markdownlint',
    \ 's': 'open SPECIFICATION.md',
    \ 'R': 'open README.md',
    \ 'v': 'open VERSION',
    \ 'u': 'edit PG UNRELEASED.sql',
    \ 'U': 'edit GPKG UNRELEASED.sql',
    \ '1': 'start PostgreSQL',
    \ '0': 'stop PostgreSQL',
    \ }
endif
