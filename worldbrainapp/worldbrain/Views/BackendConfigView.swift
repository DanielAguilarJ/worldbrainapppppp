//
//  BackendConfigView.swift
//  WorldBrain
//
//  Vista para autenticación con Appwrite
//

import SwiftUI

struct BackendConfigView: View {
    @StateObject private var authManager = UnifiedAuthManager()
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isRegistering = false
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack {
                        Text("🔧 Autenticación")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Usando Appwrite como backend")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    
                    // Estado del backend
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🔗 Backend")
                            .font(.headline)
                        
                        HStack {
                            Circle()
                                .fill(Color.purple)
                                .frame(width: 8, height: 8)
                            
                            Text("Usando Appwrite")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Estado del usuario
                    VStack(alignment: .leading, spacing: 10) {
                        Text("👤 Estado de Autenticación")
                            .font(.headline)
                        
                        HStack {
                            Circle()
                                .fill(authManager.isLoggedIn ? Color.green : Color.red)
                                .frame(width: 8, height: 8)
                            
                            Text(authManager.isLoggedIn ? "✅ Logueado" : "❌ No logueado")
                                .foregroundColor(authManager.isLoggedIn ? .green : .red)
                            
                            Spacer()
                            
                            if authManager.isLoggedIn {
                                Button("Cerrar Sesión") {
                                    Task {
                                        await authManager.signOut()
                                    }
                                }
                                .disabled(isLoading)
                                .foregroundColor(.red)
                            }
                        }
                        
                        if let user = authManager.currentUser {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("📧 Email: \(user.email)")
                                    .font(.caption)
                                if let userName = user.name, !userName.isEmpty {
                                    Text("👤 Nombre: \(userName)")
                                        .font(.caption)
                                }
                                Text("💎 XP: \(user.xp)")
                                    .font(.caption)
                                Text("🎓 Lecciones: \(user.completedLessons.count)")
                                    .font(.caption)
                                Text("⭐ Premium: \(user.premium ? "Sí" : "No")")
                                    .font(.caption)
                            }
                            .padding(.top, 5)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Formulario de autenticación
                    if !authManager.isLoggedIn {
                        VStack(spacing: 15) {
                            Text(isRegistering ? "📝 Registro" : "🔐 Inicio de Sesión")
                                .font(.headline)
                            
                            if isRegistering {
                                TextField("Nombre", text: $name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            TextField("Email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            
                            SecureField("Contraseña", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            HStack(spacing: 10) {
                                Button(isRegistering ? "Registrarse" : "Iniciar Sesión") {
                                    Task {
                                        isLoading = true
                                        if isRegistering {
                                            await authManager.signUp(email: email, password: password, name: name.isEmpty ? nil : name)
                                        } else {
                                            await authManager.signIn(email: email, password: password)
                                        }
                                        isLoading = false
                                        
                                        if authManager.errorMessage != nil {
                                            alertMessage = authManager.errorMessage ?? "Error desconocido"
                                            showingAlert = true
                                        } else {
                                            // Limpiar campos si fue exitoso
                                            email = ""
                                            password = ""
                                            name = ""
                                        }
                                    }
                                }
                                .disabled(isLoading || email.isEmpty || password.isEmpty || (isRegistering && name.isEmpty))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(email.isEmpty || password.isEmpty || (isRegistering && name.isEmpty) ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                
                                Button(isRegistering ? "Ya tengo cuenta" : "Crear cuenta") {
                                    isRegistering.toggle()
                                    authManager.errorMessage = nil
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    }
                    
                    // Acciones de prueba
                    if authManager.isLoggedIn {
                        VStack(spacing: 10) {
                            Text("🧪 Acciones de Prueba")
                                .font(.headline)
                            
                            HStack(spacing: 10) {
                                Button("Añadir 100 XP") {
                                    Task {
                                        if let user = authManager.currentUser {
                                            await authManager.updateXP(newXP: user.xp + 100)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(8)
                                
                                Button("Completar Lección Test") {
                                    Task {
                                        await authManager.completeLesson(lessonID: "test_lesson_\(Date().timeIntervalSince1970)", earnedXP: 50)
                                    }
                                }
                                .padding()
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                            }
                            
                            Button("Actualizar Datos") {
                                Task {
                                    await authManager.refreshUserData()
                                }
                            }
                            .padding()
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(8)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    if isLoading {
                        ProgressView("Procesando...")
                            .padding()
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Backend Config")
            .alert("Mensaje", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

struct BackendConfigView_Previews: PreviewProvider {
    static var previews: some View {
        BackendConfigView()
    }
}
