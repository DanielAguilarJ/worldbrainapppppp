import SwiftUI

struct ChallengesListView: View {
    @EnvironmentObject var progressManager: ProgressManager
    let stage: StageType
    
    var challenges: [Challenge] {
        progressManager.getChallenges(for: stage)
    }
    
    var isStageUnlocked: Bool {
        progressManager.isStageUnlocked(stage)
    }
    
    var body: some View {
        ScrollView {
            if !isStageUnlocked {
                StageLockedView(stage: stage)
            } else {
                LazyVStack(spacing: 15) {
                    ForEach(challenges) { challenge in
                        ChallengeCardView(challenge: challenge)
                            .padding(.horizontal)
                    }
                    
                    // Mensaje informativo
                    InfoCardView(
                        title: "Acerca de los Desafíos",
                        message: "Los desafíos son opcionales pero te ayudarán a mejorar tus habilidades de lectura rápida y comprensión. Completa los que puedas antes del examen final.",
                        systemImage: "info.circle"
                    )
                    .padding()
                }
                .padding(.vertical)
            }
        }
    }
}

struct ChallengeCardView: View {
    let challenge: Challenge
    @State private var isExpanded = false
    @State private var showingChallenge = false
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(challenge.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(challenge.type.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Indicador de estado
                    ZStack {
                        Circle()
                            .fill(challenge.isCompleted ? Color.green : Color.blue.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        if challenge.isCompleted {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "trophy")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                        .padding(.leading, 8)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 15) {
                    Text(challenge.description)
                        .font(.body)
                        .padding(.vertical, 5)
                    
                    Button(action: {
                        showingChallenge = true
                    }) {
                        Text("Iniciar Desafío")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding(.top)
                .transition(.move(edge: .top))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .sheet(isPresented: $showingChallenge) {
            ChallengeDetailView(challenge: challenge)
        }
    }
}

struct InfoCardView: View {
    let title: String
    let message: String
    let systemImage: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.blue)
                .padding()
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct ChallengeDetailView: View {
    let challenge: Challenge
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var progressManager: ProgressManager
    
    @State private var challengeCompleted = false
    @State private var score: Double = 0
    @State private var timeRemaining = 60 // En segundos
    @State private var timer: Timer?
    @State private var startTime: Date?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Encabezado
                VStack(alignment: .leading, spacing: 10) {
                    Text(challenge.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(challenge.type.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    Text(challenge.description)
                        .font(.body)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                
                // Instrucciones
                VStack(alignment: .leading, spacing: 10) {
                    Text("Instrucciones:")
                        .font(.headline)
                    
                    Text(challenge.instructions)
                        .font(.body)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 1)
                )
                
                Spacer()
                
                // Área específica del desafío
                if challenge.type == .peripheralVision {
                    PeripheralVisionChallengeView(
                        onComplete: { result in
                            score = result
                            challengeCompleted = true
                        }
                    )
                } else if challenge.type == .speedReading {
                    SpeedReadingChallengeView(
                        onComplete: { result in
                            score = result
                            challengeCompleted = true
                        }
                    )
                } else {
                    ComprehensionChallengeView(
                        onComplete: { result in
                            score = result
                            challengeCompleted = true
                        }
                    )
                }
                
                Spacer()
                
                // Resultados si se completa
                if challengeCompleted {
                    VStack(spacing: 15) {
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.yellow)
                        
                        Text("¡Desafío completado!")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Tu puntuación: \(Int(score))%")
                            .font(.headline)
                        
                        Button(action: {
                            // Guardar resultado
                            progressManager.completeChallenge(challenge, withScore: score)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Continuar")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemGray6))
                    )
                }
            }
            .padding()
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
            startTime = Date()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
}

// Vistas específicas para cada tipo de desafío
struct PeripheralVisionChallengeView: View {
    let onComplete: (Double) -> Void
    @State private var currentIndex = 0
    @State private var correctAnswers = 0
    @State private var showingWord = false
    @State private var isCompleting = false
    
    let words = ["rápido", "lectura", "cerebro", "comprender", "velocidad", "visión", "periférica", "concentración", "enfoque", "progreso"]
    
    var body: some View {
        VStack(spacing: 30) {
            if !isCompleting {
                Text("Mantén la vista en el centro y trata de identificar la palabra que aparecerá brevemente")
                    .multilineTextAlignment(.center)
                    .padding()
                
                ZStack {
                    Circle()
                        .stroke(Color.blue, lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    if showingWord {
                        Text(words[currentIndex])
                            .font(.title)
                            .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 200)
                
                Button(action: startChallenge) {
                    Text("Comenzar")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            } else {
                // Preguntas de verificación
                Text("¿Cuál fue la última palabra que viste?")
                    .font(.headline)
                
                ForEach([words[currentIndex-1], words.randomElement()!, words.randomElement()!].shuffled(), id: \.self) { word in
                    Button(action: {
                        if word == words[currentIndex-1] {
                            correctAnswers += 1
                        }
                        completeChallenge()
                    }) {
                        Text(word)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                }
            }
        }
    }
    
    private func startChallenge() {
        var iterations = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            withAnimation {
                showingWord = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showingWord = false
                }
                
                currentIndex = (currentIndex + 1) % words.count
                iterations += 1
                
                if iterations >= 5 {
                    timer.invalidate()
                    isCompleting = true
                }
            }
        }
    }
    
    private func completeChallenge() {
        let score = Double(correctAnswers) * 20 // 5 palabras, 20% cada una
        onComplete(score)
    }
}

struct SpeedReadingChallengeView: View {
    let onComplete: (Double) -> Void
    @State private var showingText = false
    @State private var startTime: Date?
    @State private var isCompleting = false
    @State private var selectedAnswer: Int?
    
    let text = """
        La lectura rápida es una habilidad que puede mejorarse con práctica constante. Para aumentar tu velocidad de lectura, es importante eliminar la subvocalización, que es el hábito de pronunciar las palabras en tu mente mientras lees. También es útil utilizar un marcador o tu dedo para guiar tus ojos a través del texto, ayudando a mantener un ritmo constante. La práctica regular con textos de dificultad creciente permitirá que tu cerebro procese información escrita más rápidamente sin sacrificar la comprensión.
        """
    
    var body: some View {
        VStack(spacing: 25) {
            if !isCompleting {
                if !showingText {
                    Text("Lee el siguiente texto lo más rápido posible mientras comprendes su contenido")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button(action: {
                        showingText = true
                        startTime = Date()
                    }) {
                        Text("Comenzar")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                } else {
                    Text(text)
                        .lineSpacing(5)
                        .padding()
                    
                    Button(action: {
                        isCompleting = true
                    }) {
                        Text("He terminado de leer")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                }
            } else {
                // Preguntas de comprensión
                Text("¿Cuál de las siguientes afirmaciones es correcta según el texto?")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 15) {
                    ForEach(0..<3, id: \.self) { index in
                        Button(action: {
                            selectedAnswer = index
                            completeChallenge()
                        }) {
                            Text([
                                "La subvocalización ayuda a aumentar la velocidad de lectura.",
                                "Usar un marcador o dedo puede ayudar a mantener un ritmo constante.",
                                "La práctica regular disminuye la capacidad de comprensión."
                            ][index])
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                            .multilineTextAlignment(.leading)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    private func completeChallenge() {
        // La respuesta correcta es la opción 1
        var score = 0.0
        
        // Evaluar respuesta
        if selectedAnswer == 1 {
            score += 50
        }
        
        // Evaluar velocidad
        if let startTime = startTime {
            let readingTime = Date().timeIntervalSince(startTime)
            let wordCount = text.split(separator: " ").count
            let wpm = Double(wordCount) / (readingTime / 60)
            
            if wpm >= 130 {
                score += 50
            } else if wpm >= 100 {
                score += 30
            } else {
                score += 15
            }
        }
        
        onComplete(score)
    }
}

struct ComprehensionChallengeView: View {
    let onComplete: (Double) -> Void
    @State private var showingText = false
    @State private var isCompleting = false
    @State private var answers: [Int?] = [nil, nil, nil]
    
    let text = """
        El aprendizaje de la lectura rápida implica desarrollar diversas habilidades cognitivas. Estudios recientes demuestran que la práctica regular puede aumentar significativamente la velocidad de lectura mientras se mantiene la comprensión. Tres factores clave son fundamentales: primero, evitar la regresión (volver a leer palabras); segundo, expandir el campo de visión periférica; y tercero, mejorar la capacidad de procesar grupos de palabras en lugar de términos individuales. Los expertos recomiendan practicar durante al menos 15 minutos diarios para conseguir resultados óptimos.
        """
    
    let questions = [
        (question: "¿Cuántos factores clave se mencionan en el texto?", 
         options: ["Dos", "Tres", "Cuatro"], 
         correctAnswer: 1),
        
        (question: "¿Qué significa 'regresión' según el texto?", 
         options: ["Avanzar rápidamente en el texto", "Volver a leer palabras", "Procesar palabras individualmente"], 
         correctAnswer: 1),
         
        (question: "¿Cuánto tiempo diario de práctica recomiendan los expertos?", 
         options: ["10 minutos", "15 minutos", "30 minutos"], 
         correctAnswer: 1)
    ]
    
    var allQuestionsAnswered: Bool {
        !answers.contains(nil)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if !isCompleting {
                if !showingText {
                    Text("Lee el siguiente texto con atención y responde las preguntas de comprensión")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button(action: {
                        showingText = true
                    }) {
                        Text("Comenzar")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                } else {
                    Text(text)
                        .lineSpacing(5)
                        .padding()
                    
                    Button(action: {
                        isCompleting = true
                    }) {
                        Text("He terminado de leer")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        Text("Responde las siguientes preguntas:")
                            .font(.headline)
                        
                        ForEach(0..<questions.count, id: \.self) { index in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(questions[index].question)
                                    .fontWeight(.semibold)
                                
                                ForEach(0..<questions[index].options.count, id: \.self) { optionIndex in
                                    Button(action: {
                                        answers[index] = optionIndex
                                    }) {
                                        HStack {
                                            Text(questions[index].options[optionIndex])
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                            
                                            if answers[index] == optionIndex {
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
                                                .fill(answers[index] == optionIndex ? Color.blue.opacity(0.1) : Color.clear)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            
                            if index < questions.count - 1 {
                                Divider()
                                    .padding(.vertical, 5)
                            }
                        }
                        
                        Button(action: completeChallenge) {
                            Text("Enviar respuestas")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(allQuestionsAnswered ? Color.blue : Color.gray)
                                .cornerRadius(10)
                        }
                        .disabled(!allQuestionsAnswered)
                        .padding(.top)
                    }
                }
            }
        }
    }
    
    private func completeChallenge() {
        var correctCount = 0
        
        for i in 0..<questions.count {
            if answers[i] == questions[i].correctAnswer {
                correctCount += 1
            }
        }
        
        let score = Double(correctCount) / Double(questions.count) * 100
        onComplete(score)
    }
}

struct ChallengesListView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengesListView(stage: .blue)
            .environmentObject(ProgressManager())
    }
}