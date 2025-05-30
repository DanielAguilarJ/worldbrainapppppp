import Foundation
import SwiftUI

// MARK: - Modelos para analíticas avanzadas

/// Período de tiempo para análisis
enum AnalyticsPeriod: String, CaseIterable {
    case day = "day"
    case week = "week"
    case month = "month"
    case year = "year"
}

/// Métrica específica para análisis
enum AnalyticsMetric: String, CaseIterable {
    case readingSpeed = "readingSpeed"
    case accuracy = "accuracy"
    case comprehension = "comprehension"
    case studyTime = "studyTime"
}

/// Punto de datos para gráficos
struct DataPoint {
    let date: Date
    let value: Double
}

/// Analíticas extendidas del usuario
struct ExtendedUserAnalytics {
    var averageReadingSpeed: Double
    var totalStudyTime: TimeInterval
    var averageAccuracy: Double
    var globalRank: Int
    var readingSpeedTrend: TrendDirection
    var studyTimeTrend: TrendDirection
    var accuracyTrend: TrendDirection
}

/// Comparativa con otros usuarios
struct UserComparison {
    var userReadingSpeed: Double
    var averageReadingSpeed: Double
    var topReadingSpeed: Double
    var userStudyTime: Int
    var averageStudyTime: Int
    var topStudyTime: Int
    var userAccuracy: Double
    var averageAccuracy: Double
}

/// Insights de rendimiento detallados
struct DetailedPerformanceInsights {
    var bestDayOfWeek: String
    var optimalStudyTime: String
    var nextMilestone: String
    var weeklyProgress: Double
    var monthlyProgress: Double
}

/// Modelo principal que contiene todos los insights del usuario
struct UserAnalytics {
    var performanceInsights: PerformanceInsights
    var skillMetrics: [SkillMetric]
    var progressTrends: ProgressTrends
    var achievements: [Achievement]
    var timeAnalysis: TimeAnalysis
    var competitiveStats: CompetitiveStats
}

/// Métricas de rendimiento del usuario
struct PerformanceInsights {
    var readingSpeedWPM: Int
    var comprehensionRate: Double
    var visualFieldWidth: Int
    var retentionScore: Double
    var consistencyScore: Double
    var improvementRate: Double
    var weeklyGrowth: Double
    var monthlyGrowth: Double
}

/// Métrica individual por habilidad
struct SkillMetric: Identifiable {
    let id = UUID()
    var skillType: SkillType
    var currentLevel: Int
    var progress: Double // 0.0 a 1.0
    var weeklyImprovement: Double
    var experiencePoints: Int
    var lastUpdate: Date
    var sessionHistory: [SessionData]
}

/// Tipos de habilidades que se pueden medir
enum SkillType: String, CaseIterable, Identifiable {
    case readingSpeed = "readingSpeed"
    case comprehension = "comprehension"
    case retention = "retention"
    case eyeMovement = "eyeMovement"
    case peripheralVision = "peripheralVision"
    case focus = "focus"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .readingSpeed: return "speedometer"
        case .comprehension: return "brain.head.profile"
        case .visualField: return "eye.circle"
        case .retention: return "bookmark.circle"
        case .eyeMovement: return "eye.trianglebadge.exclamationmark"
        case .concentration: return "target"
        }
    }
    
    var color: Color {
        switch self {
        case .readingSpeed: return .blue
        case .comprehension: return .green
        case .visualField: return .purple
        case .retention: return .orange
        case .eyeMovement: return .red
        case .concentration: return .indigo
        }
    }
    
    var unit: String {
        switch self {
        case .readingSpeed: return "PPM"
        case .comprehension: return "%"
        case .visualField: return "caracteres"
        case .retention: return "%"
        case .eyeMovement: return "movimientos/min"
        case .concentration: return "puntos"
        }
    }
}

