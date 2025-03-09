import Foundation
import SwiftUI

class XPManager: ObservableObject {
    @Published var currentXP: Int = 0
    let lessonXP = 50 // XP por lección completada
    
    init() {
        currentXP = UserDefaults.standard.integer(forKey: "currentXP")
    }
    
    func addXP(_ amount: Int) {
        currentXP += amount
        UserDefaults.standard.set(currentXP, forKey: "currentXP")
        objectWillChange.send()
    }
    
    func resetXP() {
        currentXP = 0
        UserDefaults.standard.set(currentXP, forKey: "currentXP")
        objectWillChange.send()
    }
    
    // Propiedad para determinar el nivel de lector
    var readerLevel: ReaderLevel {
        switch currentXP {
        case 0..<300:
            return .novato
        case 300..<600:
            return .intermedio
        case 600..<1200:
            return .avanzado
        default:
            return .experto
        }
    }
}

enum ReaderLevel: String {
    case novato = "Novato"
    case intermedio = "Intermedio"
    case avanzado = "Avanzado"
    case experto = "Experto"
}

