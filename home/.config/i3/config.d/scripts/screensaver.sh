#!/usr/bin/env bash
set -uo pipefail

# --- KONFIGURACJA ---
VIDEO="$HOME/Videos/Screensaver/test.mp4"
LOCK_SCRIPT="$HOME/.config/i3/config.d/scripts/lock.sh"
MPV_CONF="$HOME/.config/i3/config.d/scripts/mpv_saver.conf"

# Jeśli nie ma filmu, użyj zwykłej blokady
if [ ! -f "$VIDEO" ]; then
    bash "$LOCK_SCRIPT"
    exit 0
fi

# 1. Wyłącz wygaszanie ekranu i powiadomienia
xset s off -dpms
if command -v dunstctl >/dev/null; then
    dunstctl set-paused true
fi

# 2. Pobierz listę monitorów z i3
mapfile -t MONITORS < <(i3-msg -t get_outputs | jq -r '.[] | select(.active == true) | .name')

pids=()

# 3. Uruchom MPV na każdym monitorze
for mon in "${MONITORS[@]}"; do
    INSTANCE_NAME="saver-$mon"

    # --force-window: tworzy okno natychmiast, nie czekając na załadowanie dekodera wideo
    mpv --name="$INSTANCE_NAME" \
        --force-window=immediate \
        --loop \
        --mute=yes \
        --no-osc \
        --no-osd-bar \
        --cursor-autohide=always \
        --input-conf="$MPV_CONF" \
        --x11-name="$INSTANCE_NAME" \
        "$VIDEO" > /dev/null 2>&1 &
    
    pids+=($!)

    # 4. Pętla retry: Próbuj przenieść okno, aż się uda (max 2 sekundy)
    # To naprawia błąd "No output matched"
    for _ in {1..20}; do
        # Próbujemy przenieść okno. grep sprawdza czy i3 zgłosił sukces.
        if i3-msg "[instance=\"$INSTANCE_NAME\"] move container to output \"$mon\"" 2>&1 | grep -q '"success":true'; then
            # Jeśli się udało przenieść, daj fullscreen i wyjdź z pętli
            i3-msg "[instance=\"$INSTANCE_NAME\"] fullscreen enable" >/dev/null
            break
        fi
        # Jeśli się nie udało (okno jeszcze nie istnieje), czekaj 0.1s i spróbuj ponownie
        sleep 0.1
    done
done

# 5. Czekaj na interakcję użytkownika (zamknięcie jednej z instancji)
wait -n

# 6. Zabij pozostałe procesy
kill "${pids[@]}" 2>/dev/null
wait 2>/dev/null

# --- KONIEC ---
xset s on +dpms
if command -v dunstctl >/dev/null; then
    dunstctl set-paused false
fi

bash "$LOCK_SCRIPT"
