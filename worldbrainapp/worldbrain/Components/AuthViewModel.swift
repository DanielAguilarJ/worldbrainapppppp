//
//  AuthViewModel.swift
//  worldbrainapp
//
//  Maneja registro, login y Firestore
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore

class AuthViewModel: ObservableObject {
    @Published var currentUser: FBUser?  // Usuario logueado
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    
    // Referencias a otros gestores de la app
    private var stageManager: StageManager?
    private var xpManager: XPManager?
    
    init() {
        // Ver si hay un usuario de FirebaseAuth
        if let user = Auth.auth().currentUser {
            fetchUserDocument(uid: user.uid)
        }
    }
    
    // Conectar con otros managers (llamar desde AppDelegate o similar)
    func connectManagers(stageManager: StageManager, xpManager: XPManager) {
        self.stageManager = stageManager
        self.xpManager = xpManager
        print("📊 AuthViewModel conectado con StageManager y XPManager")
    }
    
    // MARK: - REGISTRO
    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = "Error al registrarse: \(error.localizedDescription)"
                return
            }
            guard let user = result?.user else { return }
            
            // Crear doc en Firestore con valores iniciales
            let fbUser = FBUser(id: user.uid, email: email, premium: false, xp: 0, completedLessons: [])
            
            self?.db.collection("users")
                .document(user.uid)
                .setData(fbUser.toDictionary()) { err in
                    if let err = err {
                        self?.errorMessage = "Error guardando usuario: \(err.localizedDescription)"
                    } else {
                        self?.currentUser = fbUser
                    }
                }
        }
    }
    
    // MARK: - LOGIN
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = "Error al iniciar sesión: \(error.localizedDescription)"
                return
            }
            guard let user = result?.user else { return }
            // Cargar doc en Firestore
            self?.fetchUserDocument(uid: user.uid)
        }
    }
    
    // MARK: - LOGOUT
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
        } catch {
            self.errorMessage = "No se pudo cerrar sesión: \(error.localizedDescription)"
        }
    }
    
    // MARK: - OBTENER doc de Firestore
    private func fetchUserDocument(uid: String) {
        db.collection("users").document(uid).getDocument { [weak self] document, error in
            if let error = error {
                self?.errorMessage = "Error cargando usuario: \(error.localizedDescription)"
                return
            }
            guard let data = document?.data() else { return }
            if let fbUser = FBUser(id: uid, data: data) {
                self?.currentUser = fbUser
                
                // Si hay lecciones completadas, sincronizar con StageManager
                if !fbUser.completedLessons.isEmpty {
                    self?.syncCompletedLessonsWithStageManager(fbUser.completedLessons)
                }
            }
        }
    }
    
    // Nueva función para sincronizar lecciones completadas con StageManager
    private func syncCompletedLessonsWithStageManager(_ completedLessons: [String]) {
        guard let stageManager = stageManager else {
            print("⚠️ No se pudo sincronizar con StageManager: referencia no disponible")
            return
        }
        
        print("🔄 Sincronizando \(completedLessons.count) lecciones completadas desde Firestore")
        
        // Implementar sincronización aquí cuando sea necesario
        // Este es un placeholder para la función de sincronización completa
    }
    
    // MARK: - ACTUALIZAR XP
    func updateXP(newXP: Int) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ Error actualizando XP: usuario no autenticado")
            return
        }
        
        print("💎 Actualizando XP a \(newXP)")
        
        db.collection("users").document(uid)
            .updateData(["xp": newXP]) { [weak self] err in
                if let err = err {
                    self?.errorMessage = "Error actualizando XP: \(err.localizedDescription)"
                    print("❌ Error al guardar XP en Firestore: \(err.localizedDescription)")
                } else {
                    self?.currentUser?.xp = newXP
                    print("✅ XP actualizado correctamente en Firestore")
                }
            }
        
        // Actualizar XP en manager local si está disponible
        if let xpManager = xpManager {
            if xpManager.currentXP != newXP {
                // Solo sincronizar si es diferente para evitar ciclos
                print("🔄 Sincronizando XP con XPManager local")
                // Implementación específica dependiendo de la API de XPManager
            }
        }
    }
    
    // MARK: - COMPLETAR LECCIÓN
    func completeLesson(lessonID: String, stageIndex: Int? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ Error completando lección: usuario no autenticado")
            return
        }
        
        guard var updatedLessons = currentUser?.completedLessons else {
            print("❌ Error completando lección: no se pudo acceder a lecciones completadas")
            return
        }
        
        if !updatedLessons.contains(lessonID) {
            updatedLessons.append(lessonID)
            print("🔄 Añadiendo lección \(lessonID) a lecciones completadas")
        } else {
            print("ℹ️ La lección \(lessonID) ya estaba marcada como completada")
        }
        
        // Actualizar en Firestore
        db.collection("users").document(uid)
            .updateData(["completedLessons": updatedLessons]) { [weak self] err in
                if let err = err {
                    self?.errorMessage = "Error completando lección: \(err.localizedDescription)"
                    print("❌ Error al guardar lección completada en Firestore: \(err.localizedDescription)")
                } else {
                    self?.currentUser?.completedLessons = updatedLessons
                    print("✅ Lección guardada correctamente en Firestore")
                    
                    // Si se proporcionó un índice de etapa, completar lección en StageManager
                    if let stageIndex = stageIndex, let stageManager = self?.stageManager {
                        // Convertir string a UUID si es posible
                        if let lessonUUID = UUID(uuidString: lessonID) {
                            print("🔄 Sincronizando compleción con StageManager - Etapa: \(stageIndex), ID: \(lessonUUID)")
                            stageManager.completeLesson(stageIndex: stageIndex, lessonId: lessonUUID)
                        } else {
                            print("⚠️ No se pudo convertir \(lessonID) a UUID para StageManager")
                        }
                    }
                }
            }
    }
    
    // MARK: - MARCAR AL USUARIO COMO PREMIUM
    func setPremium() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ Error activando Premium: usuario no autenticado")
            return
        }
        
        db.collection("users").document(uid)
            .updateData(["premium": true]) { [weak self] err in
                if let err = err {
                    self?.errorMessage = "Error al activar Premium: \(err.localizedDescription)"
                    print("❌ Error al activar Premium en Firestore: \(err.localizedDescription)")
                } else {
                    self?.currentUser?.premium = true
                    print("✅ Cuenta actualizada a Premium correctamente")
                }
            }
    }
    
    // MARK: - REDEEM CODE
    func redeemCode(_ codeIngresado: String) {
        print("🔄 Verificando código Premium: \(codeIngresado)")
        
        db.collection("premiumCodes")
            .whereField("code", isEqualTo: codeIngresado)
            .whereField("used", isEqualTo: false)
            .getDocuments { [weak self] snap, error in
                if let error = error {
                    self?.errorMessage = "Error buscando código: \(error.localizedDescription)"
                    print("❌ Error al verificar código: \(error.localizedDescription)")
                    return
                }
                guard let docs = snap?.documents, !docs.isEmpty else {
                    self?.errorMessage = "Código inválido o ya fue usado."
                    print("⚠️ Código inválido o ya usado: \(codeIngresado)")
                    return
                }
                
                let doc = docs[0]
                let docID = doc.documentID
                print("✅ Código válido encontrado: \(docID)")
                
                // Marcar used = true
                self?.db.collection("premiumCodes")
                    .document(docID)
                    .updateData(["used": true]) { err in
                        if let err = err {
                            self?.errorMessage = "No se pudo marcar el código como usado: \(err.localizedDescription)"
                            print("❌ Error al marcar código como usado: \(err.localizedDescription)")
                            return
                        }
                        // Activar premium en el usuario
                        print("🔄 Código marcado como usado. Activando cuenta Premium...")
                        self?.setPremium()
                    }
            }
    }
}
