import SwiftUI
import AVFoundation

struct QuizView: View {
    let questions: [Question]
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int?
    @State private var score = 0
    let onQuizCompleted: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            if currentQuestionIndex < questions.count {
                let question = questions[currentQuestionIndex]
                
                Text(question.text)
                    .font(.headline)
                    .padding()
                
                ForEach(0..<question.options.count, id: \.self) { index in
                    Button(action: {
                        selectedAnswer = index
                    }) {
                        Text(question.options[index])
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedAnswer == index ? Color.blue : Color.gray.opacity(0.2))
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
            } else {
                VStack {
                    Text("¡Lección completada!")
                        .font(.title)
                    Text("Puntuación: \(score) de \(questions.count)")
                        .padding()
                    Button("Cerrar") {
                        onQuizCompleted()
                        dismiss()
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    QuizView(
        questions: [
            Question(
                text: "Pregunta de ejemplo",
                options: ["Opción 1", "Opción 2", "Opción 3", "Opción 4"],
                correctAnswer: 0
            )
        ],
        onQuizCompleted: {}
    )
}
