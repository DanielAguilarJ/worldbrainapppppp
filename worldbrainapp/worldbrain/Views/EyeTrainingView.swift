//
//  EyeExerciseView.swift
//  worldbrainapp
//
//  Ejemplo completo con entrenamientos oculares y cuenta regresiva
//

import SwiftUI

// MARK: - MODELO DE EJERCICIO Y ENUM

enum EyeExerciseType {
    case dotTracking
    case horizontalMovement
    case verticalMovement
    case circularMovement
    case peripheralVision
    case focusChange
    case palmingExercise
    case diagonalMovement
}

struct EyeExercise {
    let type: EyeExerciseType
    let duration: Int       // No se usa estrictamente en este ejemplo, pero puedes aprovecharlo si deseas un temporizador
    let instructions: String
}

// MARK: - SUBVISTAS DE EJERCICIOS (puedes modificar o ampliar)

struct DotTrackingExercise: View {
    // Ejemplo mínimo: se mueve un punto en diagonal
    @State private var dotPosition = CGPoint(x: 20, y: 20)
    @State private var movingRight = true
    
    var body: some View {
        GeometryReader { geo in
            Circle()
                .fill(Color.red)
                .frame(width: 20, height: 20)
                .position(dotPosition)
                .onAppear {
                    // Animación simple: mover de izquierda a derecha repetidamente
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: true)) {
                        dotPosition = CGPoint(x: geo.size.width - 20, y: geo.size.height - 20)
                    }
                }
        }
    }
}

struct HorizontalMovementExercise: View {
    @State private var isMovingRight = false
    
    var body: some View {
        Circle()
            .fill(Color.red)
            .frame(width: 20, height: 20)
            .offset(x: isMovingRight ? 150 : -150)
            .animation(.linear(duration: 2).repeatForever(autoreverses: true), value: isMovingRight)
            .onAppear {
                isMovingRight.toggle()
            }
    }
}

struct VerticalMovementExercise: View {
    @State private var isMovingUp = false
    
    var body: some View {
        Circle()
            .fill(Color.red)
            .frame(width: 20, height: 20)
            .offset(y: isMovingUp ? -100 : 100)
            .animation(.linear(duration: 2).repeatForever(autoreverses: true), value: isMovingUp)
            .onAppear {
                isMovingUp.toggle()
            }
    }
}

struct CircularMovementExercise: View {
    @State private var angle: Double = 0
    
    var body: some View {
        Circle()
            .fill(Color.red)
            .frame(width: 20, height: 20)
            .offset(y: -100)
            .rotationEffect(.degrees(angle))
            .animation(.linear(duration: 4).repeatForever(autoreverses: false), value: angle)
            .onAppear {
                angle = 360
            }
    }
}

struct PeripheralVisionExercise: View {
    var body: some View {
        Text("Ejercicio de Visión Periférica")
            .font(.title3)
            .foregroundColor(.blue)
    }
}

struct FocusChangeExercise: View {
    var body: some View {
        Text("Ejercicio de Cambio de Enfoque")
            .font(.title3)
            .foregroundColor(.blue)
    }
}

struct PalmingExerciseView: View {
    var body: some View {
        Text("Ejercicio de Palming")
            .font(.title3)
            .foregroundColor(.blue)
    }
}

struct DiagonalMovementExercise: View {
    var body: some View {
        Text("Ejercicio de Movimiento Diagonal")
            .font(.title3)
            .foregroundColor(.blue)
    }
}

// MARK: - VISTA PRINCIPAL DE ENTRENAMIENTO OCULAR
struct EyeExerciseView: View {
    let exercise: EyeExercise
    
    // Control de estados para la cuenta regresiva
    @State private var countdownActive = false
    @State private var countdownValue = 3
    
    // Control de si el ejercicio está en progreso
    @State private var exerciseInProgress = false
    
    // Para mostrar alerta de salir
    @State private var showingExitAlert = false
    
    // Ambiente para cerrar la vista si pulsamos “Salir”
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // ENCABEZADO
                HStack {
                    // Botón “Atrás”
                    Button {
                        showingExitAlert = true
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text("Entrenamiento Ocular")
                        .font(.headline)
                    
                    Spacer()
                    Spacer().frame(width: 20)
                }
                .padding(.top, 50)
                .padding(.horizontal)
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
                
                // Instrucciones (las del EyeExercise)
                Text(exercise.instructions)
                    .font(.title3)
                    .padding()
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                // ZONA DONDE SE MUESTRA EL EJERCICIO
                ZStack {
                    if exerciseInProgress {
                        // Según el tipo de ejercicio, mostramos una sub-vista
                        switch exercise.type {
                        case .dotTracking:
                            DotTrackingExercise()
                        case .horizontalMovement:
                            HorizontalMovementExercise()
                        case .verticalMovement:
                            VerticalMovementExercise()
                        case .circularMovement:
                            CircularMovementExercise()
                        case .peripheralVision:
                            PeripheralVisionExercise()
                        case .focusChange:
                            FocusChangeExercise()
                        case .palmingExercise:
                            PalmingExerciseView()
                        case .diagonalMovement:
                            DiagonalMovementExercise()
                        }
                    } else {
                        // Texto mientras no se inicie
                        Text("El ejercicio ocular se mostrará al terminar la cuenta regresiva.")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 300)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                
                Spacer()
                
                // BOTONES
                if !exerciseInProgress && !countdownActive {
                    // Botón para iniciar
                    Button("Iniciar Ejercicio Ocular") {
                        startCountdown()
                    }
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    
                } else if exerciseInProgress {
                    // Botón para terminar
                    Button("Terminar Ejercicio") {
                        endExercise()
                    }
                    .font(.headline)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            
            // OVERLAY de cuenta regresiva
            if countdownActive {
                Color.black.opacity(0.5).ignoresSafeArea()
                Text(countdownValue > 0 ? "\(countdownValue)" : "¡Fuera!")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.white)
                    .transition(.scale)
            }
        }
        // ALERTA de salida
        .alert(isPresented: $showingExitAlert) {
            Alert(
                title: Text("¿Salir del ejercicio?"),
                message: Text("¿Deseas interrumpir el entrenamiento ocular?"),
                primaryButton: .destructive(Text("Salir")) {
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel(Text("Continuar"))
            )
        }
    }
    
    // MARK: - Métodos
    
    /// Inicia la cuenta regresiva de 3 segundos
    private func startCountdown() {
        countdownActive = true
        countdownValue = 3
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            countdownValue = 2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            countdownValue = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            countdownActive = false
            exerciseInProgress = true
        }
    }
    
    /// Terminar ejercicio
    private func endExercise() {
        exerciseInProgress = false
        presentationMode.wrappedValue.dismiss()
    }
}

