//
//  AppwriteBackend.swift
//  WorldBrain
//
//  Adaptador para Appwrite que implementa BackendProtocol
//

import Foundation
import Appwrite
import JSONCodable

class AppwriteBackend: BackendProtocol {
    private let client: Client
    private let account: Account
    private let databases: Databases
    
    // Configuración de Appwrite
    private let PROJECT_ID = "683b7d7000153e36f0d8"
    private let ENDPOINT = "https://cloud.appwrite.io/v1"
    private let DATABASE_ID = "worldbrain_db"
    private let USERS_COLLECTION_ID = "users"
    
    init() {
        client = Client()
            .setEndpoint(ENDPOINT)
            .setProject(PROJECT_ID)
        
        account = Account(client)
        databases = Databases(client)
    }
    
    func signUp(email: String, password: String, name: String?) async throws -> BackendUser {
        // Crear usuario en Appwrite Auth
        let user = try await account.create(
            userId: ID.unique(),
            email: email,
            password: password,
            name: name
        )
        
        // Crear documento en la base de datos
        let userData: [String: Any] = [
            "email": email,
            "name": name ?? "",
            "premium": false,
            "xp": 0,
            "completedLessons": [],
            "createdAt": Date().timeIntervalSince1970
        ]
        
        _ = try await databases.createDocument(
            databaseId: DATABASE_ID,
            collectionId: USERS_COLLECTION_ID,
            documentId: user.id,
            data: userData
        )
        
        return BackendUser(
            id: user.id,
            email: email,
            name: name,
            premium: false,
            xp: 0,
            completedLessons: []
        )
    }
    
    func signIn(email: String, password: String) async throws -> BackendUser {
        // Crear sesión
        _ = try await account.createEmailPasswordSession(
            email: email,
            password: password
        )
        
        // Obtener información del usuario
        let user = try await account.get()
        return try await getUserData(userId: user.id)
    }
    
    func signOut() async throws {
        _ = try await account.deleteSession(sessionId: "current")
    }
    
    func getCurrentUser() async throws -> BackendUser? {
        do {
            let user = try await account.get()
            return try await getUserData(userId: user.id)
        } catch {
            return nil
        }
    }
    
    func updateUserXP(userId: String, newXP: Int) async throws {
        _ = try await databases.updateDocument(
            databaseId: DATABASE_ID,
            collectionId: USERS_COLLECTION_ID,
            documentId: userId,
            data: ["xp": newXP]
        )
    }
    
    func markLessonAsCompleted(userId: String, lessonId: String) async throws {
        // Primero obtener el documento actual
        let userDoc = try await databases.getDocument(
            databaseId: DATABASE_ID,
            collectionId: USERS_COLLECTION_ID,
            documentId: userId
        )
        
        var completedLessons = userDoc.data["completedLessons"] as? [String] ?? []
        
        if !completedLessons.contains(lessonId) {
            completedLessons.append(lessonId)
            
            _ = try await databases.updateDocument(
                databaseId: DATABASE_ID,
                collectionId: USERS_COLLECTION_ID,
                documentId: userId,
                data: ["completedLessons": completedLessons]
            )
        }
    }
    
    func getUserData(userId: String) async throws -> BackendUser {
        let document = try await databases.getDocument(
            databaseId: DATABASE_ID,
            collectionId: USERS_COLLECTION_ID,
            documentId: userId
        )
        
        let data = document.data
        
        return BackendUser(
            id: userId,
            email: data["email"] as? String ?? "",
            name: data["name"] as? String,
            premium: data["premium"] as? Bool ?? false,
            xp: data["xp"] as? Int ?? 0,
            completedLessons: data["completedLessons"] as? [String] ?? []
        )
    }
}
