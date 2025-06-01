//
//  UnifiedAuthManager.swift
//  WorldBrain
//
//  Gestor de autenticación usando Appwrite
//

import Foundation
import SwiftUI

class UnifiedAuthManager: ObservableObject {
    @Published var currentUser: BackendUser?
    @Published var isLoggedIn = false
    @Published var errorMessage: String?
    
    private var appwriteBackend: AppwriteBackend
    
    // Referencias a otros gestores de la app
    private var stageManager: StageManager?
    private var xpManager: XPManager?
    
    private var activeBackend: BackendProtocol {
        return appwriteBackend
    }
    
    init() {
        appwriteBackend = AppwriteBackend()
        
        // Verificar usuario actual al inicializar
        Task {
            await checkCurrentUser()
        }
    }
    
    // MARK: - Configuración
    func connectManagers(stageManager: StageManager, xpManager: XPManager) {
        self.stageManager = stageManager
        self.xpManager = xpManager
        print("📊 UnifiedAuthManager conectado con StageManager y XPManager")
    }
    
    // MARK: - Verificar usuario actual
    @MainActor
    private func checkCurrentUser() async {
        do {
            if let user = try await activeBackend.getCurrentUser() {
                self.currentUser = user
                self.isLoggedIn = true
                print("✅ Usuario encontrado en Appwrite: \(user.email)")
            } else {
                self.currentUser = nil
                self.isLoggedIn = false
                print("❌ No hay usuario logueado en Appwrite")
            }
        } catch {
            self.currentUser = nil
            self.isLoggedIn = false
            print("❌ Error verificando usuario en Appwrite: \(error)")
        }
    }
    
    // MARK: - Registro
    @MainActor
    func signUp(email: String, password: String, name: String? = nil) async {
        errorMessage = nil
        
        do {
            let user = try await activeBackend.signUp(email: email, password: password, name: name)
            self.currentUser = user
            self.isLoggedIn = true
            
            print("✅ Registro exitoso en Appwrite: \(user.email)")
            
            // Sincronizar con managers locales si están disponibles
            await syncWithLocalManagers(user: user)
            
        } catch {
            self.errorMessage = "Error al registrarse: \(error.localizedDescription)"
            print("❌ Error registro en Appwrite: \(error)")
        }
    }
    
    // MARK: - Inicio de sesión
    @MainActor
    func signIn(email: String, password: String) async {
        errorMessage = nil
        
        do {
            let user = try await activeBackend.signIn(email: email, password: password)
            self.currentUser = user
            self.isLoggedIn = true
            
            print("✅ Login exitoso en Appwrite: \(user.email)")
            
            // Sincronizar con managers locales si están disponibles
            await syncWithLocalManagers(user: user)
            
        } catch {
            self.errorMessage = "Error al iniciar sesión: \(error.localizedDescription)"
            print("❌ Error login en Appwrite: \(error)")
        }
    }
    
    // MARK: - Cerrar sesión
    @MainActor
    func signOut() async {
        do {
            try await activeBackend.signOut()
            self.currentUser = nil
            self.isLoggedIn = false
            self.errorMessage = nil
            
            print("✅ Logout exitoso en Appwrite")
            
        } catch {
            self.errorMessage = "Error al cerrar sesión: \(error.localizedDescription)"
            print("❌ Error logout en Appwrite: \(error)")
        }
    }
    
    // MARK: - Actualizar XP
    func updateXP(newXP: Int) async {
        guard let user = currentUser else { return }
        
        do {
            try await activeBackend.updateUserXP(userId: user.id, newXP: newXP)
            
            await MainActor.run {
                self.currentUser?.xp = newXP
            }
            
            // Actualizar XP en manager local si está disponible
            xpManager?.setXP(newXP)
            
            print("💎 XP actualizado a \(newXP) en Appwrite")
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Error actualizando XP: \(error.localizedDescription)"
            }
            print("❌ Error actualizando XP: \(error)")
        }
    }
    
    // MARK: - Completar lección
    func completeLesson(lessonID: String, earnedXP: Int = 0) async {
        guard let user = currentUser else { return }
        
        do {
            // Marcar lección como completada
            try await activeBackend.markLessonAsCompleted(userId: user.id, lessonId: lessonID)
            
            // Actualizar XP si se ganó experiencia
            if earnedXP > 0 {
                let newXP = user.xp + earnedXP
                try await activeBackend.updateUserXP(userId: user.id, newXP: newXP)
                
                await MainActor.run {
                    self.currentUser?.xp = newXP
                }
                
                // Actualizar XP en manager local
                xpManager?.addXP(earnedXP)
            }
            
            // Actualizar lecciones completadas localmente
            await MainActor.run {
                if !self.currentUser!.completedLessons.contains(lessonID) {
                    self.currentUser?.completedLessons.append(lessonID)
                }
            }
            
            // Sincronizar con StageManager local si está disponible
            stageManager?.markLessonCompleted(lessonID)
            
            print("🎓 Lección \(lessonID) completada en Appwrite")
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Error completando lección: \(error.localizedDescription)"
            }
            print("❌ Error completando lección: \(error)")
        }
    }
    
    // MARK: - Sincronización con managers locales
    private func syncWithLocalManagers(user: BackendUser) async {
        // Sincronizar lecciones completadas con StageManager
        if let stageManager = stageManager {
            for lessonID in user.completedLessons {
                stageManager.markLessonCompleted(lessonID)
            }
        }
        
        // Sincronizar XP con XPManager
        xpManager?.setXP(user.xp)
    }
    
    // MARK: - Obtener información actualizada del usuario
    func refreshUserData() async {
        guard let user = currentUser else { return }
        
        do {
            let updatedUser = try await activeBackend.getUserData(userId: user.id)
            
            await MainActor.run {
                self.currentUser = updatedUser
            }
            
            await syncWithLocalManagers(user: updatedUser)
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Error actualizando datos: \(error.localizedDescription)"
            }
        }
    }
}
