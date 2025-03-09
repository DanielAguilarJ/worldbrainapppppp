//
//  LeaderboardManager.swift
//  worldbrainapp
//
//  Created by Daniel on 23/01/2025.
//


// MARK: - LeaderboardManager.swift
import SwiftUI

class LeaderboardManager: ObservableObject {
    @Published var usuarios: [LeaderboardUser] = []
    
    init() {
        // Ejemplo: datos iniciales “quemados”
        // En una app real, podrías cargar de un servidor, base de datos, etc.
        usuarios = [
            LeaderboardUser(nombre: "Daniel", xpTotal: 1200, xpSemanal: 300),
            LeaderboardUser(nombre: "Ana", xpTotal: 750, xpSemanal: 150),
            LeaderboardUser(nombre: "Carlos", xpTotal: 2000, xpSemanal: 500),
            LeaderboardUser(nombre: "María", xpTotal: 100, xpSemanal: 50),
        ]
    }
    
    // Ordenar por XP Semanal (descendente)
    func sortByWeeklyXP() {
        usuarios.sort(by: { $0.xpSemanal > $1.xpSemanal })
    }
    
    // Ordenar por XP Total (descendente)
    func sortByTotalXP() {
        usuarios.sort(by: { $0.xpTotal > $1.xpTotal })
    }
}
