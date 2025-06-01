//
//  Models.swift
//  worldbrainapp
//
//  Estructuras de datos para la aplicación
//

import Foundation

/// Información de cada usuario
/// NOTA: 'Equatable' es esencial para usar .onChange(of:...) en SwiftUI
struct FBUser: Codable, Identifiable, Equatable {
    let id: String        // uid del usuario
    var email: String
    var premium: Bool
    var xp: Int
    var completedLessons: [String]
    
    // Con Equatable, SwiftUI puede comparar objetos de este tipo
    static func == (lhs: FBUser, rhs: FBUser) -> Bool {
        lhs.id == rhs.id &&
        lhs.email == rhs.email &&
        lhs.premium == rhs.premium &&
        lhs.xp == rhs.xp &&
        lhs.completedLessons == rhs.completedLessons
    }
    
    // Init para usar manualmente
    init(id: String, email: String, premium: Bool, xp: Int, completedLessons: [String]) {
        self.id = id
        self.email = email
        self.premium = premium
        self.xp = xp
        self.completedLessons = completedLessons
    }
    
    // Para decodificar desde un doc Firestore
    init?(id: String, data: [String: Any]) {
        guard let email = data["email"] as? String,
              let premium = data["premium"] as? Bool,
              let xp = data["xp"] as? Int,
              let completedLessons = data["completedLessons"] as? [String] else { return nil }
        
        self.id = id
        self.email = email
        self.premium = premium
        self.xp = xp
        self.completedLessons = completedLessons
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "email": email,
            "premium": premium,
            "xp": xp,
            "completedLessons": completedLessons
        ]
    }
}

/// Modelo para un código premium
struct PremiumCode: Codable, Identifiable {
    let id: String       // id del documento
    var code: String     // el código en sí
    var used: Bool       // true si ya fue canjeado
    
    init(id: String, code: String, used: Bool) {
        self.id = id
        self.code = code
        self.used = used
    }
    
    init?(id: String, data: [String: Any]) {
        guard let code = data["code"] as? String,
              let used = data["used"] as? Bool else { return nil }
        self.id = id
        self.code = code
        self.used = used
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "code": code,
            "used": used
        ]
    }
}


