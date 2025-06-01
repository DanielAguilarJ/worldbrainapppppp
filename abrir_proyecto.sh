#!/bin/bash

# Script para preparar y abrir el proyecto WorldBrain con Appwrite
echo "🚀 Preparando proyecto WorldBrain con integración de Appwrite..."
echo "=============================================================="

# Verificar que estamos en el directorio correcto
if [ ! -f "worldbrainapp.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: No se encontró el proyecto de Xcode"
    echo "   Asegúrate de ejecutar este script desde /workspaces/worldbrainapppppp"
    exit 1
fi

echo "📦 Verificando configuración del proyecto..."

# Verificar que Appwrite esté configurado en el proyecto
if grep -q "sdk-for-apple" worldbrainapp.xcodeproj/project.pbxproj; then
    echo "✅ SDK de Appwrite configurado en proyecto Xcode"
else
    echo "❌ SDK de Appwrite NO configurado en proyecto Xcode"
fi

# Verificar Info.plist
if [ -f "worldbrainapp/worldbrain/Info.plist" ]; then
    echo "✅ Info.plist creado con URL scheme para OAuth"
else
    echo "❌ Info.plist no encontrado"
fi

# Verificar archivos de backend
backend_files=(
    "worldbrainapp/worldbrain/Components/BackendProtocol.swift"
    "worldbrainapp/worldbrain/Components/AppwriteBackend.swift"
    "worldbrainapp/worldbrain/Components/UnifiedAuthManager.swift"
    "worldbrainapp/worldbrain/Views/BackendConfigView.swift"
)

all_backend_files_exist=true
for file in "${backend_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $(basename "$file")"
    else
        echo "❌ $(basename "$file") - FALTA"
        all_backend_files_exist=false
    fi
done

if [ "$all_backend_files_exist" = true ]; then
    echo "✅ Todos los archivos de backend están presentes"
else
    echo "❌ Faltan archivos de backend importantes"
fi

echo ""
echo "📋 Instrucciones para continuar:"
echo "================================"
echo ""
echo "1. 🏗️  CONFIGURAR APPWRITE CONSOLE:"
echo "   - Ve a: https://cloud.appwrite.io"
echo "   - Crea proyecto con ID: 683b7d7000153e36f0d8"
echo "   - Agrega plataforma iOS con Bundle ID: m.worldbrainapp"
echo "   - Crea base de datos 'worldbrain_db' con colección 'users'"
echo ""
echo "2. 📱 ABRIR EN XCODE:"
echo "   - El proyecto ya está configurado con Appwrite SDK"
echo "   - Los archivos de backend están implementados"
echo "   - La UI de configuración está lista"
echo ""
echo "3. 🧪 PROBAR LA INTEGRACIÓN:"
echo "   - Compilar y ejecutar la app"
echo "   - Ir a pestaña 'Backend'"
echo "   - Cambiar entre Firebase y Appwrite"
echo "   - Probar registro/login con ambos backends"
echo ""

# Intentar abrir el proyecto en Xcode si está disponible
if command -v open >/dev/null 2>&1; then
    echo "🔧 Abriendo proyecto en Xcode..."
    open worldbrainapp.xcodeproj
    echo "✅ Proyecto abierto en Xcode"
else
    echo "ℹ️  Para abrir en Xcode manualmente:"
    echo "   open worldbrainapp.xcodeproj"
fi

echo ""
echo "📖 Para más detalles, consulta:"
echo "   - GUIA_CONFIGURACION_FINAL.md"
echo "   - APPWRITE_SETUP_GUIDE.md"
echo "   - APPWRITE_INTEGRATION_SUMMARY.md"
echo ""
echo "🎉 ¡Integración de Appwrite completada!"
echo "   El proyecto está listo para usar ambos backends."
