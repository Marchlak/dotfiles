# Neovim config

Ta konfiguracja ma być łatwa do rozwijania, czytelna w kodzie i odkrywalna bez przekopywania całego repo.
Dokumentacja tutaj jest źródłem prawdy. W samym Neovimie skróty są dodatkowo opisane przez `desc` i grupowane przez `which-key`.

## Struktura

```text
init.lua
lua/core      # bootstrap, opcje, globalne keymapy
lua/plugins   # deklaracje pluginów i plugin-specific keymapy
lua/lang      # cięższe konfiguracje language-specific, np. Java/JDTLS
```

### Zasady utrzymania

- Globalne ustawienia trafiają do `lua/core/options.lua`.
- Globalne skróty trafiają do `lua/core/keymaps.lua`.
- Każdy plugin ma osobny plik w `lua/plugins`.
- Skróty specyficzne dla pluginu trzymamy przy pluginie.
- Złożone integracje językowe trzymamy w `lua/lang`.
- Każdy własny `vim.keymap.set(...)` musi mieć `desc`.
- Każdy moduł pluginu powinien zaczynać się krótkim opisem, po co istnieje.

## Pluginy

### UI i nawigacja

- `catppuccin.nvim`: główny colorscheme.
- `lualine.nvim`: statusline.
- `nvim-tree.lua`: drzewo plików.
- `which-key.nvim`: dyskretne podpowiedzi grup skrótów po wciśnięciu prefixu.
- `harpoon`: szybkie przełączanie się między wybranymi plikami.

### Szukanie i edycja

- `telescope.nvim` + `telescope-ui-select.nvim`: wyszukiwanie plików, grep, bufory, diagnostyka.
- `nvim-cmp` + dodatki: autouzupełnianie z LSP, snippetów, ścieżek i bufora.
- `LuaSnip` + `friendly-snippets`: snippety.
- `nvim-autopairs`: automatyczne domykanie nawiasów i cudzysłowów.
- `nvim-surround`: szybkie operacje na otoczeniach znaków.
- `nvim-comment`: komentowanie.
- `autosave.nvim`: autosave po zmianach i wyjściu z insert mode.

### Kod, LSP i formatowanie

- `mason.nvim`: instalacja toolingu.
- `mason-lspconfig.nvim`: instalacja i podpięcie serwerów LSP.
- `nvim-lspconfig`: konfiguracja LSP i skrótów LSP.
- `none-ls.nvim` + `mason-null-ls.nvim` + `none-ls-extras.nvim`: formatowanie i dodatkowe diagnostyki.
- `nvim-treesitter`: parsowanie składni, highlight, indent i autotag.

### Git i debug

- `gitsigns.nvim`: oznaczenia zmian w buforze.
- `nvim-dap` + `nvim-dap-ui` + `nvim-nio`: debugowanie.
- `vim-dispatch`: uruchamianie komend asynchronicznych.

### Java i Spring

- `nvim-jdtls`: pełna integracja Java.
- `mason-nvim-dap.nvim`: adaptery debuggera dla Java.
- `springboot-nvim`: skróty do uruchamiania i generowania elementów Spring Boot.

## Cheatsheet skrótów

Leader to `Space`.

### Edycja i nawigacja

- `<leader>aa`: zaznacz cały bufor.
- `<leader>o`: wstaw nową linię poniżej bez zostawania w insert mode.
- `<leader><Tab>`: wróć do poprzedniego bufora.
- `<Esc>`: wyczyść highlight wyszukiwania.
- `<Esc><Esc>` w terminalu: wyjdź do normal mode.
- `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>`: przełączanie focusu między oknami.
- `<leader>wv`: podział pionowy.
- `<leader>wh`: podział poziomy.

### Pliki i wyszukiwanie

- `<leader>pv`: przełącz drzewo plików.
- `<leader>ff`: znajdź pliki.
- `<leader>fg`: grep w projekcie.
- `<C-p>`: znajdź pliki z gita.
- `<leader>fb`: lista otwartych buforów.
- `<leader>fr`: wznowienie ostatniego pickera.
- `<leader>fd`: diagnostyka przez Telescope.
- `<leader>fu`: szukaj słowa pod kursorem.

### Diagnostyka i LSP

- `<leader>e`: diagnostyka pod kursorem.
- `<leader>q`: wrzuć diagnostykę do location list.
- `<leader>nb`: następna diagnostyka.
- `<leader>gy`: deklaracja.
- `<leader>gd`: definicja.
- `<leader>gi`: implementacja.
- `<leader>gh`: hover.
- `<leader>ga`: code action.
- `<leader>gr`: references.
- `<leader>rn`: rename symbol.
- `<leader>rc`: formatuj kod.

