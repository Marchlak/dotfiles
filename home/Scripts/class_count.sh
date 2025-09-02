#!/bin/bash

# katalog wyjściowy kompilacji IntelliJ lub Gradle
OUT_DIR=${1:-out/production}

if [ ! -d "$OUT_DIR" ]; then
  echo "Nie znaleziono katalogu kompilacji: $OUT_DIR"
  exit 1
fi

class_count=$(find "$OUT_DIR" -type f -name "*.class" | wc -l)
resource_count=$(find "$OUT_DIR" -type f ! -name "*.class" | wc -l)
total=$((class_count + resource_count))

echo "Pliki .class:    $class_count"
echo "Zasoby:          $resource_count"
echo "Razem w buildzie: $total"
