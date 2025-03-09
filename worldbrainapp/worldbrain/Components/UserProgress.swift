import Foundation
import Combine

class UserProgress: ObservableObject {
    @Published var lessonsCompleted: Int = 0
    @Published var xp: Int = 0
    @Published var level: Int = 1
    @Published var xpForNextLevel: Int = 1000
    @Published var dailyStreak: Int = 0

    var progress: Double {
        return Double(xp) / Double(xpForNextLevel)
    }
    
    func completeLesson(xpGained: Int) {
        lessonsCompleted += 1
        xp += xpGained
        
        if xp >= xpForNextLevel {
            level += 1
            xp = xp - xpForNextLevel
            xpForNextLevel = Int(Double(xpForNextLevel) * 1.2)
        }
    }
}

