import Foundation

// Modelo para las etapas del programa
enum StageType: String, Codable {
    case green = "Verde"
    case blue = "Azul"
    case red = "Rojo"
    case black = "Negro"
}

// Estado de desbloqueo de una etapa
enum StageStatus: String, Codable {
    case locked = "Bloqueada"
    case unlocked = "Desbloqueada"
    case completed = "Completada"
}

// Modelo para las etapas
struct Stage: Identifiable, Codable {
    let id = UUID()
    let type: StageType
    var status: StageStatus
    let requiredWPM: Int
    let requiredComprehension: Double
    let description: String
    var lessons: [Lesson]
    var challenges: [Challenge]
    var exam: Exam?
}

// Modelo para las lecciones
struct Lesson: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let content: String
    let targetWPM: Int
    var isCompleted: Bool = false
    var userComprehensionScore: Double?
    var userWPM: Int?
}

// Modelo para los desafíos
struct Challenge: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let type: ChallengeType
    let instructions: String
    var isCompleted: Bool = false
    var score: Double?
}

// Tipos de desafíos
enum ChallengeType: String, Codable {
    case peripheralVision = "Visión Periférica"
    case speedReading = "Lectura Rápida"
    case comprehension = "Comprensión"
}

// Modelo para exámenes
struct Exam: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let content: String
    let questions: [ExamQuestion]
    let requiredWPM: Int
    let requiredComprehension: Double
    var isPassed: Bool = false
    var userWPM: Int?
    var userComprehensionScore: Double?
    var attempts: Int = 0
}

// Modelo para preguntas de examen
struct ExamQuestion: Identifiable, Codable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctOptionIndex: Int
    var userSelectedIndex: Int?
    
    var isCorrect: Bool {
        guard let userSelectedIndex = userSelectedIndex else { return false }
        return userSelectedIndex == correctOptionIndex
    }
}

// Modelo para almacenar el progreso del usuario
struct UserProgress: Codable {
    var currentStage: StageType = .green
    var stages: [Stage]
    var currentWPM: Int = 0
    var averageComprehension: Double = 0
    
    func isStageUnlocked(_ stageType: StageType) -> Bool {
        if let stage = stages.first(where: { $0.type == stageType }) {
            return stage.status != .locked
        }
        return false
    }
}