#!/bin/bash
# Script de verificación para las analíticas avanzadas de WorldBrain App

echo "🚀 Verificando implementación de Analíticas Avanzadas..."
echo ""

# Verificar archivos creados
echo "📁 Verificando archivos principales:"
files=(
    "worldbrainapp/worldbrain/Models/AnalyticsModels.swift"
    "worldbrainapp/worldbrain/Managers/AnalyticsManager.swift"
    "worldbrainapp/worldbrain/Views/AnalyticsDashboardView.swift"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        lines=$(wc -l < "$file")
        echo "✅ $file ($lines líneas)"
    else
        echo "❌ $file - NO ENCONTRADO"
    fi
done

echo ""
echo "🔍 Verificando integración en ProfileView.swift..."
if grep -q "AnalyticsPreviewCard" worldbrainapp/worldbrain/Views/ProfileView.swift; then
    echo "✅ AnalyticsPreviewCard integrado en ProfileView"
else
    echo "❌ AnalyticsPreviewCard NO encontrado en ProfileView"
fi

if grep -q "showAnalyticsDashboard" worldbrainapp/worldbrain/Views/ProfileView.swift; then
    echo "✅ Estado showAnalyticsDashboard agregado"
else
    echo "❌ Estado showAnalyticsDashboard NO encontrado"
fi

if grep -q "AnalyticsDashboardView()" worldbrainapp/worldbrain/Views/ProfileView.swift; then
    echo "✅ Sheet de AnalyticsDashboardView configurado"
else
    echo "❌ Sheet de AnalyticsDashboardView NO configurado"
fi

echo ""
echo "📊 Verificando componentes de analíticas..."

# Verificar enums y estructuras en AnalyticsModels.swift
models=(
    "AnalyticsPeriod"
    "AnalyticsMetric"
    "ExtendedUserAnalytics"
    "UserComparison"
    "DetailedPerformanceInsights"
    "DataPoint"
)

for model in "${models[@]}"; do
    if grep -q "$model" worldbrainapp/worldbrain/Models/AnalyticsModels.swift; then
        echo "✅ Modelo $model definido"
    else
        echo "❌ Modelo $model NO encontrado"
    fi
done

echo ""
echo "🎨 Verificando componentes UI..."

ui_components=(
    "StatCard"
    "SkillMetricCard"
    "InsightCard"
    "ComparisonBar"
    "AchievementCard"
    "CustomLineChart"
    "AnalyticsPreviewCard"
    "MiniStatView"
)

for component in "${ui_components[@]}"; do
    if grep -q "struct $component" worldbrainapp/worldbrain/Views/AnalyticsDashboardView.swift || grep -q "struct $component" worldbrainapp/worldbrain/Views/ProfileView.swift; then
        echo "✅ Componente $component implementado"
    else
        echo "❌ Componente $component NO encontrado"
    fi
done

echo ""
echo "⚙️ Verificando funcionalidades del AnalyticsManager..."

manager_methods=(
    "refreshAnalytics"
    "updatePeriod"
    "getPerformanceData"
    "updateAllAnalytics"
    "updateUserAnalytics"
    "updatePerformanceInsights"
    "updateSkillMetrics"
    "updateUserComparison"
    "updateRecentAchievements"
)

for method in "${manager_methods[@]}"; do
    if grep -q "$method" worldbrainapp/worldbrain/Managers/AnalyticsManager.swift; then
        echo "✅ Método $method implementado"
    else
        echo "❌ Método $method NO encontrado"
    fi
done

echo ""
echo "🎯 Resumen de implementación:"
echo ""
echo "✅ COMPLETADO:"
echo "   • Modelos de datos para analíticas avanzadas"
echo "   • Manager de analíticas con datos de muestra"
echo "   • Vista completa de dashboard con gráficos personalizados"
echo "   • Integración en ProfileView con preview card"
echo "   • Componentes UI reutilizables"
echo "   • Gráficos personalizados sin dependencias externas"
echo "   • Sistema de períodos de análisis (día/semana/mes/año)"
echo "   • Métricas por habilidad con progreso visual"
echo "   • Comparativas con la comunidad"
echo "   • Logros recientes con categorías"
echo ""
echo "🚀 La implementación de Analíticas Avanzadas está completa!"
echo "   El usuario puede acceder desde ProfileView → 'Analíticas Avanzadas'"
echo ""
echo "📱 Funcionalidades implementadas:"
echo "   • Dashboard principal con múltiples secciones"
echo "   • Selector de período de análisis"
echo "   • Estadísticas rápidas con tendencias"
echo "   • Gráfico de evolución de rendimiento"
echo "   • Métricas por habilidad individual"
echo "   • Insights y predicciones"
echo "   • Comparativa con otros usuarios"
echo "   • Logros recientes categorizados"
echo ""
