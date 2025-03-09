// MARK: - LeaderboardUser.swift
import Foundation

struct LeaderboardUser: Identifiable {
    let id = UUID()
    var nombre: String
    var xpTotal: Int
    var xpSemanal: Int
    
    // Opcional: si quieres mostrar una “foto” o avatar
    // var avatarURL: URL?
}
