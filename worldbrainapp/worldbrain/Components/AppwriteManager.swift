//
//  AppwriteManager.swift
//  WorldBrain
//
//  Singleton para manejar la conexión y operaciones con Appwrite
//

import Foundation
import Appwrite
import JSONCodable

class AppwriteManager: ObservableObject {
    static let shared = AppwriteManager()
    
    private let client: Client
    private let account: Account
    private let databases: Databases
    
    // Configuración de Appwrite
    private let PROJECT_ID = "683b7d7000153e36f0d8"
    private let ENDPOINT = "https://cloud.appwrite.io/v1"
    
    @Published var currentSession: Session?
    @Published var isLoggedIn = false
    
    private init() {
        client = Client()
            .setEndpoint(ENDPOINT)
            .setProject(PROJECT_ID)
        
        account = Account(client)
        databases = Databases(client)
        
        // Verificar si hay una sesión activa
        checkCurrentSession()
    }
    
    // MARK: - Verificar sesión actual
    private func checkCurrentSession() {
        Task {
            do {
                let session = try await account.getSession(sessionId: "current")
                DispatchQueue.main.async {
                    self.currentSession = session
                    self.isLoggedIn = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.currentSession = nil
                    self.isLoggedIn = false
                }
            }
        }
    }
    
    // MARK: - Registro de usuario
    @MainActor
    func register(email: String, password: String, name: String) async throws -> User<[String: AnyCodable]> {
        let user = try await account.create(
            userId: ID.unique(),
            email: email,
            password: password,
            name: name
        )
        
        // Crear documento de usuario en la base de datos
        try await createUserDocument(userId: user.id, email: email, name: name)
        
        return user
    }
    
    // MARK: - Inicio de sesión
    @MainActor
    func login(email: String, password: String) async throws -> Session {
        let session = try await account.createEmailPasswordSession(
            email: email,
            password: password
        )
        
        self.currentSession = session
        self.isLoggedIn = true
        
        return session
    }
    
    // MARK: - Cerrar sesión
    @MainActor
    func logout() async throws {
        _ = try await account.deleteSession(sessionId: "current")
        
        self.currentSession = nil
        self.isLoggedIn = false
    }
    
    // MARK: - Crear documento de usuario en la base de datos
    private func createUserDocument(userId: String, email: String, name: String) async throws {
        let userData: [String: Any] = [
            "email": email,
            "name": name,
            "premium": false,
            "xp": 0,
            "completedLessons": [],
            "createdAt": Date().timeIntervalSince1970
        ]
        
        // Nota: Necesitarás crear una base de datos y colección en la consola de Appwrite
        // DATABASE_ID y COLLECTION_ID se definen en la consola
        let DATABASE_ID = "worldbrain_db"
        let USERS_COLLECTION_ID = "users"
        
        do {
            _ = try await databases.createDocument(
                databaseId: DATABASE_ID,
                collectionId: USERS_COLLECTION_ID,
                documentId: userId,
                data: userData
            )
        } catch {
            print("Error creando documento de usuario: \(error)")
            throw error
        }
    }
    
    // MARK: - Obtener información del usuario actual
    func getCurrentUser() async throws -> User<[String: AnyCodable]> {
        return try await account.get()
    }
    
    // MARK: - Actualizar XP del usuario
    func updateUserXP(userId: String, newXP: Int) async throws {
        let DATABASE_ID = "worldbrain_db"
        let USERS_COLLECTION_ID = "users"
        
        _ = try await databases.updateDocument(
            databaseId: DATABASE_ID,
            collectionId: USERS_COLLECTION_ID,
            documentId: userId,
            data: ["xp": newXP]
        )
    }
    
    // MARK: - Marcar lección como completada
    func markLessonAsCompleted(userId: String, lessonId: String) async throws {
        let DATABASE_ID = "worldbrain_db"
        let USERS_COLLECTION_ID = "users"
        
        // Primero obtener las lecciones completadas actuales
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
    
    // MARK: - Ping al servidor
    func pingServer() async -> Bool {
        do {
            _ = try await account.get()
            return true
        } catch {
            return false
        }
    }
}
