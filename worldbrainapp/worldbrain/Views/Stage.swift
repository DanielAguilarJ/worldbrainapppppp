import SwiftUI
import AVFoundation

struct Stage: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let description: String
    let requiredLessons: Int
    
    // Anotamos el tipo completo, especificando directamente la estructura que queremos usar
    // Ya que hay dos definiciones de "Lesson" diferentes en el proyecto
    var lessons: [LessonFromModelsFile] // Usamos una estructura específica para evitar ambigüedad
    var isLocked: Bool
    
    static func == (lhs: Stage, rhs: Stage) -> Bool {
        lhs.id == rhs.id
    }
    
    var isCompleted: Bool {
        lessons.filter { $0.isCompleted }.count >= requiredLessons
    }
    
    var completedLessonsCount: Int {
        lessons.filter { $0.isCompleted }.count
    }
}

// Tipo auxiliar para eliminar la ambigüedad
// Esta estructura debe tener exactamente la misma definición que la Lesson original
struct LessonFromModelsFile: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let type: LessonType
    let timeLimit: Int
    let content: String
    let questions: [Question]
    var isCompleted: Bool = false
    var isLocked: Bool = true
    let eyeExercises: [EyeExercise]?
    let pyramidExercise: PyramidTextExercise?
}
