//
//  RedeemCodeView.swift
//  worldbrainapp
//
//  Created by Daniel on 24/01/2025.
//


import SwiftUI

struct RedeemCodeView: View {
    @ObservedObject var authVM: AuthViewModel
    @State private var codeIngresado = ""
    
    var body: some View {
        VStack {
            TextField("Ingresa tu código", text: $codeIngresado)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Canjear") {
                authVM.redeemCode(codeIngresado)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            if let error = authVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
        }
        .navigationTitle("Canjear Código Premium")
    }
}
