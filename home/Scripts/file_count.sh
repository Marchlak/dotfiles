#!/bin/bash

DIR=${1:-.}

java_count=$(find "$DIR" -type f -name "*.java" | wc -l)
kt_count=$(find "$DIR" -type f -name "*.kt" | wc -l)
total=$((java_count + kt_count))

echo "Pliki .java: $java_count"
echo "Pliki .kt:   $kt_count"
echo "Razem:       $total"
