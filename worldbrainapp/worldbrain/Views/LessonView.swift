import SwiftUI

struct LessonView: View {
    let lesson: Lesson
    let stage: Stage
    @ObservedObject var stageManager: StageManager
    @ObservedObject var xpManager: XPManager
    let stageIndex: Int
    
    // Callback para notificar a StageLessonsView que se cierre esta fullScreenCover
    var onCloseLesson: (() -> Void)?
    
    // Estados para lecturas y conteo
    @State private var readingInProgress = false
    @State private var readingStartTime: Date? = nil
    @State private var readingSpeed: Double = 0.0
    
    // Conteo regresivo
    @State private var countdownActive = false
    @State private var countdownValue = 3
    
    // Estados para eyeTraining
    @State private var showingEyeExercise = false
    @State private var finishedAllEyeExercises = false
    
    // Muestra un quiz al final
    @State private var showingQuiz = false
    
    // Alerta de salir
    @State private var showingExitAlert = false
    
    // Para cerrar esta vista si el usuario decide “Salir”
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ENCABEZADO con botón “Atrás”
                HStack {
                    Button {
                        showingExitAlert = true
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text("\(stage.name) - Lección \(getLessonNumber())")
                        .font(.headline)
                    
                    Spacer()
                    Spacer().frame(width: 20)
                }
                .padding(.top, 50)
                .padding(.horizontal)
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
                
                // Si la lección es reading
                if lesson.type == .reading || lesson.type == .speedReading {
                    Text("Lectura Rápida")
                        .font(.title2)
                        .padding(.vertical, 8)
                    
                    ScrollView {
                        if readingInProgress {
                            Text(lesson.content)
                                .font(.system(size: 18))
                                .lineSpacing(8)
                                .foregroundColor(.green)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                        } else {
                            Text("El texto se mostrará cuando inicie la lectura...")
                                .font(.callout)
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    .frame(maxHeight: .infinity)
                    
                    if !readingInProgress && !countdownActive {
                        Button("Iniciar Lectura") {
                            startCountdown()
                        }
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.bottom, 20)
                        
                    } else if readingInProgress {
                        Button("Terminar Lectura") {
                            finishReading()
                        }
                        .font(.headline)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.bottom, 20)
                    }
                    
                } else if lesson.type == .eyeTraining {
                    // Entrenamiento Ocular
                    Text("Entrenamiento Ocular")
                        .font(.title2)
                        .padding(.vertical, 8)
                    
                    Text(lesson.description)
                        .font(.callout)
                        .foregroundColor(.gray)
                        .padding()
                    
                    Spacer()
                    
                    if !finishedAllEyeExercises {
                        Button("Iniciar Entrenamiento Ocular") {
                            showingEyeExercise = true
                        }
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    } else {
                        // Si la lección ocular también tiene questions
                        if hasQuestions {
                            Button("Responder Quiz") {
                                showingQuiz = true
                            }
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        } else {
                            Button("Finalizar") {
                                completeLessonAndDismiss()
                            }
                            .font(.headline)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    
                    Spacer()
                }
            }
            
            // Conteo “3,2,1”
            if countdownActive {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    Text(countdownValue > 0 ? "\(countdownValue)" : "¡Fuera!")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        // Al terminar la lección, mostrar quiz a pantalla completa
        .fullScreenCover(isPresented: $showingQuiz) {
            QuizView(
                questions: lesson.questions,
                lesson: lesson,
                stage: stage,
                stageManager: stageManager,
                xpManager: xpManager,
                stageIndex: stageIndex,
                readingSpeed: readingSpeed
            ) {
                // Al terminar quiz
                presentationMode.wrappedValue.dismiss()
                onCloseLesson?()
            }
        }
        // Al entrenar ojos
        .fullScreenCover(isPresented: $showingEyeExercise) {
            if let ex = lesson.eyeExercises?.first {
                EyeExerciseView(exercise: ex)
                    .onDisappear {
                        finishedAllEyeExercises = true
                    }
            } else {
                Text("No hay ejercicios en esta lección.")
            }
        }
        // Alerta “¿Salir?”
        .alert(isPresented: $showingExitAlert) {
            Alert(
                title: Text("¿Seguro que quieres salir?"),
                message: Text("Si sales, perderás tu progreso actual."),
                primaryButton: .destructive(Text("Salir")) {
                    presentationMode.wrappedValue.dismiss()
                    onCloseLesson?()
                },
                secondaryButton: .cancel(Text("Continuar"))
            )
        }
    }
    
    private var hasQuestions: Bool {
        !lesson.questions.isEmpty
    }
    
    private func getLessonNumber() -> Int {
        if let index = stage.lessons.firstIndex(where: { $0.id == lesson.id }) {
            return index + 1
        }
        return 1
    }
    
    // Inicia la cuenta regresiva
    private func startCountdown() {
        countdownActive = true
        countdownValue = 3
        readingInProgress = false
        readingStartTime = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            countdownValue = 2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            countdownValue = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            countdownActive = false
            readingInProgress = true
            readingStartTime = Date()
        }
    }
    
    private func finishReading() {
        readingInProgress = false
        
        guard let start = readingStartTime else {
            readingSpeed = 0
            showingQuiz = true
            return
        }
        
        let end = Date()
        let duration = end.timeIntervalSince(start) // en segundos
        let minutes = duration / 60.0
        
        let wordCount = lesson.content
            .split(separator: " ", omittingEmptySubsequences: true)
            .count
        
        if minutes > 0 {
            readingSpeed = Double(wordCount) / minutes
        } else {
            readingSpeed = 0
        }
        
        showingQuiz = true
    }
    
    private func completeLessonAndDismiss() {
        xpManager.addXP(xpManager.lessonXP)
        stageManager.completeLesson(stageIndex: stageIndex, lessonId: lesson.id)
        presentationMode.wrappedValue.dismiss()
        onCloseLesson?()
    }
}

