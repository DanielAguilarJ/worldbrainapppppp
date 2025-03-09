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
    
    init() {
        // Ver si hay un usuario de FirebaseAuth
        if let user = Auth.auth().currentUser {
            fetchUserDocument(uid: user.uid)
        }
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
            }
        }
    }
    
    // MARK: - ACTUALIZAR XP
    func updateXP(newXP: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid)
            .updateData(["xp": newXP]) { [weak self] err in
                if let err = err {
                    self?.errorMessage = "Error actualizando XP: \(err.localizedDescription)"
                } else {
                    self?.currentUser?.xp = newXP
                }
            }
    }
    
    // MARK: - COMPLETAR LECCIÓN
    func completeLesson(lessonID: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard var updatedLessons = currentUser?.completedLessons else { return }
        
        if !updatedLessons.contains(lessonID) {
            updatedLessons.append(lessonID)
        }
        
        db.collection("users").document(uid)
            .updateData(["completedLessons": updatedLessons]) { [weak self] err in
                if let err = err {
                    self?.errorMessage = "Error completando lección: \(err.localizedDescription)"
                } else {
                    self?.currentUser?.completedLessons = updatedLessons
                }
            }
    }
    
    // MARK: - MARCAR AL USUARIO COMO PREMIUM
    func setPremium() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid)
            .updateData(["premium": true]) { [weak self] err in
                if let err = err {
                    self?.errorMessage = "Error al activar Premium: \(err.localizedDescription)"
                } else {
                    self?.currentUser?.premium = true
                }
            }
    }
    
    // MARK: - REDEEM CODE
    func redeemCode(_ codeIngresado: String) {
        db.collection("premiumCodes")
            .whereField("code", isEqualTo: codeIngresado)
            .whereField("used", isEqualTo: false)
            .getDocuments { [weak self] snap, error in
                if let error = error {
                    self?.errorMessage = "Error buscando código: \(error.localizedDescription)"
                    return
                }
                guard let docs = snap?.documents, !docs.isEmpty else {
                    self?.errorMessage = "Código inválido o ya fue usado."
                    return
                }
                let doc = docs[0]
                let docID = doc.documentID
                
                // Marcar used = true
                self?.db.collection("premiumCodes")
                    .document(docID)
                    .updateData(["used": true]) { err in
                        if let err = err {
                            self?.errorMessage = "No se pudo marcar el código como usado: \(err.localizedDescription)"
                            return
                        }
                        // Activar premium en el usuario
                        self?.setPremium()
                    }
            }
    }
}

