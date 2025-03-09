//
//  PyramidTextView.swift
//  worldbrainapp
//
//  Created by msc on 09/03/2025.
//


import SwiftUI

struct PyramidTextView: View {
    let exercise: PyramidTextExercise
    @ObservedObject var xpManager: XPManager
    @Environment(\.presentationMode) var presentationMode
    
    // Exercise states
    @State private var currentParagraphIndex = 0
    @State private var showingInstructions = true
    @State private var exerciseCompleted = false
    @State private var timer: Timer?
    @State private var timeRemaining = 30 // 30 seconds per paragraph
    @State private var totalTime = 0
    
    // Animation states
    @State private var paragraphOpacity = 1.0
    @State private var focusPointScale = 1.0
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.2), Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if showingInstructions {
                instructionsView
            } else if exerciseCompleted {
                completionView
            } else {
                exerciseView
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // Instructions view shown at the beginning
    private var instructionsView: some View {
        VStack(spacing: 25) {
            Text("Entrenamiento de Visión Periférica")
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.green)
                .padding(.top, 40)
            
            Image(systemName: "eye.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
                .padding(.vertical, 20)
            
            VStack(spacing: 20) {
                Text(exercise.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(exercise.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 15) {
                    InstructionRow(number: "1", text: "Enfoca tu mirada en la palabra destacada en VERDE")
                    InstructionRow(number: "2", text: "Intenta percibir todo el texto sin mover tus ojos")
                    InstructionRow(number: "3", text: "Mantén la mirada fija por 30 segundos en cada párrafo")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.1))
                )
                .padding(.horizontal)
            }
            
            Spacer()
            
            Button {
                withAnimation {
                    showingInstructions = false
                    startExercise()
                }
            } label: {
                Text("COMENZAR")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 220, height: 55)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(15)
                    .shadow(color: Color.green.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .padding(.bottom, 50)
        }
    }
    
    // Main exercise view
    private var exerciseView: some View {
        VStack {
            // Header with progress and timer
            HStack {
                Button {
                    showExitAlert()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                        Text("Salir")
                            .font(.headline)
                    }
                    .foregroundColor(.green)
                    .padding(8)
                    .background(
                        Capsule()
                            .fill(Color.green.opacity(0.15))
                    )
                }
                
                Spacer()
                
                // Progress indicator
                HStack(spacing: 5) {
                    ForEach(0..<exercise.paragraphs.count) { i in
                        Circle()
                            .fill(i <= currentParagraphIndex ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                }
                
                Spacer()
                
                // Timer
                Text(timeString(from: timeRemaining))
                    .font(.system(.headline, design: .monospaced))
                    .padding(8)
                    .background(
                        Capsule()
                            .fill(
                                timeRemaining < 10 
                                ? Color.red.opacity(0.15) 
                                : Color.green.opacity(0.15)
                            )
                    )
                    .foregroundColor(timeRemaining < 10 ? .red : .green)
            }
            .padding(.horizontal)
            .padding(.top, 50)
            
            Spacer()
            
            // Pyramid text display
            VStack(spacing: 30) {
                Text("Mantén la mirada en la palabra verde")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                ZStack {
                    // Text container with styled background
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .frame(width: UIScreen.main.bounds.width - 60, height: 280)
                    
                    // Current paragraph with focus word highlighted
                    if currentParagraphIndex < exercise.paragraphs.count {
                        let paragraph = exercise.paragraphs[currentParagraphIndex]
                        PyramidParagraphView(
                            text: paragraph.text,
                            focusWord: paragraph.focusPoint
                        )
                        .opacity(paragraphOpacity)
                    }
                }
                .padding(.horizontal)
                
                Text("No muevas tus ojos del centro")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Next button visible only in the last 5 seconds
            if timeRemaining <= 5 && currentParagraphIndex < exercise.paragraphs.count - 1 {
                Button {
                    moveToNextParagraph()
                } label: {
                    Text("SIGUIENTE")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.green)
                        .cornerRadius(15)
                }
                .padding(.bottom, 30)
            }
            
            // Complete button for the last paragraph
            if timeRemaining <= 5 && currentParagraphIndex == exercise.paragraphs.count - 1 {
                Button {
                    completeExercise()
                } label: {
                    Text("COMPLETAR")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                .padding(.bottom, 30)
            }
        }
    }
    
    // Completion view shown at the end
    private var completionView: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
                .padding(.top, 50)
            
            Text("¡Ejercicio Completado!")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                CompletionStatRow(label: "Tiempo total:", value: timeString(from: totalTime))
                CompletionStatRow(label: "Párrafos completados:", value: "\(exercise.paragraphs.count)")
                CompletionStatRow(label: "XP ganados:", value: "+\(calculateXP()) XP")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .padding(.horizontal, 30)
            
            Text("Este ejercicio ha ayudado a mejorar tu visión periférica, lo que permite una lectura más rápida y eficiente.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button {
                // Award XP and dismiss
                xpManager.addXP(calculateXP())
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("CONTINUAR")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                    .padding(.horizontal, 30)
            }
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - Helper Views
    
    struct InstructionRow: View {
        let number: String
        let text: String
        
        var body: some View {
            HStack(alignment: .top, spacing: 15) {
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 25, height: 25)
                    
                    Text(number)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text(text)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
            }
        }
    }
    
    struct CompletionStatRow: View {
        let label: String
        let value: String
        
        var body: some View {
            HStack {
                Text(label)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(value)
                    .font(.body)
                    .fontWeight(.semibold)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func startExercise() {
        // Start the timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                totalTime += 1
            } else if currentParagraphIndex < exercise.paragraphs.count - 1 {
                moveToNextParagraph()
            } else {
                completeExercise()
            }
        }
        
        // Start pulse animation for focus point
        withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            pulseAnimation = true
        }
    }
    
    private func moveToNextParagraph() {
        withAnimation {
            paragraphOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentParagraphIndex += 1
            timeRemaining = 30
            
            withAnimation {
                paragraphOpacity = 1
            }
        }
    }
    
    private func completeExercise() {
        timer?.invalidate()
        withAnimation {
            exerciseCompleted = true
        }
    }
    
    private func calculateXP() -> Int {
        // Base XP plus bonus for difficulty
        return 50 + (exercise.difficulty * 10)
    }
    
    private func timeString(from seconds: Int) -> String {
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
    
    private func showExitAlert() {
        // In a real implementation, add an alert here asking if they want to exit
        timer?.invalidate()
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - PyramidParagraphView

struct PyramidParagraphView: View {
    let text: String
    let focusWord: String
    
    @State private var pulseScale = 1.0
    
    var body: some View {
        let lines = text.components(separatedBy: "\n")
        
        VStack(spacing: 8) {
            ForEach(lines.indices, id: \.self) { index in
                Text(attributedLine(lines[index]))
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .lineSpacing(5)
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseScale = 1.1
            }
        }
    }
    
    private func attributedLine(_ line: String) -> AttributedString {
        var attributed = AttributedString(line)
        
        if let range = line.range(of: focusWord, options: .caseInsensitive) {
            let nsRange = NSRange(range, in: line)
            if let attributedRange = Range<AttributedString.Index>(NSRange(location: nsRange.location, length: nsRange.length), in: attributed) {
                attributed[attributedRange].foregroundColor = .green
                attributed[attributedRange].font = .system(size: 18, weight: .bold, design: .serif)
            }
        }
        
        return attributed
    }
}