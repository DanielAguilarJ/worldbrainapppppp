//
//  LoginView.swift
//  worldbrainapp
//
import SwiftUI

struct LoginView: View {
    @StateObject private var authVM = AuthViewModel()  // Maneja login
    
    @State private var email = ""
    @State private var password = ""
    
    // Para navegar a la vista principal cuando inicie sesión
    @State private var goToHome = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Iniciar Sesión")
                    .font(.largeTitle)
                    .padding(.top, 40)
                
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                SecureField("Contraseña", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                if let error = authVM.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Button("Acceder") {
                    authVM.signIn(email: email, password: password)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                NavigationLink("¿No tienes cuenta? Regístrate", destination: SignUpView())
                    .foregroundColor(.blue)
                
                Spacer()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            // OBSERVA EL CAMBIO de authVM.currentUser
            .onChange(of: authVM.currentUser) { newVal in
                if newVal != nil {
                    // Ir a la home (podrías presentar ContentView, etc.)
                    goToHome = true
                }
            }
            .background(
                // Navegación condicional
                NavigationLink(destination: MainTabView(), isActive: $goToHome) {
                    EmptyView()
                }
                .hidden()
            )
        }
    }
}

