//
//  MigratedAuthViewModel.swift
//  WorldBrain
//
//  Ejemplo de migración del AuthViewModel existente al sistema unificado
//

import SwiftUI

class MigratedAuthViewModel: ObservableObject {
    @Published var currentUser: BackendUser?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    // Gestor unificado de backends
    private let unifiedAuthManager = UnifiedAuthManager()
    
    // Referencias a otros gestores de la app
    private var stageManager: StageManager?
    private var xpManager: XPManager?
    
    init() {
        // Configurar observadores del gestor unificado
        setupUnifiedManagerObservers()
    }
    
    // MARK: - Configuración inicial
    private func setupUnifiedManagerObservers() {
        // Observar cambios en el usuario actual
        unifiedAuthManager.$currentUser
            .assign(to: \.currentUser, on: self)
            .store(in: &cancellables)
        
        // Observar errores
        unifiedAuthManager.$errorMessage
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // Conectar con otros managers (mantener compatibilidad)
    func connectManagers(stageManager: StageManager, xpManager: XPManager) {
        self.stageManager = stageManager
        self.xpManager = xpManager
        
        // Conectar también con el gestor unificado
        unifiedAuthManager.connectManagers(stageManager: stageManager, xpManager: xpManager)
        
        print("📊 MigratedAuthViewModel conectado con StageManager y XPManager")
    }
    
    // MARK: - Métodos de autenticación (mantener compatibilidad)
    
    func signUp(email: String, password: String) {
        Task {
            await MainActor.run { self.isLoading = true }
            await unifiedAuthManager.signUp(email: email, password: password, name: nil)
            await MainActor.run { self.isLoading = false }
        }
    }
    
    func signIn(email: String, password: String) {
        Task {
            await MainActor.run { self.isLoading = true }
            await unifiedAuthManager.signIn(email: email, password: password)
            await MainActor.run { self.isLoading = false }
        }
    }
    
    func signOut() {
        Task {
            await MainActor.run { self.isLoading = true }
            await unifiedAuthManager.signOut()
            await MainActor.run { self.isLoading = false }
        }
    }
    
    // MARK: - Métodos específicos (adaptados)
    
    func updateXP(newXP: Int) {
        Task {
            await unifiedAuthManager.updateXP(newXP: newXP)
        }
    }
    
    func completeLesson(lessonID: String, stageIndex: Int? = nil) {
        Task {
            // Calcular XP basado en la lección completada
            let earnedXP = calculateXP(for: lessonID)
            await unifiedAuthManager.completeLesson(lessonID: lessonID, earnedXP: earnedXP)
        }
    }
    
    func setPremium() {
        // Esta funcionalidad necesitaría ser implementada en el backend unificado
        // Por ahora, mantener la lógica existente o adaptar según sea necesario
        guard let user = currentUser else { return }
        
        Task {
            // Implementar lógica para marcar como premium en ambos backends
            // Esto requerirá extender el protocolo BackendProtocol
            print("⭐ Funcionalidad Premium: Pendiente de implementación en sistema unificado")
        }
    }
    
    func redeemCode(_ code: String) {
        // Similar a setPremium, necesitaría ser implementado en el sistema unificado
        print("🎫 Código de redención: Pendiente de implementación en sistema unificado")
    }
    
    // MARK: - Métodos adicionales del sistema unificado
    
    func refreshUserData() {
        Task {
            await unifiedAuthManager.refreshUserData()
        }
    }
    
    // MARK: - Métodos auxiliares
    
    private func calculateXP(for lessonID: String) -> Int {
        // Lógica para calcular XP basado en el tipo de lección
        // Esto puede ser más sofisticado dependiendo de la lección
        return 50 // XP base por lección
    }
    
    // MARK: - Conversión de datos
    
    // Convertir BackendUser a FBUser para mantener compatibilidad con código existente
    var currentFBUser: FBUser? {
        guard let user = currentUser else { return nil }
        
        return FBUser(
            id: user.id,
            email: user.email,
            premium: user.premium,
            xp: user.xp,
            completedLessons: user.completedLessons
        )
    }
}

// MARK: - Extensión para mantener compatibilidad
extension MigratedAuthViewModel {
    
    // Propiedades computadas para mantener la API existente
    var isLoggedIn: Bool {
        return unifiedAuthManager.isLoggedIn
    }
    
    // Métodos que mantienen la misma firma que el AuthViewModel original
    func fetchUserDocument(uid: String) {
        // En el sistema unificado, esto se maneja automáticamente
        refreshUserData()
    }
    
    func syncCompletedLessonsWithStageManager(_ completedLessons: [String]) {
        // Esto se maneja automáticamente en UnifiedAuthManager
        print("🔄 Sincronización automática con StageManager activada")
    }
}

// MARK: - Extensión para Combine
import Combine

extension MigratedAuthViewModel {
    
    // Publicadores adicionales para reactive programming
    var userPublisher: AnyPublisher<BackendUser?, Never> {
        return $currentUser.eraseToAnyPublisher()
    }
    
    var authStatePublisher: AnyPublisher<Bool, Never> {
        return unifiedAuthManager.$isLoggedIn.eraseToAnyPublisher()
    }
}
