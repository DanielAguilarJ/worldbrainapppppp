//
//  BackendProtocol.swift
//  WorldBrain
//
//  Protocolo para el backend de Appwrite
//

import Foundation

// MARK: - Protocolo de Backend
protocol BackendProtocol {
    func signUp(email: String, password: String, name: String?) async throws -> BackendUser
    func signIn(email: String, password: String) async throws -> BackendUser
    func signOut() async throws
    func getCurrentUser() async throws -> BackendUser?
    func updateUserXP(userId: String, newXP: Int) async throws
    func markLessonAsCompleted(userId: String, lessonId: String) async throws
    func getUserData(userId: String) async throws -> BackendUser
}

// MARK: - Modelo unificado de usuario
struct BackendUser: Codable, Identifiable, Equatable {
    let id: String
    var email: String
    var name: String?
    var premium: Bool
    var xp: Int
    var completedLessons: [String]
    
    static func == (lhs: BackendUser, rhs: BackendUser) -> Bool {
        lhs.id == rhs.id &&
        lhs.email == rhs.email &&
        lhs.name == rhs.name &&
        lhs.premium == rhs.premium &&
        lhs.xp == rhs.xp &&
        lhs.completedLessons == rhs.completedLessons
    }
}
