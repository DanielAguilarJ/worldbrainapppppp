import Foundation
import SwiftUI
import Combine

/// Manager que maneja todas las analíticas y métricas del usuario
class AnalyticsManager: ObservableObject {
    @Published var userAnalytics: ExtendedUserAnalytics?
    @Published var performanceInsights: DetailedPerformanceInsights?
    @Published var skillMetrics: [SkillMetric] = []
    @Published var userComparison: UserComparison?
    @Published var recentAchievements: [Achievement] = []
    @Published var isLoading = false
    @Published var lastUpdated: Date?
    
    private var currentPeriod: AnalyticsPeriod = .week
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    
    // Referencias a otros managers
    private weak var xpManager: XPManager?
    private weak var userProgress: UserProgress?
    
    init() {
        generateSampleData()
    }
    
    // MARK: - Public Methods
    
    func refreshAnalytics() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.updateAllAnalytics()
            self?.isLoading = false
        }
    }
    
    func updatePeriod(_ period: AnalyticsPeriod) {
        currentPeriod = period
        updateAllAnalytics()
    }
    
    func getPerformanceData(for metric: AnalyticsMetric) -> [DataPoint] {
        let calendar = Calendar.current
        let now = Date()
        var dataPoints: [DataPoint] = []
        
        let dayCount: Int
        switch currentPeriod {
        case .day:
            dayCount = 24 // Horas del día
        case .week:
            dayCount = 7
        case .month:
            dayCount = 30
        case .year:
            dayCount = 12 // Meses
        }
        
        for i in 0..<dayCount {
            let date: Date
            let baseValue: Double
            
            switch currentPeriod {
            case .day:
                date = calendar.date(byAdding: .hour, value: -dayCount + i, to: now) ?? now
                baseValue = generateRandomValue(for: metric, hour: i)
            case .week:
                date = calendar.date(byAdding: .day, value: -dayCount + i, to: now) ?? now
                baseValue = generateRandomValue(for: metric, day: i)
            case .month:
                date = calendar.date(byAdding: .day, value: -dayCount + i, to: now) ?? now
                baseValue = generateRandomValue(for: metric, day: i)
            case .year:
                date = calendar.date(byAdding: .month, value: -dayCount + i, to: now) ?? now
                baseValue = generateRandomValue(for: metric, month: i)
            }
            
            dataPoints.append(DataPoint(date: date, value: baseValue))
        }
        
        return dataPoints
    }
    
    // MARK: - Private Methods
    
    private func updateAllAnalytics() {
        updateUserAnalytics()
        updatePerformanceInsights()
        updateSkillMetrics()
        updateUserComparison()
        updateRecentAchievements()
        lastUpdated = Date()
    }
    
    private func updateUserAnalytics() {
        userAnalytics = ExtendedUserAnalytics(
            averageReadingSpeed: Double.random(in: 250...400),
            totalStudyTime: TimeInterval.random(in: 3600...14400), // 1-4 horas
            averageAccuracy: Double.random(in: 0.8...0.98),
            globalRank: Int.random(in: 50...500),
            readingSpeedTrend: .increasing,
            studyTimeTrend: .increasing,
            accuracyTrend: .stable
        )
    }
    
    private func updatePerformanceInsights() {
        performanceInsights = DetailedPerformanceInsights(
            bestDayOfWeek: ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes"].randomElement() ?? "Lunes",
            optimalStudyTime: ["9:00 AM", "2:00 PM", "7:00 PM", "10:00 AM"].randomElement() ?? "9:00 AM",
            nextMilestone: ["Velocidad 300 PPM", "Precisión 95%", "Tiempo diario 2h"].randomElement() ?? "Velocidad 300 PPM",
            weeklyProgress: Double.random(in: 0.05...0.15),
            monthlyProgress: Double.random(in: 0.2...0.4)
        )
    }
    
    private func updateSkillMetrics() {
        skillMetrics = SkillType.allCases.map { skillType in
            SkillMetric(
                skillType: skillType,
                currentLevel: Int.random(in: 1...10),
                progress: Double.random(in: 0.1...0.9),
                weeklyImprovement: Double.random(in: 0.02...0.08),
                experiencePoints: Int.random(in: 100...1000),
                lastUpdate: Date(),
                sessionHistory: []
            )
        }
    }
    
    private func updateUserComparison() {
        let userSpeed = Double.random(in: 280...350)
        let userStudyTime = Int.random(in: 60...180)
        let userAccuracy = Double.random(in: 0.85...0.95)
        
        userComparison = UserComparison(
            userReadingSpeed: userSpeed,
            averageReadingSpeed: 250,
            topReadingSpeed: 450,
            userStudyTime: userStudyTime,
            averageStudyTime: 90,
            topStudyTime: 240,
            userAccuracy: userAccuracy,
            averageAccuracy: 0.82
        )
    }
    
    private func updateRecentAchievements() {
        recentAchievements = [
            Achievement(
                title: "Velocista",
                description: "Alcanzaste 300 PPM",
                iconName: "speedometer",
                isUnlocked: true,
                earnedDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                category: .speed,
                rarity: .rare,
                progress: 1.0,
                requirements: ["Leer a 300 PPM por 5 minutos"]
            ),
            Achievement(
                title: "Precisión Perfecta",
                description: "90% de precisión en comprensión",
                iconName: "target",
                isUnlocked: true,
                earnedDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                category: .mastery,
                rarity: .epic,
                progress: 1.0,
                requirements: ["Mantener 90% precisión en 10 sesiones"]
            ),
            Achievement(
                title: "Constancia",
                description: "7 días consecutivos de práctica",
                iconName: "calendar.badge.checkmark",
                isUnlocked: true,
                earnedDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                category: .consistency,
                rarity: .common,
                progress: 1.0,
                requirements: ["Practicar 7 días seguidos"]
            ),
            Achievement(
                title: "Concentración Máxima",
                description: "45 minutos sin distracciones",
                iconName: "eye",
                isUnlocked: true,
                earnedDate: Date(),
                category: .special,
                rarity: .legendary,
                progress: 1.0,
                requirements: ["Mantener concentración por 45 min"]
            )
        ]
    }
    
    private func generateRandomValue(for metric: AnalyticsMetric, hour: Int = 0, day: Int = 0, month: Int = 0) -> Double {
        let baseValue: Double
        let variance: Double
        
        switch metric {
        case .readingSpeed:
            baseValue = 280
            variance = 50
        case .accuracy:
            baseValue = 0.85
            variance = 0.1
        case .comprehension:
            baseValue = 0.82
            variance = 0.08
        case .studyTime:
            baseValue = 120 // minutos
            variance = 40
        }
        
        let trend = sin(Double(day + hour + month) * 0.3) * 0.1 + 1.0
        let randomFactor = Double.random(in: -variance...variance)
        
        return max(0, baseValue * trend + randomFactor)
    }
    
    private func generateSampleData() {
        updateAllAnalytics()
    }
}

