//
//  AppwriteTestView.swift
//  WorldBrain
//
//  Vista de prueba para verificar la conexión con Appwrite
//

import SwiftUI

struct AppwriteTestView: View {
    @StateObject private var appwriteManager = AppwriteManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isRegistering = false
    @State private var message = ""
    @State private var isLoading = false
    @State private var pingResult = "No probado"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack {
                        Text("🚀 Appwrite Connection Test")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Proyecto ID: 683b7d7000153e36f0d8")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    
                    // Ping Test
                    VStack(alignment: .leading, spacing: 10) {
                        Text("📡 Test de Conexión")
                            .font(.headline)
                        
                        HStack {
                            Text("Estado: \(pingResult)")
                                .foregroundColor(pingResult == "✅ Conectado" ? .green : 
                                               pingResult == "❌ Error" ? .red : .orange)
                            
                            Spacer()
                            
                            Button("Probar Ping") {
                                Task {
                                    await testPing()
                                }
                            }
                            .disabled(isLoading)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Status del usuario
                    VStack(alignment: .leading, spacing: 10) {
                        Text("👤 Estado de Autenticación")
                            .font(.headline)
                        
                        HStack {
                            Text(appwriteManager.isLoggedIn ? "✅ Logueado" : "❌ No logueado")
                                .foregroundColor(appwriteManager.isLoggedIn ? .green : .red)
                            
                            Spacer()
                            
                            if appwriteManager.isLoggedIn {
                                Button("Cerrar Sesión") {
                                    Task {
                                        await logout()
                                    }
                                }
                                .disabled(isLoading)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    if !appwriteManager.isLoggedIn {
                        // Formulario de autenticación
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
                                        if isRegistering {
                                            await register()
                                        } else {
                                            await login()
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
                                    message = ""
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
                    
                    // Mensajes
                    if !message.isEmpty {
                        Text(message)
                            .padding()
                            .background(message.contains("Error") ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(message.contains("Error") ? .red : .green)
                    }
                    
                    if isLoading {
                        ProgressView("Procesando...")
                            .padding()
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Appwrite Test")
        }
        .onAppear {
            Task {
                await testPing()
            }
        }
    }
    
    private func testPing() async {
        await MainActor.run {
            pingResult = "🔄 Probando..."
        }
        
        let success = await appwriteManager.pingServer()
        
        await MainActor.run {
            pingResult = success ? "✅ Conectado" : "❌ Error"
        }
    }
    
    private func login() async {
        await MainActor.run {
            isLoading = true
            message = ""
        }
        
        do {
            _ = try await appwriteManager.login(email: email, password: password)
            await MainActor.run {
                message = "✅ Inicio de sesión exitoso"
                email = ""
                password = ""
            }
        } catch {
            await MainActor.run {
                message = "❌ Error: \(error.localizedDescription)"
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    private func register() async {
        await MainActor.run {
            isLoading = true
            message = ""
        }
        
        do {
            _ = try await appwriteManager.register(email: email, password: password, name: name)
            await MainActor.run {
                message = "✅ Registro exitoso"
                email = ""
                password = ""
                name = ""
                isRegistering = false
            }
        } catch {
            await MainActor.run {
                message = "❌ Error: \(error.localizedDescription)"
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    private func logout() async {
        await MainActor.run {
            isLoading = true
            message = ""
        }
        
        do {
            try await appwriteManager.logout()
            await MainActor.run {
                message = "✅ Sesión cerrada"
            }
        } catch {
            await MainActor.run {
                message = "❌ Error cerrando sesión: \(error.localizedDescription)"
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
}

struct AppwriteTestView_Previews: PreviewProvider {
    static var previews: some View {
        AppwriteTestView()
    }
}
