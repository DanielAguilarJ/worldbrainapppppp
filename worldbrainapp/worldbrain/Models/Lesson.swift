import SwiftUI
import AVFoundation

struct Lesson: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let content: String
    let timeLimit: Int
    let questions: [Question]
    var isCompleted: Bool = false
    var isLocked: Bool = true
}