// MARK: - Extensiones auxiliares

extension AnalyticsManager {
    
    private func calculateSkillLevel(for skill: SkillType, from sessions: [SessionData]) -> Int {
        let skillSessions = sessions.filter { $0.skillImprovements.keys.contains(skill) }
        let totalImprovement = skillSessions.reduce(0.0) { sum, session in
            return sum + (session.skillImprovements[skill] ?? 0.0)
        }
        
        return max(1, Int(totalImprovement * 10) + 1) // Convertir mejora a nivel
    }
    
    private func calculateSkillProgress(for skill: SkillType, from sessions: [SessionData]) -> Double {
        let level = calculateSkillLevel(for: skill, from: sessions)
        let skillSessions = sessions.filter { $0.skillImprovements.keys.contains(skill) }
        let totalImprovement = skillSessions.reduce(0.0) { sum, session in
            return sum + (session.skillImprovements[skill] ?? 0.0)
        }
        
        let progressInLevel = totalImprovement.truncatingRemainder(dividingBy: 0.1)
        return progressInLevel / 0.1
    }
    
    private func calculateWeeklyImprovement(for skill: SkillType, from sessions: [SessionData]) -> Double {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentSessions = sessions.filter { $0.date >= oneWeekAgo && $0.skillImprovements.keys.contains(skill) }
        
        return recentSessions.reduce(0.0) { sum, session in
            return sum + (session.skillImprovements[skill] ?? 0.0)
        }
    }
    
    private func generateProgressDataPoints(from sessions: [SessionData]) -> [ProgressDataPoint] {
        var dataPoints: [ProgressDataPoint] = []
        
        for skill in SkillType.allCases {
            let skillSessions = sessions.filter { $0.skillImprovements.keys.contains(skill) }
            
            for session in skillSessions.prefix(20) { // Últimos 20 puntos de datos
                let value = session.skillImprovements[skill] ?? 0.0
                dataPoints.append(ProgressDataPoint(date: session.date, value: value, metric: skill))
            }
        }
        
        return dataPoints.sorted { $0.date > $1.date }
    }
    
    private func calculateTrend(for period: Calendar.Component, from dataPoints: [ProgressDataPoint]) -> TrendDirection {
        let calendar = Calendar.current
        let periodDate: Date
        
        switch period {
        case .weekOfYear:
            periodDate = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        case .month:
            periodDate = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        case .year:
            periodDate = calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        default:
            periodDate = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        }
        
        let recentPoints = dataPoints.filter { $0.date >= periodDate }
        let olderPoints = dataPoints.filter { $0.date < periodDate }
        
        if recentPoints.isEmpty || olderPoints.isEmpty { return .noData }
        
        let recentAverage = recentPoints.reduce(0.0) { $0 + $1.value } / Double(recentPoints.count)
        let olderAverage = olderPoints.reduce(0.0) { $0 + $1.value } / Double(olderPoints.count)
        
        let difference = recentAverage - olderAverage
        
        if abs(difference) < 0.01 { return .stable }
        return difference > 0 ? .increasing : .decreasing
    }
    
