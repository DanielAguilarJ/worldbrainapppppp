//
//  WordInequalityView.swift
//  worldbrainapp
//
//  Created by msc on 09/03/2025.
//


//
//  WordInequalityView.swift
//  worldbrainapp
//
//  Vista para el desafío de pares de palabras desiguales
//

import SwiftUI

struct WordInequalityView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var xpManager: XPManager
    
    @State private var timeRemaining = 90
    @State private var timer: Timer? = nil
    @State private var score = 0
    @State private var pairs: [(String, String, Bool)] = [] // (palabra1, palabra2, sonIguales)
    @State private var tappedPairs: Set<Int> = []
    @State private var showExitAlert = false
    @State private var gameEnded = false
    @State private var showGameOverAlert = false
    @State private var earnedXP = 0
    @State private var xpUpdated = false
    @State private var showFeedback = false
    @State private var feedbackMessage = ""
    @State private var feedbackIsPositive = true
    @State private var lastFeedbackTime = Date()
    
    // Conjuntos de palabras similares para crear confusión
    let wordSets: [[String]] = [
        // Palabras que se parecen visualmente
        ["casa", "caza", "cosa", "cesa", "caso"],
        ["pero", "perro", "pera", "poro", "para"],
        ["mano", "mono", "mina", "mona", "mesa"],
        ["lava", "leva", "leve", "lava", "loba"],
        ["pata", "pato", "pasta", "pista", "punta"],
        ["boca", "bola", "bota", "boda", "besa"],
        ["mundo", "mando", "manto", "mando", "mucho"],
        ["gato", "gasto", "gesto", "gusto", "gota"],
        ["sol", "sal", "sil", "solo", "sala"],
        ["mar", "mal", "más", "mes", "mis"],
        
        // Verbos similares
        ["tomar", "tocar", "tirar", "temar", "tamar"],
        ["comer", "coser", "correr", "cocer", "comer"],
        ["sacar", "saltar", "sanar", "salar", "sajar"],
        ["pedir", "pelar", "penar", "pesar", "pecar"],
        ["mirar", "minar", "mimar", "medir", "mecer"],
        
        // Sustantivos similares
        ["libro", "litro", "labio", "libre", "libra"],
        ["vaso", "paso", "vaso", "veso", "viso"],
        ["mesa", "masa", "misa", "musa", "meso"],
        ["calle", "valle", "calle", "celle", "cille"],
        ["cielo", "ciclo", "ciego", "cieno", "cielo"]
    ]
    
    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Cálculo de XP basado en puntuación
    var calculatedXP: Int {
        return max(score * 5, 0) // 5 XP por punto, mínimo 0
    }
    
    var body: some View {
        ZStack {
            // Fondo
            LinearGradient(
                gradient: Gradient(colors: [Color.indigo.opacity(0.7), Color.purple.opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            ).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                // Header con cronómetro y puntuación
                HStack {
                    Button(action: {
                        if !gameEnded {
                            timer?.invalidate()
                            
                            // Si el juego no ha terminado, actualizar XP antes de preguntar
                            if !xpUpdated && score > 0 {
                                earnedXP = calculatedXP
                                xpManager.addXP(earnedXP)
                                xpUpdated = true
                            }
                            
                            showExitAlert = true
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Cerrar")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(20)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Text(formattedTime)
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Puntuación: \(score)")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(15)
                    
                    Spacer()
                    
                    // Vista de XP
                    VStack {
                        Text("XP")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("\(calculatedXP)")
                            .font(.title3.bold())
                            .foregroundColor(.yellow)
                    }
                    .padding(.horizontal, 15)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Instrucciones
                VStack(spacing: 5) {
                    Text("Encuentra pares de palabras DIFERENTES")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Cuidado con los pares idénticos, tienen penalización")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.vertical, 5)
                .padding(.horizontal)
                .background(Color.black.opacity(0.2))
                .cornerRadius(10)
                
                // Grid de pares de palabras
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 15) {
                    ForEach(0..<pairs.count, id: \.self) { index in
                        WordPairCardView(
                            pair: pairs[index],
                            isSelected: tappedPairs.contains(index)
                        )
                        .onTapGesture {
                            pairTapped(at: index)
                        }
                        .disabled(tappedPairs.contains(index) || gameEnded)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Feedback en tiempo real
                if showFeedback {
                    Text(feedbackMessage)
                        .font(.headline)
                        .foregroundColor(feedbackIsPositive ? .green : .red)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 20)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(20)
                        .transition(.scale.combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation {
                                    if Date().timeIntervalSince(lastFeedbackTime) > 1.0 {
                                        showFeedback = false
                                    }
                                }
                            }
                        }
                }
            }
            .onAppear {
                setupGame()
            }
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
        .alert("¿Estás seguro?", isPresented: $showExitAlert) {
            Button("Continuar jugando", role: .cancel) {
                startTimer()
            }
            Button("Salir", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Si sales ahora, conservarás los \(earnedXP) XP que has ganado.")
        }
        .alert(timeRemaining <= 0 ? "¡Tiempo terminado!" : "¡Juego completado!", isPresented: $showGameOverAlert) {
            Button("Jugar de nuevo") {
                resetGame()
            }
            Button("Salir", role: .cancel) {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Puntuación final: \(score)\nXP ganado: +\(earnedXP)")
        }
    }
    
    private func setupGame() {
        // Reset game state
        tappedPairs = []
        score = 0
        gameEnded = false
        earnedXP = 0
        xpUpdated = false
        timeRemaining = 90
        showFeedback = false
        
        // Crear los 15 pares (formato 3x5)
        pairs = []
        
        // Generar los pares
        for _ in 0..<15 {
            // 60% de probabilidad de que sean diferentes, 40% iguales
            if Bool.random() && pairs.filter { $0.2 == false }.count < 10 { // Máximo 10 pares diferentes
                // Par diferente
                let randomSet = wordSets.randomElement()!
                let word1 = randomSet.randomElement()!
                var word2: String
                repeat {
                    word2 = randomSet.randomElement()!
                } while word1 == word2
                
                pairs.append((word1, word2, false)) // False = no son iguales
            } else {
                // Par idéntico
                let randomSet = wordSets.randomElement()!
                let word = randomSet.randomElement()!
                
                pairs.append((word, word, true)) // True = son iguales
            }
        }
        
        // Asegurar que haya al menos 5 pares diferentes y 3 iguales
        let differentCount = pairs.filter { !$0.2 }.count
        if differentCount < 5 {
            // Reemplazar algunos pares iguales con diferentes
            for i in 0..<pairs.count where pairs[i].2 && differentCount + i < 5 {
                let randomSet = wordSets.randomElement()!
                let word1 = randomSet.randomElement()!
                var word2: String
                repeat {
                    word2 = randomSet.randomElement()!
                } while word1 == word2
                
                pairs[i] = (word1, word2, false)
            }
        }
        
        // Asegurar que haya al menos 3 pares iguales
        let sameCount = pairs.filter { $0.2 }.count
        if sameCount < 3 {
            // Reemplazar algunos pares diferentes con iguales
            for i in 0..<pairs.count where !pairs[i].2 && sameCount + i < 3 {
                let randomSet = wordSets.randomElement()!
                let word = randomSet.randomElement()!
                
                pairs[i] = (word, word, true)
            }
        }
        
        // Mezclar los pares
        pairs.shuffle()
        
        // Start the timer
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                endGame()
            }
        }
    }
    
    private func resetGame() {
        timer?.invalidate()
        setupGame()
    }
    
    private func pairTapped(at index: Int) {
        guard !tappedPairs.contains(index) else { return }
        
        let pair = pairs[index]
        tappedPairs.insert(index)
        lastFeedbackTime = Date()
        
        // Verificar si el par es correcto (diferente)
        if !pair.2 { // Palabras diferentes
            // Sumar puntos
            score += 10
            
            // Mostrar feedback positivo
            feedbackMessage = "+10 ¡Correcto!"
            feedbackIsPositive = true
            withAnimation {
                showFeedback = true
            }
        } else { // Palabras iguales
            // Restar puntos
            score = max(0, score - 5)
            
            // Mostrar feedback negativo
            feedbackMessage = "-5 ¡Incorrecto!"
            feedbackIsPositive = false
            withAnimation {
                showFeedback = true
            }
        }
        
        // Comprobar si todos los pares correctos han sido encontrados
        let correctPairs = pairs.enumerated().filter { !$0.element.2 } // Pares diferentes
        let foundAllCorrect = correctPairs.allSatisfy { tappedPairs.contains($0.offset) }
        
        if foundAllCorrect {
            // Bonus por encontrar todos los pares correctos
            let timeBonus = timeRemaining / 2
            score += timeBonus
            earnedXP = calculatedXP
            
            // Mostrar feedback del bonus
            feedbackMessage = "+\(timeBonus) ¡BONUS DE TIEMPO!"
            feedbackIsPositive = true
            withAnimation {
                showFeedback = true
            }
            
            // Terminar el juego con victoria
            endGame(withVictory: true)
        }
    }
    
    private func endGame(withVictory: Bool = false) {
        timer?.invalidate()
        gameEnded = true
        
        // Calcula y guarda la XP ganada
        earnedXP = calculatedXP
        
        // Actualizar la XP usando el XPManager
        if !xpUpdated && score > 0 {
            xpManager.addXP(earnedXP)
            xpUpdated = true
        }
        
        showGameOverAlert = true
    }
}

// Vista para mostrar un par de palabras
struct WordPairCardView: View {
    let pair: (String, String, Bool) // (palabra1, palabra2, sonIguales)
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Primera palabra
            ZStack {
                Rectangle()
                    .fill(cardColor)
                    .cornerRadius(10, corners: [.topLeft, .topRight])
                
                Text(pair.0)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(10)
            }
            .frame(height: 50)
            
            // Separador
            Rectangle()
                .fill(Color.white)
                .frame(height: 2)
            
            // Segunda palabra
            ZStack {
                Rectangle()
                    .fill(cardColor)
                    .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
                
                Text(pair.1)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(10)
            }
            .frame(height: 50)
        }
        .shadow(color: isSelected ? (pair.2 ? .red.opacity(0.7) : .green.opacity(0.7)) : .black.opacity(0.3), 
                radius: isSelected ? 5 : 2)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? (pair.2 ? Color.red : Color.green) : Color.clear, lineWidth: 3)
        )
    }
    
    var cardColor: Color {
        if isSelected {
            return pair.2 ? Color.red.opacity(0.3) : Color.green.opacity(0.3)
        } else {
            return Color(red: 0.3, green: 0.3, blue: 0.7)
        }
    }
}

// Extensión para redondear solo algunas esquinas
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}