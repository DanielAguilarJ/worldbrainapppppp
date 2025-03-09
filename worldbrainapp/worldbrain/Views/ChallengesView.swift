//
//  ChallengesView.swift
//  worldbrainapp
//
//  Muestra un gradiente y un card con “Ejercicio de Retención Aleatorio”
//

import SwiftUI

struct ChallengesView: View {
    @State private var showingRetentionSheet = false
    @State private var selectedExercise: RetentionExercise? = nil
    
    var body: some View {
        ZStack {
            // FONDO GRADIENTE
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.green]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)
            
            VStack(spacing: 0) {
                // Titulo
                Text("Desafíos")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 60)
                    .padding(.bottom, 20)
                
                // Card con Retención
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ejercicio de Retención")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Lee y responde")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Spacer().frame(height: 12)
                            
                            Button(action: {
                                if let random = retentionExercises.randomElement() {
                                    selectedExercise = random
                                    showingRetentionSheet = true
                                }
                            }) {
                                Text("INICIAR")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(Color.blue)
                                    .cornerRadius(20)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "brain.head.profile")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.green)
                            .padding(.trailing, 8)
                    }
                    .padding(16)
                }
                .frame(height: 120)
                .padding(.horizontal, 16)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingRetentionSheet, onDismiss: {
            // Volver a nil para que la próxima vez se re-randomice
            selectedExercise = nil
        }) {
            if let exercise = selectedExercise {
                RetentionExerciseView(exercise: exercise)
            }
        }
    }
}

