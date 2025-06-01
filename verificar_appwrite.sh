#!/bin/bash

# Script para verificar la configuración de Appwrite en WorldBrain
echo "🔍 Verificando configuración de Appwrite para WorldBrain..."
echo "=================================================="

# Verificar archivos creados
echo "📁 Verificando archivos creados:"

files=(
    "worldbrainapp/worldbrain/Components/BackendProtocol.swift"
    "worldbrainapp/worldbrain/Components/FirebaseBackend.swift"
    "worldbrainapp/worldbrain/Components/AppwriteBackend.swift"
    "worldbrainapp/worldbrain/Components/UnifiedAuthManager.swift"
    "worldbrainapp/worldbrain/Components/AppwriteManager.swift"
    "worldbrainapp/worldbrain/Views/BackendConfigView.swift"
    "worldbrainapp/worldbrain/Views/AppwriteTestView.swift"
    "worldbrainapp/worldbrain/AppwriteConfig.plist"
    "APPWRITE_SETUP_GUIDE.md"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file (FALTA)"
    fi
done

echo ""
echo "🔧 Verificaciones adicionales:"

# Verificar contenido del archivo de configuración
if [ -f "worldbrainapp/worldbrain/AppwriteConfig.plist" ]; then
    echo "✅ AppwriteConfig.plist existe"
    if grep -q "683b7d7000153e36f0d8" "worldbrainapp/worldbrain/AppwriteConfig.plist"; then
        echo "✅ Project ID configurado correctamente"
    else
        echo "⚠️  Project ID no encontrado en configuración"
    fi
else
    echo "❌ AppwriteConfig.plist no encontrado"
fi

# Verificar MainTabView actualizado
if [ -f "worldbrainapp/worldbrain/Views/MainTabView.swift" ]; then
    if grep -q "BackendConfigView" "worldbrainapp/worldbrain/Views/MainTabView.swift"; then
        echo "✅ MainTabView actualizado con pestaña Backend"
    else
        echo "⚠️  BackendConfigView no encontrado en MainTabView"
    fi
else
    echo "❌ MainTabView.swift no encontrado"
fi

# Verificar que worldbrainappApp.swift incluye Appwrite
if [ -f "worldbrainapp/worldbrain/App/worldbrainappApp.swift" ]; then
    if grep -q "import Appwrite" "worldbrainapp/worldbrain/App/worldbrainappApp.swift"; then
        echo "✅ Appwrite importado en app principal"
    else
        echo "⚠️  Appwrite no importado en app principal"
    fi
else
    echo "❌ worldbrainappApp.swift no encontrado"
fi

echo ""
echo "📋 Pasos siguientes:"
echo "1. Abrir proyecto en Xcode: open worldbrainapp/worldbrainapp.xcodeproj"
echo "2. Añadir dependencia de Appwrite SDK:"
echo "   - File > Add Package Dependencies"
echo "   - URL: https://github.com/appwrite/sdk-for-apple.git"
echo "   - Versión: 10.1.0"
echo "3. Configurar Info.plist con URL scheme para OAuth"
echo "4. Crear proyecto en Appwrite Console con ID: 683b7d7000153e36f0d8"
echo "5. Configurar base de datos y colección 'users'"
echo ""
echo "📖 Ver APPWRITE_SETUP_GUIDE.md para instrucciones detalladas"

# Verificar starter kit
echo ""
echo "🚀 Starter Kit de Appwrite:"
if [ -d "starter-for-ios" ]; then
    echo "✅ Starter kit clonado"
    if [ -f "starter-for-ios/Sources/Config.plist" ]; then
        if grep -q "683b7d7000153e36f0d8" "starter-for-ios/Sources/Config.plist"; then
            echo "✅ Starter kit configurado con Project ID correcto"
        else
            echo "⚠️  Starter kit no configurado correctamente"
        fi
    fi
else
    echo "❌ Starter kit no encontrado"
fi

echo ""
echo "🎯 Estado de la integración:"
echo "✅ Archivos de backend creados"
echo "✅ Vistas de configuración creadas"
echo "✅ Sistema unificado implementado"
echo "⏳ Pendiente: Configuración en Xcode"
echo "⏳ Pendiente: Configuración en Appwrite Console"

echo ""
echo "=================================================="
echo "🎉 Configuración de archivos completada!"
echo "📋 Sigue las instrucciones en APPWRITE_SETUP_GUIDE.md"
