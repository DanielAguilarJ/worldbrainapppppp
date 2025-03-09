//
//  UserProgress.swift
//  worldbrainapp
//
//  Este objeto controla el progreso del usuario y se actualiza automáticamente
//  cuando se completa una lección o ejercicio.
//  Usa @Published para notificar cambios y actualizar todas las vistas que lo observan.
//

import Foundation
import Combine

class UserProgress: ObservableObject {
    @Published var lessonsCompleted: Int = 0
    @Published var xp: Int = 0
    @Published var level: Int = 1
    @Published var xpForNextLevel: Int = 1000
    @Published var dailyStreak: Int = 0

    // Progreso como valor entre 0 y 1
    var progress: Double {
        return Double(xp) / Double(xpForNextLevel)
    }
    
    // Esta función se llamará automáticamente al terminar una lección o ejercicio.
    // Por ejemplo, si se gana 150 XP al completar una lección, se llama con xpGained: 150.
    func completeLesson(xpGained: Int) {
        lessonsCompleted += 1
        xp += xpGained
        
        // Si se supera el XP requerido para subir de nivel
        if xp >= xpForNextLevel {
            level += 1
            xp = xp - xpForNextLevel
            // Se incrementa el XP requerido para el siguiente nivel (ej. en un 20%)
            xpForNextLevel = Int(Double(xpForNextLevel) * 1.2)
        }
    }
}