/// Datos de una sesión individual
struct SessionData: Identifiable {
    let id = UUID()
    var date: Date
    var duration: TimeInterval
    var xpGained: Int
    var exerciseType: String
    var performanceScore: Double
    var skillImprovements: [SkillType: Double]
}

/// Tendencias de progreso a lo largo del tiempo
struct ProgressTrends {
    var weeklyTrend: TrendDirection
    var monthlyTrend: TrendDirection
    var yearlyTrend: TrendDirection
    var dataPoints: [ProgressDataPoint]
    var predictions: [PredictionDataPoint]
}

/// Dirección de la tendencia
enum TrendDirection {
    case increasing
    case decreasing
    case stable
    case noData
    
    var icon: String {
        switch self {
        case .increasing: return "arrow.up.right"
        case .decreasing: return "arrow.down.right"
        case .stable: return "arrow.right"
        case .noData: return "questionmark"
        }
    }
    
    var color: Color {
        switch self {
        case .increasing: return .green
        case .decreasing: return .red
        case .stable: return .orange
        case .noData: return .gray
        }
    }
}

/// Punto de datos para gráficos de progreso
struct ProgressDataPoint: Identifiable {
    let id = UUID()
    var date: Date
    var value: Double
    var metric: SkillType
}

/// Punto de datos para predicciones
struct PredictionDataPoint: Identifiable {
    let id = UUID()
    var date: Date
    var predictedValue: Double
    var confidence: Double
    var metric: SkillType
}

/// Logros y medallas del usuario
struct Achievement: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var icon: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    var category: AchievementCategory
    var rarity: AchievementRarity
    var progress: Double // 0.0 a 1.0 para logros en progreso
    var requirement: String
}

enum AchievementCategory: String, CaseIterable {
    case speed = "Velocidad"
    case consistency = "Consistencia"
    case improvement = "Mejora"
    case mastery = "Maestría"
    case social = "Social"
    case special = "Especial"
}

enum AchievementRarity: String, CaseIterable {
    case common = "Común"
    case rare = "Raro"
    case epic = "Épico"
    case legendary = "Legendario"
    
    var color: Color {
        switch self {
        case .common: return .gray
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .yellow
        }
    }
}

/// Análisis temporal de las actividades del usuario
struct TimeAnalysis {
    var bestTimeOfDay: TimeRange
    var mostProductiveDays: [String]
    var averageSessionDuration: TimeInterval
    var totalTimeSpent: TimeInterval
    var longestStreak: Int
    var currentStreak: Int
    var weeklyPattern: [DayPerformance]
}

/// Rango de tiempo óptimo
struct TimeRange {
    var start: Int // Hora del día (0-23)
    var end: Int
    
    var description: String {
        return "\(start):00 - \(end):00"
    }
}

/// Rendimiento por día de la semana
struct DayPerformance {
    var day: String
    var averageScore: Double
    var sessionsCount: Int
    var totalXP: Int
}

/// Estadísticas competitivas
struct CompetitiveStats {
    var globalRank: Int
    var regionRank: Int
    var percentile: Double
    var competitionsWon: Int
    var competitionsParticipated: Int
    var averageRankingPosition: Double
    var rivalComparison: [RivalComparison]
}

/// Comparación con rivales/amigos
struct RivalComparison {
    var rivalName: String
    var myScore: Int
    var rivalScore: Int
    var skillComparison: [SkillType: ComparisonResult]
}

enum ComparisonResult {
    case ahead(by: Double)
    case behind(by: Double)
    case tied
    
    var color: Color {
        switch self {
        case .ahead: return .green
        case .behind: return .red
        case .tied: return .orange
        }
    }
}

// MARK: - Extensiones para formateo

extension Double {
    var formattedPercentage: String {
        return String(format: "%.1f%%", self * 100)
    }
    
    var formattedDecimal: String {
        return String(format: "%.2f", self)
    }
}

extension TimeInterval {
    var formattedDuration: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

extension Date {
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: self)
    }
    
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: self)
    }
}
