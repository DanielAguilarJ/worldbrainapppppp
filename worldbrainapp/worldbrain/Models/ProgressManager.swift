//
//  StageType 2.swift
//  worldbrainapp
//
//  Created by msc on 10/03/2025.
//


//
//  ProgressManager.swift
//  worldbrainapp
//
//  Created by msc on 10/03/2025.
//

import SwiftUI
import Combine

// Este enumerado define los tipos de etapas en el nuevo sistema
enum StageType: String, Codable, Identifiable {
    case green = "Verde"
    case blue = "Azul"
    case red = "Rojo"
    case black = "Negro"
    
    var id: String { self.rawValue }
}

// Define los estados posibles de una etapa
enum StageStatus: String, Codable {
    case locked = "Bloqueada"
    case unlocked = "Desbloqueada"
    case completed = "Completada"
}

// Esta clase actúa como adaptador entre el sistema de etapas existente y el nuevo sistema
class ProgressManager: ObservableObject {
    @Published var blueStageProgress: Double = 0.0
    
    // Referencias a los sistemas de gestión existentes
    private let stageManager: StageManager
    private let xpManager: XPManager
    private let userProgress: UserProgress
    
    // Modelo de lección compatible con BlueStageView y ChallengesListView
    @Published var blueStageLessons: [Lesson] = []
    @Published var blueStageChallenges: [Challenge] = []
    
    init(stageManager: StageManager, xpManager: XPManager) {
        self.stageManager = stageManager
        self.xpManager = xpManager
        self.userProgress = UserProgress()
        
        // Inicializa desafíos para la etapa azul
        setupBlueStageChallenges()
        
        // Actualiza el progreso al iniciar
        calculateBlueStageProgress()
    }
    
    // Convierte las lecciones del StageManager al formato necesario para BlueStageView
    private func convertLessonsForBlueStage() {
        // Encuentra la etapa azul en el sistema existente (asumiendo que es la segunda etapa)
        if stageManager.stages.count >= 2 {
            let blueStage = stageManager.stages[1]
            
            // Convierte las lecciones existentes al nuevo formato
            blueStageLessons = blueStage.lessons.map { lesson in
                return Lesson(
                    id: lesson.id,
                    title: lesson.title,
                    description: lesson.description,
                    content: lesson.content,
                    targetWPM: 130, // Objetivo para la etapa azul
                    isCompleted: lesson.isCompleted,
                    userComprehensionScore: nil,
                    userWPM: nil
                )
            }
        }
    }
    
    // Configura los desafíos para la etapa azul
    private func setupBlueStageChallenges() {
        blueStageChallenges = [
            Challenge(
                id: UUID(),
                title: "Visión periférica avanzada",
                description: "Mejora tu capacidad para percibir más palabras en cada fijación visual.",
                type: .peripheralVision,
                instructions: "Mantén tu mirada fija en el punto central y trata de percibir las palabras que aparecerán brevemente a los lados."
            ),
            Challenge(
                id: UUID(),
                title: "Lectura cronometrada",
                description: "Lee un texto complejo a 130 PPM manteniendo alta comprensión.",
                type: .speedReading,
                instructions: "Lee el texto completo lo más rápido que puedas y responde las preguntas de comprensión correctamente."
            ),
            Challenge(
                id: UUID(),
                title: "Comprensión profunda",
                description: "Demuestra tu capacidad para entender textos complejos a alta velocidad.",
                type: .comprehension,
                instructions: "Lee el texto a tu velocidad máxima y responde a preguntas detalladas sobre su contenido."
            )
        ]
    }
    
    // Calcula el progreso de la etapa azul
    func calculateBlueStageProgress() {
        if stageManager.stages.count >= 2 {
            let blueStage = stageManager.stages[1]
            let completedLessons = blueStage.lessons.filter({ $0.isCompleted }).count
            let totalLessons = blueStage.requiredLessons
            
            // El progreso es la proporción de lecciones completadas
            blueStageProgress = totalLessons > 0 ? Double(completedLessons) / Double(totalLessons) : 0
        }
    }
    
    // MARK: - Métodos requeridos por BlueStageView y ChallengesListView
    
    // Verifica si la etapa está desbloqueada
    func isStageUnlocked(_ stage: StageType) -> Bool {
        switch stage {
        case .green:
            return true // La etapa verde siempre está desbloqueada
        case .blue:
            return stageManager.stages.count >= 2 ? !stageManager.stages[1].isLocked : false
        case .red:
            return stageManager.stages.count >= 3 ? !stageManager.stages[2].isLocked : false
        case .black:
            return stageManager.stages.count >= 4 ? !stageManager.stages[3].isLocked : false
        }
    }
    
    // Obtiene las lecciones para una etapa específica
    func getLessons(for stage: StageType) -> [Lesson] {
        // Si es la etapa azul, actualizamos primero y luego devolvemos
        if stage == .blue {
            convertLessonsForBlueStage()
            return blueStageLessons
        }
        return []
    }
    
    // Obtiene los desafíos para una etapa específica
    func getChallenges(for stage: StageType) -> [Challenge] {
        if stage == .blue {
            return blueStageChallenges
        }
        return []
    }
    
    // Completa una lección y actualiza el progreso
    func completeLesson(_ lesson: Lesson, withWPM wpm: Int, comprehension: Double) {
        // Busca la lección equivalente en el sistema existente y márcala como completada
        if let stageIndex = stageManager.stages.firstIndex(where: { $0.name == "Etapa Azul" }) {
            if let lessonIndex = stageManager.stages[stageIndex].lessons.firstIndex(where: { $0.id == lesson.id }) {
                stageManager.completeLesson(stageIndex: stageIndex, lessonId: lesson.id)
                
                // Añadir XP
                xpManager.addXP(xpManager.lessonXP)
                
                // Actualizar el progreso
                calculateBlueStageProgress()
            }
        }
    }
    
    // Completa un desafío
    func completeChallenge(_ challenge: Challenge, withScore score: Double) {
        // En el sistema actual no hay equivalente directo para desafíos
        // pero podemos incrementar XP como recompensa
        let earnedXP = Int(score / 20)
        xpManager.addXP(earnedXP)
        
        // Marcar el desafío como completado en nuestro modelo local
        if let index = blueStageChallenges.firstIndex(where: { $0.id == challenge.id }) {
            blueStageChallenges[index].isCompleted = true
            blueStageChallenges[index].score = score
        }
    }
    
    // Determina si todas las lecciones de una etapa están completadas
    func areAllLessonsCompleted(for stageType: StageType) -> Bool {
        switch stageType {
        case .blue:
            if stageManager.stages.count >= 2 {
                let blueStage = stageManager.stages[1]
                return blueStage.isCompleted
            }
            return false
        default:
            return false
        }
    }
    
    // Función para navegar al examen de una etapa
    func navigateToExam(of stageType: StageType) {
        // Esta función sería implementada para la navegación
        // Por ahora es un placeholder
    }
}

// MARK: - Modelos de datos para la etapa azul

// Modelo de lección adaptado para BlueStageView
struct Lesson: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let content: String
    let targetWPM: Int
    var isCompleted: Bool = false
    var userComprehensionScore: Double?
    var userWPM: Int?
}

// Modelo para desafíos
struct Challenge: Identifiable {
    let id: UUID
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

// Modelo para examen
struct Exam: Identifiable {
    let id: UUID
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
struct ExamQuestion: Identifiable {
    let id: UUID
    let question: String
    let options: [String]
    let correctOptionIndex: Int
    var userSelectedIndex: Int?
}