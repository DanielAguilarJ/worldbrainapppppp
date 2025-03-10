//
//  LessonDetailView.swift
//  worldbrainapp
//
//  Created by msc on 10/03/2025.
//


import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    @EnvironmentObject var progressManager: ProgressManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isReading = false
    @State private var readingCompleted = false
    @State private var startTime: Date?
    @State private var endTime: Date?
    @State private var wordCount: Int = 0
    @State private var showComprehensionTest = false
    @State private var questionAnswers: [Int?]
    @State private var comprehensionQuestions = [
        ExamQuestion(
            id: UUID(),
            question: "¿Cuál es el tema principal de esta lección?",
            options: ["Velocidad de lectura", "Comprensión de textos complejos", "Técnicas de memoria", "Historia de la literatura"],
            correctOptionIndex: 0
        ),
        ExamQuestion(
            id: UUID(),
            question: "¿Qué habilidad específica se busca mejorar en esta etapa?",
            options: ["Escritura veloz", "Lectura a 130 palabras por minuto", "Memorización de textos", "Análisis literario"],
            correctOptionIndex: 1
        ),
        ExamQuestion(
            id: UUID(),
            question: "¿Cuál es el nivel de comprensión objetivo de esta etapa?",
            options: ["80%", "90%", "95%", "100%"],
            correctOptionIndex: 2
        )
    ]
    
    init(lesson: Lesson) {
        self.lesson = lesson
        // Inicializa el array de respuestas con nil para cada pregunta
        _questionAnswers = State(initialValue: Array(repeating: nil, count: 3))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Encabezado de la lección
                    VStack(alignment: .leading, spacing: 10) {
                        Text(lesson.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Objetivo: \(lesson.targetWPM) PPM")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Divider()
                        
                        Text(lesson.description)
                            .font(.body)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    
                    // Botón para comenzar la lectura
                    if !isReading && !readingCompleted {
                        Button(action: {
                            startReading()
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Comenzar Lectura")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Contenido de la lectura
                    if isReading {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Lectura:")
                                .font(.headline)
                            
                            Text(lesson.content)
                                .font(.body)
                                .lineSpacing(5)
                            
                            Button(action: {
                                finishReading()
                            }) {
                                HStack {
                                    Image(systemName: "checkmark")
                                    Text("He terminado de leer")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                            }
                            .padding(.top, 20)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 2)
                        )
                    }
                    
                    // Resultados de la lectura
                    if readingCompleted && !showComprehensionTest {
                        ResultsView(
                            wordsPerMinute: calculateWPM(),
                            targetWPM: lesson.targetWPM,
                            onContinue: {
                                showComprehensionTest = true
                            }
                        )
                    }
                    
                    // Prueba de comprensión
                    if showComprehensionTest {
                        ComprehensionTestView(
                            questions: comprehensionQuestions,
                            answers: $questionAnswers,
                            onSubmit: submitComprehension
                        )
                    }
                }
                .padding()
            }
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.blue)
                }
            )
        }
        .onAppear {
            // Contar palabras en el contenido de la lección
            wordCount = lesson.content.split(separator: " ").count
        }
    }
    
    private func startReading() {
        startTime = Date()
        isReading = true
    }
    
    private func finishReading() {
        endTime = Date()
        isReading = false
        readingCompleted = true
    }
    
    private func calculateWPM() -> Int {
        guard let start = startTime, let end = endTime else { return 0 }
        let timeInterval = end.timeIntervalSince(start)
        let minutes = timeInterval / 60
        return Int(Double(wordCount) / minutes)
    }
    
    private func submitComprehension() {
        // Calcular puntuación de comprensión
        var correctAnswers = 0
        for (index, question) in comprehensionQuestions.enumerated() {
            if questionAnswers[index] == question.correctOptionIndex {
                correctAnswers += 1
            }
        }
        
        let comprehensionScore = Double(correctAnswers) / Double(comprehensionQuestions.count) * 100
        let wpm = calculateWPM()
        
        // Guardar resultados
        progressManager.completeLesson(lesson, withWPM: wpm, comprehension: comprehensionScore)
        
        // Cerrar la vista
        presentationMode.wrappedValue.dismiss()
    }
}

struct ResultsView: View {
    let wordsPerMinute: Int
    let targetWPM: Int
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: wordsPerMinute >= targetWPM ? "star.fill" : "star")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(wordsPerMinute >= targetWPM ? .yellow : .gray)
                .padding()
            
            Text("Tu velocidad de lectura:")
                .font(.headline)
            
            Text("\(wordsPerMinute) PPM")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(wordsPerMinute >= targetWPM ? .green : .orange)
            
            Text("Objetivo: \(targetWPM) PPM")
                .foregroundColor(.secondary)
            
            if wordsPerMinute >= targetWPM {
                Text("¡Excelente! Has alcanzado el objetivo de velocidad.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.green)
            } else {
                Text("Sigue practicando para alcanzar el objetivo.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.orange)
            }
            
            Button(action: onContinue) {
                Text("Continuar a la prueba de comprensión")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemGray6))
        )
    }
}

struct ComprehensionTestView: View {
    let questions: [ExamQuestion]
    @Binding var answers: [Int?]
    let onSubmit: () -> Void
    
    var allQuestionsAnswered: Bool {
        !answers.contains(nil)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Prueba de Comprensión")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Responde las siguientes preguntas para evaluar tu comprensión del texto.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ForEach(questions.indices, id: \.self) { index in
                QuestionView(
                    question: questions[index],
                    selectedOption: answers[index],
                    onSelect: { optionIndex in
                        answers[index] = optionIndex
                    }
                )
            }
            
            Button(action: onSubmit) {
                Text("Enviar respuestas")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(allQuestionsAnswered ? Color.blue : Color.gray)
                    .cornerRadius(10)
            }
            .disabled(!allQuestionsAnswered)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.blue, lineWidth: 1)
        )
    }
}

struct QuestionView: View {
    let question: ExamQuestion
    let selectedOption: Int?
    let onSelect: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(question.question)
                .fontWeight(.semibold)
            
            ForEach(question.options.indices, id: \.self) { index in
                Button(action: {
                    onSelect(index)
                }) {
                    HStack {
                        Text(question.options[index])
                        
                        Spacer()
                        
                        if selectedOption == index {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        } else {
                            Circle()
                                .stroke(Color.gray, lineWidth: 1)
                                .frame(width: 20, height: 20)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedOption == index ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct LessonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LessonDetailView(lesson: Lesson(
            id: UUID(),
            title: "Lectura fluida",
            description: "Aprende a leer de manera fluida y natural.",
            content: "Este es un texto de ejemplo para la lección. Contiene suficientes palabras para practicar la lectura fluida y mejorar tu velocidad de lectura. La lectura fluida es esencial para comprender textos complejos y aumentar tu velocidad de lectura.",
            targetWPM: 130
        ))
        .environmentObject(ProgressManager())
    }
}