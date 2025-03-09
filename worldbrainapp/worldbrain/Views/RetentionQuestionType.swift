//import SwiftUI
//
//// MARK: - Modelo de Pregunta y Ejercicio
//enum RetentionQuestionType {
//    case multipleChoice
//}
//
//struct RetentionQuestion {
//    let text: String
//    let options: [String]
//    let correctIndex: Int
//}
//
//struct RetentionExercise {
//    let paragraph: String
//    let readingTime: Int
//    let questions: [RetentionQuestion]
//}
//
//// MARK: - Vista principal del Ejercicio de Retención
//
//struct RetentionExerciseView: View {
//    let exercise: RetentionExercise
//    
//    // Estados para cuenta regresiva
//    @State private var showCountdown = false
//    @State private var countdownValue = 3
//    
//    // Estados para mostrar el párrafo
//    @State private var showParagraph = false
//    @State private var timeLeft: Int = 0
//    @State private var timer: Timer? = nil
//    
//    // Estados para el quiz
//    @State private var showingQuiz = false
//    @State private var currentQuestionIndex = 0
//    @State private var selectedAnswer: Int?
//    @State private var score = 0
//    
//    // Para cerrar la vista al terminar
//    @Environment(\.presentationMode) var presentationMode
//    
//    var body: some View {
//        ZStack {
//            Color.white.ignoresSafeArea()
//            
//            if !showingQuiz {
//                // Pantalla antes del quiz
//                VStack(spacing: 20) {
//                    Text("Ejercicio de Retención")
//                        .font(.title)
//                        .padding(.top, 50)
//                    
//                    if !showParagraph && !showCountdown {
//                        // Mensaje inicial
//                        Text("Al iniciar, verás el texto por \(exercise.readingTime) segundos.\nDespués contestarás preguntas de memoria.")
//                            .multilineTextAlignment(.center)
//                            .padding()
//                        
//                        Button("Iniciar Ejercicio") {
//                            startCountdown()
//                        }
//                        .font(.headline)
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(12)
//                        
//                    } else if showCountdown {
//                        // Vista “3,2,1…”
//                        Text(countdownValue > 0 ? "\(countdownValue)" : "¡Fuera!")
//                            .font(.system(size: 80, weight: .bold))
//                            .foregroundColor(.white)
//                            .background(Color.black.opacity(0.5).ignoresSafeArea())
//                        
//                    } else if showParagraph {
//                        // Párrafo + tiempo restante
//                        Text(exercise.paragraph)
//                            .font(.body)
//                            .multilineTextAlignment(.leading)
//                            .padding()
//                        
//                        Text("Tiempo restante: \(timeLeft)s")
//                            .font(.headline)
//                            .foregroundColor(.red)
//                        
//                        Spacer()
//                        
//                        // Botón para terminar antes del tiempo
//                        Button("Terminar ahora") {
//                            endParagraphDisplay()
//                        }
//                        .font(.headline)
//                        .padding()
//                        .background(Color.red)
//                        .foregroundColor(.white)
//                        .cornerRadius(12)
//                    }
//                    
//                    Spacer()
//                }
//            } else {
//                // Cuestionario
//                if currentQuestionIndex < exercise.questions.count {
//                    let question = exercise.questions[currentQuestionIndex]
//                    
//                    VStack(spacing: 20) {
//                        Text("Pregunta \(currentQuestionIndex + 1) de \(exercise.questions.count)")
//                            .font(.headline)
//                            .padding(.top, 40)
//                        
//                        Text(question.text)
//                            .font(.title3)
//                            .multilineTextAlignment(.center)
//                            .padding(.horizontal)
//                        
//                        ForEach(0..<question.options.count, id: \.self) { i in
//                            Button(action: {
//                                selectedAnswer = i
//                            }) {
//                                Text(question.options[i])
//                                    .padding()
//                                    .frame(maxWidth: .infinity)
//                                    .background(selectedAnswer == i ? Color.blue : Color.gray.opacity(0.2))
//                                    .foregroundColor(selectedAnswer == i ? .white : .black)
//                                    .cornerRadius(10)
//                            }
//                            .padding(.horizontal)
//                        }
//                        
//                        Button("Siguiente") {
//                            if let selected = selectedAnswer {
//                                if selected == question.correctIndex {
//                                    score += 1
//                                }
//                                currentQuestionIndex += 1
//                                selectedAnswer = nil
//                            }
//                        }
//                        .disabled(selectedAnswer == nil)
//                        .padding()
//                        .background(selectedAnswer == nil ? Color.gray : Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                        
//                        Spacer()
//                    }
//                } else {
//                    // Pantalla final
//                    VStack(spacing: 20) {
//                        Text("¡Ejercicio Completado!")
//                            .font(.largeTitle)
//                            .padding(.top, 40)
//                        
//                        Text("Aciertos: \(score) de \(exercise.questions.count)")
//                            .font(.title2)
//                        
//                        Button("Terminar") {
//                            // Aquí podrías sumar XP con xpManager si quisieras
//                            presentationMode.wrappedValue.dismiss()
//                        }
//                        .font(.headline)
//                        .padding()
//                        .background(Color.green)
//                        .foregroundColor(.white)
//                        .cornerRadius(12)
//                        
//                        Spacer()
//                    }
//                }
//            }
//        }
//        .onDisappear {
//            timer?.invalidate()
//        }
//    }
//    
//    // MARK: - Lógica
//    
//    private func startCountdown() {
//        showCountdown = true
//        countdownValue = 3
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            countdownValue = 2
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            countdownValue = 1
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            showCountdown = false
//            showParagraph = true
//            timeLeft = exercise.readingTime
//            startParagraphTimer()
//        }
//    }
//    
//    private func startParagraphTimer() {
//        timer?.invalidate()
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//            if timeLeft > 0 {
//                timeLeft -= 1
//            } else {
//                endParagraphDisplay()
//            }
//        }
//    }
//    
//    private func endParagraphDisplay() {
//        timer?.invalidate()
//        timer = nil
//        showParagraph = false
//        showingQuiz = true
//    }
//}
//
