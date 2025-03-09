//
//  RetentionExerciseView.swift
//  worldbrainapp
//
//  Created by Daniel on 24/01/2025.
//


//
//  RetentionExerciseView.swift
//  worldbrainapp
//
//  Vista principal del Ejercicio de Retención (lee x seg y contesta un quiz)
//

import SwiftUI

struct RetentionExerciseView: View {
    let exercise: RetentionExercise  // Lectura y preguntas
    
    // ---------- ESTADOS para la CUENTA REGRESIVA
    @State private var showCountdown = false
    @State private var countdownValue = 3
    
    // ---------- ESTADOS para MOSTRAR EL PÁRRAFO
    @State private var showParagraph = false
    @State private var timeLeft: Int = 0
    @State private var timer: Timer? = nil
    
    // ---------- ESTADOS para el QUIZ
    @State private var showingQuiz = false
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int?
    @State private var score = 0
    
    // Indica si falló el quiz y tiene que releer
    @State private var showFailView = false
    
    // Para poder cerrar esta vista con un .dismiss()
    @Environment(\.presentationMode) var presentationMode
    
    // Ajusta la puntuación mínima para “aprobar”
    private let minScoreToPass = 2
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if !showingQuiz {
                // Pantalla de introducción / cuenta atrás / párrafo
                buildReadingPhase()
            } else {
                // Pantalla del quiz o resultado
                buildQuizPhase()
            }
        }
        .onDisappear {
            // invalidar timer
            timer?.invalidate()
        }
    }
    
    // MARK: - PHASE 1: Lógica para la lectura (cuenta atrás + texto)
    private func buildReadingPhase() -> some View {
        VStack(spacing: 20) {
            Text("Ejercicio de Retención")
                .font(.title)
                .padding(.top, 40)
            
            if !showParagraph && !showCountdown {
                // Introducción inicial
                Text("""
                     Al iniciar, verás el texto por \(exercise.readingTime) segundos.
                     Después contestarás preguntas de memoria.
                     """)
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
                
            } else if showCountdown {
                // Conteo “3,2,1… ¡Fuera!”
                Text(countdownValue > 0 ? "\(countdownValue)" : "¡Fuera!")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.5).ignoresSafeArea())
                
            } else if showParagraph {
                // Párrafo + temporizador
                Text(exercise.paragraph)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .padding()
                
                Text("Tiempo restante: \(timeLeft)s")
                    .font(.headline)
                    .foregroundColor(.red)
                
                Spacer()
                
                Button("Terminar ahora") {
                    endReadingPhase()
                }
                .font(.headline)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            Spacer()
        }
    }
    
    // MARK: - PHASE 2: Lógica para el quiz
    private func buildQuizPhase() -> some View {
        VStack {
            if currentQuestionIndex < exercise.questions.count && !showFailView {
                // Muestra las preguntas
                let question = exercise.questions[currentQuestionIndex]
                
                Text("Pregunta \(currentQuestionIndex + 1) de \(exercise.questions.count)")
                    .font(.headline)
                    .padding(.top, 40)
                
                Text(question.text)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
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
                        // Verifica respuesta
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
                .padding(.top, 20)
                
                Spacer()
            }
            else {
                // Terminamos las preguntas o estamos en failView
                if showFailView {
                    // Vista de fallo (no pasa)
                    RetentionFailView(score: score, totalQuestions: exercise.questions.count) {
                        // Al presionar RELEER, se reinicia todo
                        resetExercise()
                    }
                } else {
                    // Evaluamos si pasó o no
                    checkQuizResult()
                }
            }
        }
    }
    
    // MARK: - HELPER: Verifica puntaje final
    private func checkQuizResult() -> some View {
        let totalQuestions = exercise.questions.count
        if score < minScoreToPass {
            // No pasó
            return AnyView(
                RetentionFailView(score: score, totalQuestions: totalQuestions) {
                    resetExercise()
                }
            )
        } else {
            // Pasó: pantalla final
            return AnyView(
                VStack(spacing: 20) {
                    Text("¡Ejercicio Completado!")
                        .font(.largeTitle)
                        .padding(.top, 40)
                    
                    Text("Aciertos: \(score) de \(totalQuestions)")
                        .font(.title2)
                        .padding(.horizontal)
                    
                    Button("Terminar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.headline)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    
                    Spacer()
                }
            )
        }
    }
    
    // MARK: - CICLO DE LECTURA
    
    /// Inicia la cuenta regresiva “3…2…1”
    private func startCountdown() {
        showCountdown = true
        countdownValue = 3
        
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
            startTimerForReading()
        }
    }
    
    /// Inicia el timer que decrementa el tiempo de lectura
    private func startTimerForReading() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                endReadingPhase()
            }
        }
    }
    
    /// Termina la fase de lectura, pasa al quiz
    private func endReadingPhase() {
        timer?.invalidate()
        timer = nil
        showParagraph = false
        showingQuiz = true
    }
    
    // MARK: - REINICIAR EJERCICIO SI FALLA
    /// Reinicia estados para que el usuario relea el texto y reintente
    private func resetExercise() {
        // Regresamos a la fase de lectura
        showParagraph = false
        showCountdown = false
        showingQuiz = false
        showFailView = false
        
        // Resetea score y preguntas
        score = 0
        currentQuestionIndex = 0
        selectedAnswer = nil
        
        // Lanza la cuenta atrás de nuevo
        startCountdown()
    }
}

// MARK: - RetentionFailView (Pantalla de “Fallo”, no aprobó el quiz)
struct RetentionFailView: View {
    let score: Int
    let totalQuestions: Int
    
    // Acción para reintentar
    var onRetry: () -> Void
    
    var body: some View {
        ZStack {
            Color.red.opacity(0.1).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Debes repasar el texto")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 40)
                
                Text("Aciertos: \(score) de \(totalQuestions)")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Text("No alcanzaste el mínimo requerido. Relee cuidadosamente antes de contestar.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                Button("RELEER") {
                    onRetry()
                }
                .font(.headline)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.bottom, 30)
            }
        }
    }
}
