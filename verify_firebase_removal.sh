#!/bin/bash

echo "🔍 VERIFICACIÓN DE ELIMINACIÓN DE FIREBASE"
echo "=========================================="

# Verificar archivos Swift
echo "📁 Buscando referencias a Firebase en archivos Swift..."
FIREBASE_REFS=$(grep -r "Firebase" /workspaces/worldbrainapppppp/worldbrainapp/worldbrain --include="*.swift" 2>/dev/null | wc -l)

if [ $FIREBASE_REFS -eq 0 ]; then
    echo "✅ No se encontraron referencias a Firebase en archivos Swift"
else
    echo "❌ Se encontraron $FIREBASE_REFS referencias a Firebase:"
    grep -r "Firebase" /workspaces/worldbrainapppppp/worldbrainapp/worldbrain --include="*.swift" 2>/dev/null
fi

echo ""

# Verificar archivos de configuración
echo "📁 Buscando archivos de configuración de Firebase..."
GOOGLE_SERVICE_FILES=$(find /workspaces/worldbrainapppppp -name "GoogleService-Info.plist" 2>/dev/null | wc -l)

if [ $GOOGLE_SERVICE_FILES -eq 0 ]; then
    echo "✅ No se encontraron archivos GoogleService-Info.plist"
else
    echo "❌ Se encontraron archivos GoogleService-Info.plist:"
    find /workspaces/worldbrainapppppp -name "GoogleService-Info.plist" 2>/dev/null
fi

echo ""

# Verificar proyecto Xcode
echo "📁 Verificando proyecto Xcode..."
XCODE_FIREBASE_REFS=$(grep -c "Firebase" /workspaces/worldbrainapppppp/worldbrainapp.xcodeproj/project.pbxproj 2>/dev/null || echo "0")

if [ $XCODE_FIREBASE_REFS -eq 0 ]; then
    echo "✅ No se encontraron referencias a Firebase en project.pbxproj"
else
    echo "❌ Se encontraron $XCODE_FIREBASE_REFS referencias a Firebase en project.pbxproj"
fi

echo ""

# Verificar archivos de backend
echo "📁 Verificando archivos de backend..."
if [ -f "/workspaces/worldbrainapppppp/worldbrainapp/worldbrain/Components/AppwriteBackend.swift" ]; then
    echo "✅ AppwriteBackend.swift existe"
else
    echo "❌ AppwriteBackend.swift no encontrado"
fi

if [ -f "/workspaces/worldbrainapppppp/worldbrainapp/worldbrain/Components/FirebaseBackend.swift" ]; then
    echo "❌ FirebaseBackend.swift aún existe"
else
    echo "✅ FirebaseBackend.swift eliminado correctamente"
fi

echo ""

# Resumen final
echo "📊 RESUMEN DE VERIFICACIÓN"
echo "========================"

TOTAL_ISSUES=0

if [ $FIREBASE_REFS -gt 0 ]; then
    echo "❌ Referencias a Firebase en código: $FIREBASE_REFS"
    TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
fi

if [ $GOOGLE_SERVICE_FILES -gt 0 ]; then
    echo "❌ Archivos de configuración de Firebase: $GOOGLE_SERVICE_FILES"
    TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
fi

if [ $XCODE_FIREBASE_REFS -gt 0 ]; then
    echo "❌ Referencias en proyecto Xcode: $XCODE_FIREBASE_REFS"
    TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
fi

if [ $TOTAL_ISSUES -eq 0 ]; then
    echo ""
    echo "🎉 VERIFICACIÓN EXITOSA"
    echo "✅ Firebase ha sido eliminado completamente"
    echo "✅ Solo Appwrite permanece como backend"
    echo "✅ Proyecto listo para usar exclusivamente Appwrite"
else
    echo ""
    echo "⚠️  VERIFICACIÓN CON PROBLEMAS"
    echo "❌ Se encontraron $TOTAL_ISSUES problemas que necesitan atención"
fi

echo ""
echo "🔗 Archivos principales de Appwrite:"
echo "   - AppwriteBackend.swift"
echo "   - AppwriteConfig.plist"
echo "   - UnifiedAuthManager.swift (simplificado)"
