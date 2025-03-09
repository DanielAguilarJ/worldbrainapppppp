import SwiftUI

struct QuizView: View {
    let questions: [Question]
    let lesson: Lesson
    let stage: Stage
    @ObservedObject var stageManager: StageManager
    @ObservedObject var xpManager: XPManager
    let stageIndex: Int
    
    let readingSpeed: Double
    
    var onQuizComplete: (() -> Void)?
    
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int?
    @State private var score = 0
    
    var body: some View {
        if currentQuestionIndex < questions.count {
            VStack {
                Text("Pregunta \(currentQuestionIndex + 1) de \(questions.count)")
                    .font(.headline)
                    .padding()
                
                ProgressView(value: Double(currentQuestionIndex), total: Double(questions.count))
                    .padding(.horizontal)
                
                let question = questions[currentQuestionIndex]
                
                Text(question.text)
                    .font(.title3)
                    .padding()
                    .multilineTextAlignment(.center)
                
                ForEach(0..<question.options.count, id: \.self) { index in
                    Button(action: {
                        selectedAnswer = index
                    }) {
                        Text(question.options[index])
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedAnswer == index ? stage.color : Color.gray.opacity(0.2))
                            .foregroundColor(selectedAnswer == index ? .white : .primary)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                Button("Siguiente") {
                    if let selected = selectedAnswer {
                        if selected == question.correctAnswer {
                            score += 1
                        }
                        currentQuestionIndex += 1
                        selectedAnswer = nil
                    }
                }
                .disabled(selectedAnswer == nil)
                .padding()
                .foregroundColor(.white)
                .background(selectedAnswer == nil ? Color.gray : stage.color)
                .cornerRadius(10)
                .padding(.top)
                
                Spacer()
            }
        } else {
            let minScoreToPass = 2
            if score < minScoreToPass {
                LessonFailView(score: score, totalQuestions: questions.count) {
                    presentationMode.wrappedValue.dismiss()
                    // Lógica para reintentar o regresar a LessonView
                }
            } else {
                LessonCompletedView(
                    lesson: lesson,
                    stage: stage,
                    score: score,
                    totalQuestions: questions.count,
                    stageManager: stageManager,
                    xpManager: xpManager,
                    stageIndex: stageIndex,
                    readingSpeed: readingSpeed
                ) {
                    onQuizComplete?()
                }
            }
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
}

struct LessonFailView: View {
    let score: Int
    let totalQuestions: Int
    var onRetry: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color(.systemRed).opacity(0.1).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("¡Necesitas repasar!")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 40)
                Text("Obtuviste \(score) de \(totalQuestions) respuestas correctas.")
                    .font(.title3)
                    .padding()
                Text("Para avanzar, repite la lectura y vuelve a intentarlo.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                    onRetry()
                }) {
                    Text("RELEER LECCIÓN")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