### Debug

- `<leader>dt`: toggle breakpoint.
- `<leader>ds`: start / continue debug session.
- `<leader>dc`: zamknij UI debuggera.

### Harpoon

- `<leader>as`: dodaj plik do listy.
- `<C-e>`: otwórz menu Harpoona.
- `<C-1>` ... `<C-4>`: skok do zapisanego pliku.
- `<C-n>`: poprzedni plik na liście.
- `<leader>hn`: następny plik na liście.

### Java i Spring

- `<leader>jr`: uruchom Spring Boot.
- `<leader>jc`: wygeneruj klasę.
- `<leader>ji`: wygeneruj interfejs.
- `<leader>je`: wygeneruj enum.
- `<leader>jo`: organize imports.
- `<leader>jv`: extract variable.
- `<leader>jx`: extract constant.
- `<leader>jm`: test nearest method.
- `<leader>jt`: test class.
- `<leader>ju`: odśwież konfigurację JDTLS.

### Inne

- `<leader>bs`: uruchom `browser-sync`.

## Języki i narzędzia

Obecnie konfiguracja jest przygotowana pod:

- `java`
- `kotlin`
- `python`
- `javascript`
- `typescript`
- `lua`
- `json`
- `bash`
- `html`
- `css`
- `sql`

LSP instalowane przez Mason:

- `lua_ls`
- `clangd`
- `html`
- `cssls`
- `tailwindcss`
- `kotlin_language_server`
- `lemminx`
- `jsonls`
- `bashls`
- `pylsp`
- `ts_ls`

Formatowanie i diagnostyka:

- `stylua`
- `prettier`
- `black`
- `isort`
- `eslint_d` jako opcjonalna diagnostyka JS/TS do włączenia później, jeśli będzie potrzebna

SQL:

- `sqls` jest obsługiwany przez konfigurację dla plików `sql` i `mysql`.
- Jeśli binarka `sqls` nie jest dostępna w `PATH`, konfiguracja po prostu nie aktywuje LSP dla SQL.
- Jeśli chcesz używać własnych połączeń bez trzymania sekretów w repo, ustaw zmienną środowiskową `SQLS_CONFIG` wskazującą na lokalny plik YAML dla `sqls`.

## Lokalne zależności

Do pełnego działania `checkhealth` poza samym Masonem potrzebne są jeszcze lokalne narzędzia:

- `python3 -m pip install --user pynvim`
- `npm install -g neovim`
- `npm install -g eslint_d` jeśli chcesz później dodać diagnostykę ESLint poza obecnym formatter setupem
- `go install github.com/sqls-server/sqls@latest`
- `sudo apt install fd-find`

Uwagi:

- Ruby i Perl provider są wyłączone w konfiguracji, bo ten setup ich nie używa.
- Jeśli na Ubuntu dostajesz tylko binarkę `fdfind`, Telescope użyje jej automatycznie.
- `lazy.nvim` ma wyłączone wsparcie `luarocks`, bo obecne pluginy go nie wymagają.
- `LuaSnip` buduje `jsregexp`, żeby nie zgłaszać warningu o brakujących placeholder transformations.

## Jak rozszerzać konfigurację

### Dodać plugin

1. Dodaj nowy plik w `lua/plugins`.
2. Na początku pliku wpisz jednozdaniowy opis pluginu.
3. Trzymaj local keymapy przy pluginie.
4. Jeśli plugin dotyczy konkretnego języka i ma większą konfigurację, wydziel logikę do `lua/lang`.
5. Dopisz plugin do README tylko wtedy, gdy rzeczywiście jest aktywną częścią workflow.

### Dodać skrót

1. Globalny skrót dodaj do `lua/core/keymaps.lua`.
2. Skrót zależny od pluginu trzymaj przy pluginie.
3. Skrót zależny od language servera trzymaj przy `LspAttach` albo w module z `lua/lang`.
4. Każdy skrót musi mieć `desc`, bo to zasila dokumentację w Neovimie.
5. Jeśli pojawia się nowa grupa prefixów, dodaj ją do konfiguracji `which-key`.

### Dodać język

1. Dodaj serwer do listy w `lua/plugins/lsp-config.lua`, jeśli wystarcza standardowe `lspconfig`.
2. Jeśli język wymaga osobnego bootstrapu, utwórz moduł w `lua/lang`.
3. Trzymaj skróty i zachowania specyficzne dla języka w tym module.
4. Zaktualizuj README tylko o realnie dostępne funkcje, nie o plany.
