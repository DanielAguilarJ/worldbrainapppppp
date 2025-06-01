#!/bin/bash

echo "🔥 Limpiando referencias a Firebase del proyecto Xcode..."

PROJECT_FILE="/workspaces/worldbrainapppppp/worldbrainapp.xcodeproj/project.pbxproj"

# Hacer backup del archivo original
cp "$PROJECT_FILE" "$PROJECT_FILE.backup"
echo "✅ Backup creado: $PROJECT_FILE.backup"

# Remover líneas que contengan Firebase
sed -i '/Firebase/d' "$PROJECT_FILE"

echo "✅ Referencias a Firebase eliminadas del proyecto Xcode"

# Mostrar cuántas líneas fueron eliminadas
ORIGINAL_LINES=$(wc -l < "$PROJECT_FILE.backup")
NEW_LINES=$(wc -l < "$PROJECT_FILE")
REMOVED_LINES=$((ORIGINAL_LINES - NEW_LINES))

echo "📊 Líneas originales: $ORIGINAL_LINES"
echo "📊 Líneas actuales: $NEW_LINES"
echo "📊 Líneas eliminadas: $REMOVED_LINES"

echo "🎉 Limpieza de Firebase completada"
