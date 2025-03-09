//
//  RetentionExerciseView.swift
//  worldbrainapp
//
//  Ejemplo completo de Ejercicio de Retención con cuenta regresiva y quiz
//

import SwiftUI

// MARK: - Modelo de Pregunta y Ejercicio

/// Tipo de pregunta (para posibles extensiones)
enum RetentionQuestionType {
    case multipleChoice
}

/// Estructura para cada pregunta
struct RetentionQuestion {
    let text: String
    let options: [String]
    let correctIndex: Int
}

/// Estructura para un ejercicio de retención
struct RetentionExercise {
    /// Párrafo a memorizar
    let paragraph: String
    /// Tiempo (en segundos) que se mostrará el texto
    let readingTime: Int
    /// Listado de preguntas a responder
    let questions: [RetentionQuestion]
}

// MARK: - Vista principal del Ejercicio de Retención

struct RetentionExerciseView: View {
    let exercise: RetentionExercise
    
    // Estados para la cuenta regresiva inicial (3,2,1)
    @State private var showCountdown = false
    @State private var countdownValue = 3
    
    // Estados para mostrar el párrafo
    @State private var showParagraph = false
    @State private var timeLeft: Int = 0
    @State private var timer: Timer? = nil
    
    // Estados para el quiz final
    @State private var showingQuiz = false
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int?
    @State private var score = 0
    
    // Ambiente para poder cerrar la vista si se desea
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if !showingQuiz {
                // Antes de entrar al quiz
                VStack(spacing: 20) {
                    Text("Ejercicio de Retención")
                        .font(.title)
                        .padding(.top, 50)
                    
                    // Parte inicial
                    if !showParagraph && !showCountdown {
                        Text("Al iniciar, verás el texto por \(exercise.readingTime) segundos.\nDespués contestarás preguntas de memoria.")
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button("Iniciar Ejercicio") {
                            startCountdown()
                        }
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        
                    // Modo cuenta regresiva: 3,2,1
                    } else if showCountdown {
                        // Texto grande en el centro
                        Text(countdownValue > 0 ? "\(countdownValue)" : "¡Fuera!")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5).ignoresSafeArea())
                        
                    // Mostramos el párrafo
                    } else if showParagraph {
                        Text(exercise.paragraph)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .padding()
                        
                        Text("Tiempo restante: \(timeLeft)s")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Spacer()
                        
                        // Botón para terminar manualmente la lectura
                        Button("Terminar ahora") {
                            endParagraphDisplay()
                        }
                        .font(.headline)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
            } else {
                // Cuestionario
                if currentQuestionIndex < exercise.questions.count {
                    let question = exercise.questions[currentQuestionIndex]
                    
                    VStack(spacing: 20) {
                        Text("Pregunta \(currentQuestionIndex + 1) de \(exercise.questions.count)")
                            .font(.headline)
                            .padding(.top, 40)
                        
                        Text(question.text)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        ForEach(0..<question.options.count, id: \.self) { i in
                            Button(action: {
                                selectedAnswer = i
                            }) {
                                Text(question.options[i])
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(selectedAnswer == i ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedAnswer == i ? .white : .black)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        
                        Button("Siguiente") {
                            if let selected = selectedAnswer {
                                if selected == question.correctIndex {
                                    score += 1
                                }
                                currentQuestionIndex += 1
                                selectedAnswer = nil
                            }
                        }
                        .disabled(selectedAnswer == nil)
                        .padding()
                        .background(selectedAnswer == nil ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Spacer()
                    }
                    
                } else {
                    // Al terminar el quiz
                    VStack(spacing: 20) {
                        Text("¡Ejercicio Completado!")
                            .font(.largeTitle)
                            .padding(.top, 40)
                        
                        Text("Aciertos: \(score) de \(exercise.questions.count)")
                            .font(.title2)
                        
                        Button("Terminar") {
                            // Aquí podrías sumar XP si quieres:
                            // xpManager.addXP(50)
                            presentationMode.wrappedValue.dismiss()
                        }
                        .font(.headline)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        
                        Spacer()
                    }
                }
            }
        }
        .onDisappear {
            // invalidar timer para evitar fugas
            timer?.invalidate()
        }
    }
    
    // MARK: - Métodos
    
    /// Inicia la cuenta regresiva de 3 segundos antes de mostrar el texto
    private func startCountdown() {
        showCountdown = true
        countdownValue = 3
        
        // Countdown “3,2,1…”
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            countdownValue = 2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            countdownValue = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showCountdown = false
            showParagraph = true
            timeLeft = exercise.readingTime
            startParagraphTimer()
        }
    }
    
    /// Inicia un timer para ocultar el párrafo al acabar `readingTime` segundos
    private func startParagraphTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                endParagraphDisplay()
            }
        }
    }
    
    /// Termina la lectura y pasa a mostrar el quiz
    private func endParagraphDisplay() {
        timer?.invalidate()
        timer = nil
        showParagraph = false
        showingQuiz = true
    }
}
