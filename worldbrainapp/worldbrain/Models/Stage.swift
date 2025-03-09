import SwiftUI
import AVFoundation

struct Stage: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let description: String
    let requiredLessons: Int
    var lessons: [Lesson]
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
