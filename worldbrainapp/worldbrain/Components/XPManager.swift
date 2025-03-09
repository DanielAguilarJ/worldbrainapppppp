//
//  XPManager.swift
//  worldbrainapp
//
//  Created by Daniel on 21/01/2025.
//


// XPManager.swift
import Foundation

class XPManager: ObservableObject {
    @Published var currentXP: Int = 0
    let lessonXP = 50 // XP ganado por lección
    
    init() {
        // Cargar XP guardado o empezar en 0
        currentXP = UserDefaults.standard.integer(forKey: "currentXP")
    }
    
    func addXP(_ amount: Int) {
        currentXP += amount
        // Guardar XP actualizado
        UserDefaults.standard.set(currentXP, forKey: "currentXP")
    }
    
    func resetXP() {
        currentXP = 0
        UserDefaults.standard.set(currentXP, forKey: "currentXP")
    }
}