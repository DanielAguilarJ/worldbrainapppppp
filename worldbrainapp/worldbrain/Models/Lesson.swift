import SwiftUI
import AVFoundation
import SwiftUI

enum LessonType {
    case reading
    case eyeTraining
    case speedReading
}
struct Lesson: Identifiable {
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
}