    private func generatePredictions(from dataPoints: [ProgressDataPoint]) -> [PredictionDataPoint] {
        // Implementación simplificada de predicción lineal
        var predictions: [PredictionDataPoint] = []
        
        for skill in SkillType.allCases {
            let skillPoints = dataPoints.filter { $0.metric == skill }.sorted { $0.date < $1.date }
            
            if skillPoints.count >= 2 {
                let x1 = skillPoints.first!.date.timeIntervalSince1970
                let y1 = skillPoints.first!.value
                let x2 = skillPoints.last!.date.timeIntervalSince1970
                let y2 = skillPoints.last!.value
                
                let slope = (y2 - y1) / (x2 - x1)
                
                // Predecir los próximos 7 días
                for i in 1...7 {
                    if let futureDate = Calendar.current.date(byAdding: .day, value: i, to: Date()) {
                        let futureX = futureDate.timeIntervalSince1970
                        let predictedY = y2 + slope * (futureX - x2)
                        
                        predictions.append(PredictionDataPoint(
                            date: futureDate,
                            predictedValue: max(0, predictedY),
                            confidence: max(0.3, 1.0 - Double(i) * 0.1), // Confianza decrece con el tiempo
                            metric: skill
                        ))
                    }
                }
            }
        }
        
        return predictions
    }
    
    private func findBestTimeOfDay(from sessions: [SessionData]) -> TimeRange {
        var hourPerformance: [Int: [Double]] = [:]
        
        for session in sessions {
            let hour = Calendar.current.component(.hour, from: session.date)
            if hourPerformance[hour] == nil {
                hourPerformance[hour] = []
            }
            hourPerformance[hour]?.append(session.performanceScore)
        }
        
        var bestHour = 9 // Default
        var bestScore = 0.0
        
        for (hour, scores) in hourPerformance {
            let average = scores.reduce(0, +) / Double(scores.count)
            if average > bestScore {
                bestScore = average
                bestHour = hour
            }
        }
        
        return TimeRange(start: bestHour, end: min(23, bestHour + 2))
    }
    
    private func findMostProductiveDays(from sessions: [SessionData]) -> [String] {
        var dayPerformance: [String: [Double]] = [:]
        
        for session in sessions {
            let day = session.date.dayOfWeek
            if dayPerformance[day] == nil {
                dayPerformance[day] = []
            }
            dayPerformance[day]?.append(session.performanceScore)
        }
        
        let sortedDays = dayPerformance.sorted { first, second in
            let firstAverage = first.value.reduce(0, +) / Double(first.value.count)
            let secondAverage = second.value.reduce(0, +) / Double(second.value.count)
            return firstAverage > secondAverage
        }
        
        return Array(sortedDays.prefix(2).map { $0.key })
    }
    
    private func calculateAverageSessionDuration(from sessions: [SessionData]) -> TimeInterval {
        if sessions.isEmpty { return 900 } // 15 minutos por defecto
        
        let totalDuration = sessions.reduce(0) { $0 + $1.duration }
        return totalDuration / Double(sessions.count)
    }
    
    private func calculateTotalTimeSpent(from sessions: [SessionData]) -> TimeInterval {
        return sessions.reduce(0) { $0 + $1.duration }
    }
    
    private func calculateWeeklyPattern(from sessions: [SessionData]) -> [DayPerformance] {
        let daysOfWeek = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
        var weeklyPattern: [DayPerformance] = []
        
        for day in daysOfWeek {
            let daySessions = sessions.filter { $0.date.dayOfWeek == day }
            
            let averageScore = daySessions.isEmpty ? 0.0 : 
                daySessions.reduce(0.0) { $0 + $1.performanceScore } / Double(daySessions.count)
            let totalXP = daySessions.reduce(0) { $0 + $1.xpGained }
            
            weeklyPattern.append(DayPerformance(
                day: day,
                averageScore: averageScore,
                sessionsCount: daySessions.count,
                totalXP: totalXP
            ))
        }
        
        return weeklyPattern
    }
    
    private func generateRivalComparisons() -> [RivalComparison] {
        // Datos simulados para demo
        let rivalNames = ["Ana García", "Carlos López", "María Ruiz"]
        var comparisons: [RivalComparison] = []
        
        for name in rivalNames {
            var skillComparison: [SkillType: ComparisonResult] = [:]
            
            for skill in SkillType.allCases {
                let randomDifference = Double.random(in: -30...30)
                if abs(randomDifference) < 5 {
                    skillComparison[skill] = .tied
                } else if randomDifference > 0 {
                    skillComparison[skill] = .ahead(by: randomDifference)
                } else {
                    skillComparison[skill] = .behind(by: abs(randomDifference))
                }
            }
            
            comparisons.append(RivalComparison(
                rivalName: name,
                myScore: Int.random(in: 800...1200),
                rivalScore: Int.random(in: 800...1200),
                skillComparison: skillComparison
            ))
        }
        
        return comparisons
    }
}

// MARK: - Extensiones para hacer los modelos Codable

extension PerformanceInsights: Codable {}
extension TimeAnalysis: Codable {}
extension TimeRange: Codable {}
extension DayPerformance: Codable {}
