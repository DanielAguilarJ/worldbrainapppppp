//
//  RetentionExerciseView.swift
//  worldbrainapp
//
import SwiftUI

struct RetentionExerciseView: View {
    let exercise: RetentionExercise
    @ObservedObject var xpManager: XPManager
    
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
    @State private var incorrectAnswers = 0
    
    // FALLA => relectura
    @State private var showFailView = false
    
    // RESUMEN FINAL
    @State private var showCompletionView = false
    @State private var earnedXP = 0
    @State private var xpUpdated = false
    @State private var timeUsed = 0
    
    // BOTÓN CERRAR
    @Environment(\.presentationMode) var presentationMode
    
    // Cálculo de estrellas basado en porcentaje de aciertos
    var stars: Int {
        let percentage = Double(score) / Double(exercise.questions.count)
        
        if percentage == 1.0 {
            return 3    // 100% correcto - 3 estrellas
        } else if percentage >= 0.75 {
            return 2    // 75%+ correcto - 2 estrellas
        } else if percentage >= 0.5 {
            return 1    // 50%+ correcto - 1 estrella
        } else {
            return 0    // Menos del 50%
        }
    }
    
    // Mensaje de rendimiento basado en estrellas
    var performanceMessage: String {
        switch stars {
        case 3:
            return "¡Excelente! Tu retención de información es perfecta."
        case 2:
            return "¡Muy bien! Has recordado la mayoría de la información."
        case 1:
            return "¡Bien! Has recordado información importante."
        default:
            return "Continúa practicando para mejorar tu retención."
        }
    }
    
    // Cálculo de XP basado en score y tiempo
    var calculatedXP: Int {
        // Base: 15XP por respuesta correcta
        let baseXP = score * 15
        
        // Bonus por completar todo correctamente
        let perfectBonus = score == exercise.questions.count ? 20 : 0
        
        return baseXP + perfectBonus
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fondo
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.4)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Barra superior con botón de cerrar - ahora fijada con safeAreaInset
                    Color.clear.frame(height: 0)
                        .safeAreaInset(edge: .top) {
                            HStack {
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    HStack {
                                        Image(systemName: "xmark.circle.fill")
                                        Text("Cerrar")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(Color.red.opacity(0.8))
                                    .cornerRadius(20)
                                }
                                
                                Spacer()
                                
                                Text("Ejercicio de Retención")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                // Vista de XP - para balancear visualmente
                                Text("")
                                    .font(.headline)
                                    .frame(width: 90)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 4)
                            .background(Color.black.opacity(0.2))
                        }
                    
                    // Contenido principal
                    if showCompletionView {
                        // Vista de resumen final
                        CompletionView()
                    } else if !showingQuiz {
                        buildReadingPhase()
                    } else {
                        buildQuizPhase()
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onDisappear {
            timer?.invalidate()
            
            // Asegurar que XP se actualiza al desaparecer si no se ha hecho antes
            if !xpUpdated && score > 0 {
                earnedXP = calculatedXP
                xpManager.addXP(earnedXP)
                xpUpdated = true
            }
        }
    }
    
