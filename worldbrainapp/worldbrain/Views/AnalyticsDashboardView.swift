import SwiftUI

struct AnalyticsDashboardView: View {
    @StateObject private var analyticsManager = AnalyticsManager()
    @State private var selectedPeriod: AnalyticsPeriod = .week
    @State private var selectedMetric: AnalyticsMetric = .readingSpeed
    @State private var showingComparison = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header con controles de período
                    periodSelectorView
                    
                    // Tarjetas de estadísticas rápidas
                    quickStatsSection
                    
                    // Gráfico principal de rendimiento
                    performanceChartSection
                    
                    // Métricas por habilidad
                    skillMetricsSection
                    
                    // Tendencias y predicciones
                    trendsSection
                    
                    // Comparativa con otros usuarios
                    comparisonSection
                    
                    // Logros recientes
                    achievementsSection
                }
                .padding()
            }
            .navigationTitle("📊 Analíticas")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Comparar") {
                        showingComparison.toggle()
                    }
                }
            }
        }
        .onAppear {
            analyticsManager.refreshAnalytics()
        }
    }
    
    // MARK: - Period Selector
    private var periodSelectorView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Período de análisis")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 8) {
                ForEach([AnalyticsPeriod.day, .week, .month, .year], id: \.self) { period in
                    Button(action: {
                        selectedPeriod = period
                        analyticsManager.updatePeriod(period)
                    }) {
                        Text(period.displayName)
                            .font(.subheadline)
                            .fontWeight(selectedPeriod == period ? .bold : .regular)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedPeriod == period ? Color.blue : Color.gray.opacity(0.2))
                            )
                            .foregroundColor(selectedPeriod == period ? .white : .primary)
                    }
                }
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Quick Stats
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resumen del progreso")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatCard(
                    title: "Velocidad promedio",
                    value: "\(Int(analyticsManager.userAnalytics?.averageReadingSpeed ?? 0)) PPM",
                    trend: analyticsManager.userAnalytics?.readingSpeedTrend ?? .stable,
                    icon: "speedometer",
                    color: .blue
                )
                
                StatCard(
                    title: "Tiempo total",
                    value: formatTime(analyticsManager.userAnalytics?.totalStudyTime ?? 0),
                    trend: analyticsManager.userAnalytics?.studyTimeTrend ?? .stable,
                    icon: "clock",
                    color: .green
                )
                
                StatCard(
                    title: "Precisión",
                    value: "\(Int((analyticsManager.userAnalytics?.averageAccuracy ?? 0) * 100))%",
                    trend: analyticsManager.userAnalytics?.accuracyTrend ?? .stable,
                    icon: "target",
                    color: .orange
                )
                
                StatCard(
                    title: "Ranking",
                    value: "#\(analyticsManager.userAnalytics?.globalRank ?? 0)",
                    trend: .stable,
                    icon: "trophy",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Performance Chart
    private var performanceChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Evolución del rendimiento")
                .font(.headline)
                .foregroundColor(.primary)
            
            // Selector de métrica
            HStack {
                Text("Métrica:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Métrica", selection: $selectedMetric) {
                    ForEach([AnalyticsMetric.readingSpeed, .accuracy, .comprehension], id: \.self) { metric in
                        Text(metric.displayName).tag(metric)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            // Gráfico de líneas personalizado
            CustomLineChart(
                data: analyticsManager.getPerformanceData(for: selectedMetric),
                metric: selectedMetric
            )
            .frame(height: 200)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    // MARK: - Skill Metrics
    private var skillMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Habilidades por categoría")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 12) {
                ForEach(analyticsManager.skillMetrics, id: \.skillType) { skill in
                    SkillMetricCard(skill: skill)
                }
            }
        }
    }
    
    // MARK: - Trends Section
    private var trendsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tendencias y predicciones")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let insights = analyticsManager.performanceInsights {
                VStack(spacing: 12) {
                    InsightCard(
                        title: "Mejor día de la semana",
                        value: insights.bestDayOfWeek,
                        icon: "calendar",
                        color: .green
                    )
                    
                    InsightCard(
                        title: "Tiempo óptimo de estudio",
                        value: insights.optimalStudyTime,
                        icon: "clock.badge.checkmark",
                        color: .blue
                    )
                    
                    InsightCard(
                        title: "Próximo objetivo",
                        value: insights.nextMilestone,
                        icon: "flag.checkered",
                        color: .orange
                    )
                }
            }
        }
    }
    
    // MARK: - Comparison Section
    private var comparisonSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Comparativa con la comunidad")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let comparison = analyticsManager.userComparison {
                VStack(spacing: 12) {
                    ComparisonBar(
                        title: "Velocidad de lectura",
                        userValue: comparison.userReadingSpeed,
                        averageValue: comparison.averageReadingSpeed,
                        maxValue: comparison.topReadingSpeed,
                        unit: "PPM"
                    )
                    
                    ComparisonBar(
                        title: "Tiempo de estudio",
                        userValue: Double(comparison.userStudyTime),
                        averageValue: Double(comparison.averageStudyTime),
                        maxValue: Double(comparison.topStudyTime),
                        unit: "min"
                    )
                    
                    ComparisonBar(
                        title: "Precisión",
                        userValue: comparison.userAccuracy * 100,
                        averageValue: comparison.averageAccuracy * 100,
                        maxValue: 100,
                        unit: "%"
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Achievements Section
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Logros recientes")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(analyticsManager.recentAchievements.prefix(4), id: \.id) { achievement in
                    AchievementCard(achievement: achievement)
                }
            }
            
            if analyticsManager.recentAchievements.count > 4 {
                Button("Ver todos los logros") {
                    // Navegar a vista completa de logros
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let trend: TrendDirection
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
                
                Image(systemName: trendIcon)
                    .foregroundColor(trendColor)
                    .font(.caption)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 1)
        )
    }
    
    private var trendIcon: String {
        switch trend {
        case .increasing:
            return "arrow.up"
        case .decreasing:
            return "arrow.down"
        case .stable:
            return "minus"
        }
    }
    
    private var trendColor: Color {
        switch trend {
        case .increasing:
            return .green
        case .decreasing:
            return .red
        case .stable:
            return .gray
        }
    }
}

