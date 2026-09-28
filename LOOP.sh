#!/usr/bin/env bash
# LOOP.sh — iteruje po liście URL-i i dla każdego uruchamia Claude Code
# z komendą /clone-website <URL>. Treść podstron trafia do content collections
# (Markdown), a na końcu powstaje raport brakujących tłumaczeń.
#
# Użycie:
#   ./LOOP.sh url1 url2 url3           # URL-e z argumentów
#   URLS_FILE=urls.txt ./LOOP.sh       # URL-e z pliku (jeden na linię, # = komentarz)
#   ./LOOP.sh                          # wbudowana lista URLS poniżej

set -uo pipefail

# ---- Konfiguracja ---------------------------------------------------------

# Domyślna lista URL-i do sklonowania.
URLS=()

# Komenda CLI Claude Code. Można nadpisać zmienną środowiskową CLAUDE_BIN.
CLAUDE_BIN="${CLAUDE_BIN:-claude}"

# Model wykonujący klonowanie. Można nadpisać zmienną środowiskową CLAUDE_MODEL.
CLAUDE_MODEL="${CLAUDE_MODEL:-opus}"

# Dodatkowe flagi dla Claude Code.
CLAUDE_FLAGS=(--model "$CLAUDE_MODEL" --dangerously-skip-permissions --chrome)

# Katalog na logi z każdego przebiegu.
LOG_DIR="${LOG_DIR:-./logs/clone-website}"

# ---- Wczytywanie URL-i ----------------------------------------------------

if [[ $# -gt 0 ]]; then
  URLS=("$@")
elif [[ -n "${URLS_FILE:-}" ]]; then
  if [[ ! -f "$URLS_FILE" ]]; then
    echo "Plik z URL-ami nie istnieje: $URLS_FILE" >&2
    exit 1
  fi
  mapfile -t URLS < <(grep -vE '^\s*(#|$)' "$URLS_FILE")
fi

if [[ ${#URLS[@]} -eq 0 ]]; then
  echo "Lista URL-i jest pusta. Podaj URL-e jako argumenty, w URLS_FILE lub w tablicy URLS w LOOP.sh." >&2
  exit 1
fi

# ---- Sprawdzenie zależności -----------------------------------------------

if ! command -v "$CLAUDE_BIN" >/dev/null 2>&1; then
  echo "Nie znaleziono polecenia '$CLAUDE_BIN' w PATH." >&2
  echo "Zainstaluj Claude Code lub ustaw zmienną CLAUDE_BIN." >&2
  exit 1
fi

mkdir -p "$LOG_DIR"

# ---- Pętla ----------------------------------------------------------------

total=${#URLS[@]}
idx=0
failed=()

for url in "${URLS[@]}"; do
  idx=$((idx + 1))
  ts="$(date +%Y%m%d-%H%M%S)"
  slug="$(echo "$url" | sed -E 's#^https?://##; s#/+$##; s#[^a-zA-Z0-9._-]+#_#g')"
  log_file="$LOG_DIR/${ts}_${idx}_${slug}.log"

  echo
  echo "============================================================"
  echo "[$idx/$total] Klonuję: $url"
  echo "Log: $log_file"
  echo "============================================================"

  prompt="/clone-website $url

Dodatkowe wymagania dla tej podstrony:
- Źródłem treści ma być Markdown w content collection Astro, NIE tekst inline'owany w .astro.
  Stosuj sekcję \"Multilingual Sites\" skilla (część \"Prose pages: content collections\").
  Jeśli projekt ma już własną konwencję (np. \`content/\` w katalogu głównym, trasy
  \`src/pages/[locale]/...\`, \`gray-matter\`), trzymaj się jej zamiast poniższych ścieżek.

- STRUKTURA KATALOGÓW (dokument = katalog, język = plik):
  - artykuły / wpisy blogowe         → \`src/content/news/<entry>/<locale>.md\`
  - strony prawne / o nas / polityki → \`src/content/legal/<entry>/<locale>.md\`
  Dobierz kolekcję (\`legal\` vs \`news\`) na podstawie charakteru podstrony.
  \`<entry>\` jest WSPÓLNY dla wszystkich języków, w angielskim kebab-case
  (np. \`privacy-policy\`, \`terms-of-service\`, \`about-us\`).
  Nazwa pliku to sam kod locale + \`.md\` (\`pl.md\`, \`en.md\`, \`de.md\`).
  Jeśli ten dokument ma już katalog z innego przebiegu (inna wersja językowa tej samej
  strony), dopisz plik do istniejącego katalogu zamiast zakładać nowy.

- JĘZYKI: znajdź wszystkie wersje językowe tej podstrony (hreflang, przełącznik języka)
  i dla każdej wersji, którą strona docelowa faktycznie serwuje, pobierz treść 1:1 z jej
  własnego URL-a. NIE tłumacz niczego sam — ani treści, ani title/description.
  Jeśli wersji w danym języku nie ma, nie twórz dla niej pliku. Braki wypisze raport
  \`docs/i18n/MISSING_TRANSLATIONS.md\` (\`node scripts/i18n-missing.mjs\`) po zakończeniu pętli.

- FRONT MATTER (YAML) w każdym pliku .md:
    title:        # tytuł w danym języku, 1:1 ze strony
    description:  # meta description w danym języku, 1:1 ze strony
    locale:       # kod języka, zgodny z nazwą pliku (np. \"pl\")
    path:         # dokładny URL tej wersji językowej na stronie docelowej (np. \"/polityka-prywatnosci\")
    # tylko dla \`news\`:
    publishedAt:  # data ISO
    author:       # opcjonalnie
    coverImage:   # opcjonalnie, ścieżka w /public/images/...
    tags:         # opcjonalnie, lista
  Pole \`translationKey\` NIE jest potrzebne — katalog \`<entry>\` wiąże wersje językowe.

- RENDERING w Astro 7 (bez gray-matter / marked — content collections robią to natywnie):
  - kolekcje w \`src/content.config.ts\` (\`glob()\` z \`astro/loaders\`, schemat \`z\` z \`astro/zod\`);
  - trasy generowane z pola \`path\` (np. \`src/pages/[...path].astro\` z \`getStaticPaths()\`
    i \`render(entry)\` z \`astro:content\`); jeśli projekt ma już taką trasę, dostosuj się do niej;
  - title, meta description i nagłówki z front mattera.

- TREŚĆ: tekst do .md pobierz 1:1 z URL-a źródłowego (zgodnie z regułami /clone-website),
  zachowując strukturę nagłówków, list i akapitów w czystym Markdownie (bez HTML, jeśli nie jest konieczny)."

  if "$CLAUDE_BIN" "${CLAUDE_FLAGS[@]}" "$prompt" 2>&1 | tee "$log_file"; then
    echo "[$idx/$total] OK: $url"
  else
    code=$?
    echo "[$idx/$total] BŁĄD ($code): $url" >&2
    failed+=("$url")
  fi
done

# ---- Raport brakujących tłumaczeń -----------------------------------------

echo
echo "============================================================"
node scripts/i18n-missing.mjs || echo "Nie udało się wygenerować raportu brakujących tłumaczeń." >&2

echo "Zakończono. Przetworzone: $total, błędy: ${#failed[@]}"
if [[ ${#failed[@]} -gt 0 ]]; then
  echo "URL-e z błędami:"
  printf '  - %s\n' "${failed[@]}"
  exit 1
fi