    // MARK: - Lectura
    private func buildReadingPhase() -> some View {
        VStack(spacing: 20) {
            if !showParagraph && !showCountdown {
                // Presentación inicial
                VStack(spacing: 20) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Text("Ejercicio de Retención")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Tendrás \(exercise.readingTime) segundos para leer el texto. Luego responderás preguntas sobre lo que leíste.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                        .padding(.horizontal, 20)
                    
                    Button(action: {
                        startCountdown()
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Comenzar")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(Color.blue)
                        .cornerRadius(15)
                        .shadow(radius: 3)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if showCountdown {
                // Conteo "3,2,1"
                VStack(spacing: 20) {
                    Spacer()
                    
                    Text("Prepárate para leer")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 150, height: 150)
                        
                        Circle()
                            .stroke(Color.white, lineWidth: 5)
                            .frame(width: 150, height: 150)
                        
                        Text(countdownValue > 0 ? "\(countdownValue)" : "¡Lee!")
                            .font(.system(size: 70, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.6))
                
            } else if showParagraph {
                // Texto a leer
                VStack {
                    // Tiempo restante
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 50)
                        
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(.white)
                            
                            Text("\(timeLeft)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("segundos")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Texto para leer
                    ScrollView {
                        Text(exercise.paragraph)
                            .font(.system(size: 18))
                            .lineSpacing(8)
                            .foregroundColor(.white)
                            .padding(20)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(15)
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 10)
                    
                    Spacer()
                    
                    // Botón de terminar
                    Button(action: {
                        endReadingPhase()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text("He terminado de leer")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(Color.green)
                        .cornerRadius(15)
                    }
                    .padding(.bottom, 30)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    // MARK: - Quiz
    private func buildQuizPhase() -> some View {
        VStack(spacing: 0) {
            // Progreso del quiz
            HStack {
                Text("\(currentQuestionIndex + 1)/\(exercise.questions.count)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(20)
                
                Spacer()
                
                // Vista de XP actual
                VStack {
                    Text("XP")
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    Text("\(calculatedXP)")
                        .font(.headline.bold())
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 15)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            // No entres al quiz si showFailView==true, a menos que "releer"
            if currentQuestionIndex < exercise.questions.count && !showFailView {
                let question = exercise.questions[currentQuestionIndex]
                
                VStack(alignment: .leading, spacing: 20) {
                    Text(question.text)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 20)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        ForEach(0..<question.options.count, id: \.self) { i in
                            Button(action: {
                                selectedAnswer = i
                            }) {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .stroke(selectedAnswer == i ? Color.white : Color.white.opacity(0.5), lineWidth: 2)
                                            .frame(width: 24, height: 24)
                                        
                                        if selectedAnswer == i {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 12, height: 12)
                                        }
                                    }
                                    
                                    Text(question.options[i])
                                        .font(.system(size: 17))
                                        .foregroundColor(.white)
                                        .padding(.leading, 10)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedAnswer == i ? Color.blue : Color.black.opacity(0.2))
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button("Siguiente") {
                        if let sel = selectedAnswer {
                            // Revisar respuesta
                            if sel == question.correctIndex {
                                score += 1
                            } else {
                                incorrectAnswers += 1
                            }
                            currentQuestionIndex += 1
                            selectedAnswer = nil
                            
                            // Si terminamos todas las preguntas, calcular XP
                            if currentQuestionIndex >= exercise.questions.count {
                                earnedXP = calculatedXP
                                timeUsed = exercise.readingTime - timeLeft
                                
                                // Verificar si pasó el umbral mínimo
                                let passThreshold = Int((Double(exercise.questions.count) * 0.5).rounded(.up))
                                if score < passThreshold {
                                    showFailView = true
                                } else {
                                    // Actualizar XP
                                    if !xpUpdated {
                                        xpManager.addXP(earnedXP)
                                        xpUpdated = true
                                    }
                                    
                                    // Mostrar resumen
                                    showCompletionView = true
                                }
                            }
                        }
                    }
                    .disabled(selectedAnswer == nil)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedAnswer == nil ? Color.gray : Color.green)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if showFailView {
                // Vista de fallo mejorada
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 70))
                        .foregroundColor(.yellow)
                        .padding(.top, 40)
                    
                    Text("¡Necesitas repasar el texto!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Aciertos: \(score) de \(exercise.questions.count)")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("No alcanzaste el mínimo necesario para aprobar. Vuelve a leer cuidadosamente.")
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    Button(action: {
                        resetExercise()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Leer de nuevo")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Salir")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.vertical, 10)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    // MARK: - Vista de Resumen Final
    @ViewBuilder
    private func CompletionView() -> some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("¡Ejercicio Completado!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(performanceMessage)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Estrellas ganadas
            HStack(spacing: 15) {
                ForEach(1...3, id: \.self) { index in
                    Image(systemName: index <= stars ? "star.fill" : "star")
                        .font(.system(size: 45))
                        .foregroundColor(index <= stars ? .yellow : .gray.opacity(0.5))
                        .shadow(color: index <= stars ? .orange.opacity(0.7) : .clear, radius: 5)
                }
            }
            .padding(.vertical, 10)
            
            // Resumen de puntuación
            VStack(spacing: 16) {
                // Puntuación
                SummaryRow(
                    title: "Respuestas correctas",
                    value: "\(score) de \(exercise.questions.count)",
                    iconName: "checkmark.circle.fill",
                    color: .green
                )
                
                // Errores
                SummaryRow(
                    title: "Respuestas incorrectas",
                    value: "\(incorrectAnswers)",
                    iconName: "xmark.circle.fill",
                    color: .red
                )
                
                // Tiempo de lectura
                SummaryRow(
                    title: "Tiempo usado",
                    value: "\(timeUsed)s",
                    iconName: "timer",
                    color: .blue
                )
                
                // XP ganado
                SummaryRow(
                    title: "XP ganado",
                    value: "+\(earnedXP)",
                    iconName: "sparkles",
                    color: .yellow
                )
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(15)
            
            // Botones de acción
            HStack(spacing: 20) {
                Button(action: {
                    resetExercise()
                    showCompletionView = false
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Repetir")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 15)
                    .background(Color.blue)
                    .cornerRadius(15)
                }
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Text("Finalizar")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 15)
                    .background(Color.purple)
                    .cornerRadius(15)
                }
            }
            .padding(.top, 10)
        }
        .padding(25)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func SummaryRow(title: String, value: String, iconName: String, color: Color) -> some View {
        HStack {
            Image(systemName: iconName)
                .font(.system(size: 22))
                .foregroundColor(color)
                .frame(width: 35)
            
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
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
    
    // Reiniciar todo (usuario falló o quiere repetir)
    private func resetExercise() {
        showParagraph = false
        showCountdown = false
        showingQuiz = false
        showFailView = false
        showCompletionView = false
        
        score = 0
        incorrectAnswers = 0
        currentQuestionIndex = 0
        selectedAnswer = nil
        xpUpdated = false
        
        startCountdown()
    }
}

// Vista previa para debugging
struct RetentionExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        RetentionExerciseView(
            exercise: retentionExercises[0],
            xpManager: XPManager()
        )
    }
}