struct SkillMetricCard: View {
    let skill: SkillMetric
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(skill.skillType.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(Int(skill.currentLevel))")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            ProgressView(value: skill.progress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: skill.skillType.color))
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
            
            HStack {
                Text("Progreso: \(Int(skill.progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("XP: \(skill.experiencePoints)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 1)
        )
    }
}

struct InsightCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
        )
    }
}

struct ComparisonBar: View {
    let title: String
    let userValue: Double
    let averageValue: Double
    let maxValue: Double
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(Int(userValue))\(unit)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Barra de fondo
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                    
                    // Barra promedio
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.orange.opacity(0.6))
                        .frame(width: geometry.size.width * (averageValue / maxValue), height: 8)
                    
                    // Barra del usuario
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * (userValue / maxValue), height: 8)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("Promedio: \(Int(averageValue))\(unit)")
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Spacer()
                
                Text("Top: \(Int(maxValue))\(unit)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.iconName)
                .font(.title2)
                .foregroundColor(achievement.category.color)
            
            Text(achievement.title)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .foregroundColor(.primary)
            
            Text(achievement.earnedDate, style: .date)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 1)
        )
    }
}

// MARK: - Extensions

extension AnalyticsPeriod {
    var displayName: String {
        switch self {
        case .day:
            return "Día"
        case .week:
            return "Semana"
        case .month:
            return "Mes"
        case .year:
            return "Año"
        }
    }
}

extension AnalyticsMetric {
    var displayName: String {
        switch self {
        case .readingSpeed:
            return "Velocidad"
        case .accuracy:
            return "Precisión"
        case .comprehension:
            return "Comprensión"
        case .studyTime:
            return "Tiempo"
        }
    }
}

extension SkillType {
    var color: Color {
        switch self {
        case .readingSpeed:
            return .blue
        case .comprehension:
            return .green
        case .retention:
            return .purple
        case .eyeMovement:
            return .orange
        case .peripheralVision:
            return .red
        case .focus:
            return .cyan
        }
    }
    
    var displayName: String {
        switch self {
        case .readingSpeed:
            return "Velocidad de lectura"
        case .comprehension:
            return "Comprensión"
        case .retention:
            return "Retención"
        case .eyeMovement:
            return "Movimiento ocular"
        case .peripheralVision:
            return "Visión periférica"
        case .focus:
            return "Concentración"
        }
    }
}

extension AchievementCategory {
    var color: Color {
        switch self {
        case .speed:
            return .blue
        case .accuracy:
            return .green
        case .consistency:
            return .orange
        case .milestone:
            return .purple
        case .special:
            return .pink
        }
    }
}

// MARK: - Custom Line Chart
struct CustomLineChart: View {
    let data: [DataPoint]
    let metric: AnalyticsMetric
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fondo del gráfico
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
                
                if !data.isEmpty {
                    let maxValue = data.map(\.value).max() ?? 100
                    let minValue = data.map(\.value).min() ?? 0
                    let range = maxValue - minValue
                    
                    // Líneas de la cuadrícula
                    VStack {
                        ForEach(0..<5) { i in
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 0.5)
                            if i < 4 { Spacer() }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Línea del gráfico
                    Path { path in
                        let stepX = geometry.size.width / CGFloat(data.count - 1)
                        let stepY = geometry.size.height
                        
                        for (index, point) in data.enumerated() {
                            let x = CGFloat(index) * stepX
                            let normalizedValue = range > 0 ? (point.value - minValue) / range : 0.5
                            let y = stepY - (CGFloat(normalizedValue) * stepY)
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color.blue, lineWidth: 2)
                    .padding(.horizontal)
                    
                    // Área bajo la línea
                    Path { path in
                        let stepX = geometry.size.width / CGFloat(data.count - 1)
                        let stepY = geometry.size.height
                        
                        // Comenzar desde la esquina inferior izquierda
                        path.move(to: CGPoint(x: 0, y: stepY))
                        
                        for (index, point) in data.enumerated() {
                            let x = CGFloat(index) * stepX
                            let normalizedValue = range > 0 ? (point.value - minValue) / range : 0.5
                            let y = stepY - (CGFloat(normalizedValue) * stepY)
                            
                            if index == 0 {
                                path.addLine(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                        
                        // Cerrar el área
                        if let lastPoint = data.last {
                            let lastX = CGFloat(data.count - 1) * stepX
                            path.addLine(to: CGPoint(x: lastX, y: stepY))
                        }
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .padding(.horizontal)
                    
                    // Puntos de datos
                    ForEach(Array(data.enumerated()), id: \.offset) { index, point in
                        let stepX = geometry.size.width / CGFloat(data.count - 1)
                        let stepY = geometry.size.height
                        let x = CGFloat(index) * stepX
                        let normalizedValue = range > 0 ? (point.value - minValue) / range : 0.5
                        let y = stepY - (CGFloat(normalizedValue) * stepY)
                        
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 6, height: 6)
                            .position(x: x + 16, y: y) // +16 para ajustar el padding
                    }
                    
                    // Etiquetas de valores en Y
                    VStack {
                        Text(String(format: "%.0f", maxValue))
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(String(format: "%.0f", (maxValue + minValue) / 2))
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(String(format: "%.0f", minValue))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

#Preview {
    AnalyticsDashboardView()
}
