//
//  ChallengesView.swift
//  worldbrainapp
//
//  Muestra un gradiente y cards para los diferentes desafíos
//

import SwiftUI

struct ChallengesView: View {
    @StateObject var xpManager = XPManager()
    @State private var showingRetentionSheet = false
    @State private var showingWordPairsFullScreen = false
    @State private var showingWordInequalityFullScreen = false
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
            
            ScrollView {
                VStack(spacing: 20) {
                    // Titulo
                    Text("Desafíos")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 60)
                        .padding(.bottom, 20)
                    
                    // Card con Retención
                    ChallengeCard(
                        title: "Ejercicio de Retención",
                        description: "Lee y responde",
                        iconName: "brain.head.profile",
                        iconColor: .green,
                        action: {
                            if let random = retentionExercises.randomElement() {
                                selectedExercise = random
                                showingRetentionSheet = true
                            }
                        }
                    )
                    
                    // Card con Pares de Palabras Iguales
                    ChallengeCard(
                        title: "Pares de Palabras",
                        description: "Encuentra el mayor número posible de pares de palabras",
                        iconName: "text.bubble.fill",
                        iconColor: .orange,
                        action: {
                            showingWordPairsFullScreen = true
                        }
                    )
                    
                    // Card con Palabras Desiguales
                    ChallengeCard(
                        title: "Palabras Desiguales",
                        description: "Encuentra pares de palabras diferentes y evita los idénticos",
                        iconName: "character.textbox",
                        iconColor: .purple,
                        action: {
                            showingWordInequalityFullScreen = true
                        }
                    )
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
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
        .fullScreenCover(isPresented: $showingWordPairsFullScreen) {
            WordPairsView(xpManager: xpManager)
        }
        .fullScreenCover(isPresented: $showingWordInequalityFullScreen) {
            WordInequalityView(xpManager: xpManager)
        }
    }
}

// Componente reutilizable para las tarjetas de desafío
struct ChallengeCard: View {
    let title: String
    let description: String
    let iconName: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Spacer().frame(height: 12)
                        
                        Text("INICIAR")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.blue)
                            .cornerRadius(20)
                    }
                    
                    Spacer()
                    
                    Image(systemName: iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(iconColor)
                        .padding(.trailing, 8)
                }
                .padding(16)
            }
            .frame(height: 120)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
