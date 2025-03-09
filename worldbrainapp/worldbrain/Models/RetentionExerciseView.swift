//
//  RetentionExerciseView.swift
//  worldbrainapp
//
import SwiftUI

struct RetentionExerciseView: View {
    let exercise: RetentionExercise
    
    // ESTADOS LECTURA
    @State private var showCountdown = false
    @State private var countdownValue = 3
    @State private var showParagraph = false
    @State private var timeLeft: Int = 0
    @State private var timer: Timer? = nil
    
    // ESTADOS QUIZ
    @State private var showingQuiz = false
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int?
    @State private var score = 0
    
    // FALLA => relectura
    @State private var showFailView = false
    
    // BOTÓN CERRAR
    @Environment(\.dismiss) private var dismissSheet
    
    // Para XP local (solo demostración). Si ya tienes XPManager, úsalo en su lugar.
    @State private var xpActual = UserDefaults.standard.integer(forKey: "userXP")
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if !showingQuiz {
                buildReadingPhase()
            } else {
                buildQuizPhase()
            }
            
            // Botón “Cerrar (X)” arriba a la izquierda
            VStack {
                HStack {
                    Button(action: {
                        dismissSheet()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                            .padding()
                    }
                    Spacer()
                }
                Spacer()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // MARK: - Lectura
    private func buildReadingPhase() -> some View {
        VStack(spacing: 20) {
            Text("Ejercicio de Retención")
                .font(.title)
                .padding(.top, 40)
            
            if !showParagraph && !showCountdown {
                // Presentación inicial
                Text("Al iniciar, tendrás \(exercise.readingTime) seg para leer. Luego responde el quiz.")
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
                // Conteo “3,2,1”
                Text(countdownValue > 0 ? "\(countdownValue)" : "¡Fuera!")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.5).ignoresSafeArea())
                
            } else if showParagraph {
                // Texto
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
    
    // MARK: - Quiz
    private func buildQuizPhase() -> some View {
        VStack {
            // No entres al quiz si showFailView==true, a menos que “releer”
            if currentQuestionIndex < exercise.questions.count && !showFailView {
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
                            .background(
                                selectedAnswer == i ? Color.blue : Color.gray.opacity(0.2)
                            )
                            .foregroundColor(selectedAnswer == i ? .white : .black)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                Button("Siguiente") {
                    if let sel = selectedAnswer {
                        // Revisar respuesta
                        if sel == question.correctIndex {
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
                // Terminamos las preguntas o showFailView
                if showFailView {
                    // Vista de fallo
                    RetentionFailView(
                        score: score,
                        totalQuestions: exercise.questions.count
                    ) {
                        resetExercise()
                    }
                } else {
                    // Check final
                    checkQuizResult()
                }
            }
        }
    }
    
    // Evaluamos si pasa y sumamos 35 XP
    private func checkQuizResult() -> some View {
        let totalQ = exercise.questions.count
        
        // Aprobado si aciertos >= 50%
        // Ej: 2 preguntas => con 1 acierto(=50%) pasa; 4 preg => 2 aciertos => 50%
        let passThreshold = Int((Double(totalQ) * 0.5).rounded(.up))
        
        if score < passThreshold {
            // Falló
            return AnyView(
                RetentionFailView(
                    score: score,
                    totalQuestions: totalQ
                ) {
                    resetExercise()
                }
            )
        } else {
            // Aprobado => sumamos 35 XP
            xpActual += 35
            UserDefaults.standard.set(xpActual, forKey: "userXP")
            
            return AnyView(
                VStack(spacing: 20) {
                    Text("¡Ejercicio Completado!")
                        .font(.largeTitle)
                        .padding(.top, 40)
                    
                    Text("Aciertos: \(score) de \(totalQ)")
                        .font(.title2)
                    
                    Text("¡Has ganado 35 XP!")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Button("Terminar") {
                        dismissSheet() // cierra la vista
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
    
    // MARK: - Lógica Lectura
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
            startReadingTimer()
        }
    }
    
    private func startReadingTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                endReadingPhase()
            }
        }
    }
    
    private func endReadingPhase() {
        timer?.invalidate()
        timer = nil
        showParagraph = false
        showingQuiz = true
    }
    
    // Reiniciar todo (usuario falló)
    private func resetExercise() {
        showParagraph = false
        showCountdown = false
        showingQuiz = false
        showFailView = false
        
        score = 0
        currentQuestionIndex = 0
        selectedAnswer = nil
        
        startCountdown()
    }
}

// MARK: - Vista de “Fallo”
struct RetentionFailView: View {
    let score: Int
    let totalQuestions: Int
    
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
                
                Text("No alcanzaste el mínimo para aprobar. Vuelve a leer cuidadosamente.")
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

