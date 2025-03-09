import Foundation

struct LeaderboardUser: Identifiable, Equatable {
    let id = UUID()
    var nombre: String
    var xpTotal: Int
    var xpSemanal: Int
    
    // Si todas las propiedades son Equatable (UUID, String, Int, etc.)
    // Swift genera la conformidad por nosotros.
}
