//
//  SignUpView.swift
//  worldbrainapp
//
import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var authVM = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Crear Cuenta")
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
            
            Button("Registrarme") {
                authVM.signUp(email: email, password: password)
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Spacer()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .onChange(of: authVM.currentUser) { newVal in
            if newVal != nil {
                // Cerrar esta vista y volver al Login
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

