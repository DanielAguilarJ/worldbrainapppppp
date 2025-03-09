import SwiftUI
import AVFoundation

struct Question: Identifiable {
    let id = UUID()
    let text: String
    let options: [String]
    let correctAnswer: Int
}
