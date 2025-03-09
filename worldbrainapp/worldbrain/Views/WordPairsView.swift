//
//  WordPairsView.swift
//  worldbrainapp
//
//  Vista para el desafío de pares de palabras
//

import SwiftUI

struct WordPairsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var xpManager: XPManager
    
    @State private var timeRemaining = 120
    @State private var timer: Timer? = nil
    @State private var foundPairs: [(String, String)] = []
    @State private var selectedCards: [Int] = []
    @State private var words: [String] = []
    @State private var matchedIndices: Set<Int> = []
    @State private var disableCards = false
    @State private var showExitAlert = false
    @State private var gameEnded = false
    @State private var showGameOverAlert = false
    @State private var earnedXP = 0
    @State private var rowCount = 5
    @State private var columnCount = 4
    @State private var xpUpdated = false
    
    // Conjuntos de pares de palabras para variedad (10 pares por conjunto = 20 cartas para grid 5x4)
    let wordPairSets: [[(String, String)]] = [
        // Set 1
        [("perro", "gato"), ("sol", "luna"), ("día", "noche"), ("agua", "fuego"),
         ("blanco", "negro"), ("alto", "bajo"), ("frío", "calor"), ("feliz", "triste"),
         ("amor", "odio"), ("dulce", "salado")],
         
        // Set 2
        [("cielo", "tierra"), ("mar", "montaña"), ("entrada", "salida"), ("arriba", "abajo"),
         ("comenzar", "terminar"), ("primero", "último"), ("ganar", "perder"), ("nacer", "morir"),
         ("verdad", "mentira"), ("amigo", "enemigo")],
         
        // Set 3
        [("niño", "adulto"), ("hablar", "escuchar"), ("izquierda", "derecha"), ("pasado", "futuro"),
         ("pregunta", "respuesta"), ("fácil", "difícil"), ("guerra", "paz"), ("éxito", "fracaso"),
         ("bueno", "malo"), ("ruido", "silencio")]
    ]
    
    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Cálculo de XP basado en pares encontrados y tiempo restante
    var calculatedXP: Int {
        // Base: 10XP por par encontrado
        let baseXP = foundPairs.count * 10
        
        // Bonus por tiempo restante (si completó todos los pares)
        let timeBonus = matchedIndices.count == words.count ? timeRemaining / 2 : 0
        
        return baseXP + timeBonus
    }
    
    var body: some View {
        ZStack {
            // Fondo
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.3)]),
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
                            if !xpUpdated {
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
                        
                        Text("Pares encontrados: \(foundPairs.count)")
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
                
                // Grid de cartas
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: columnCount),
                    spacing: 10
                ) {
                    ForEach(0..<words.count, id: \.self) { index in
                        WordCardView(
                            word: words[index],
                            isFlipped: selectedCards.contains(index) || matchedIndices.contains(index),
                            isMatched: matchedIndices.contains(index)
                        )
                        .aspectRatio(0.75, contentMode: .fit)
                        .onTapGesture {
                            cardTapped(at: index)
                        }
                        .disabled(disableCards || matchedIndices.contains(index) || selectedCards.contains(index))
                    }
                }
                .padding(.horizontal)
                
                // Instrucciones breves
                Text("Encuentra todos los pares de palabras opuestas")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.bottom, 5)
            }
            .onAppear {
                setupGame()
            }
            .onDisappear {
                timer?.invalidate()
                
                // Asegurar que XP se actualiza al desaparecer si no se ha hecho antes
                if !xpUpdated && foundPairs.count > 0 {
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
                // No necesitamos añadir XP aquí porque ya se hizo antes de mostrar la alerta
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
            Text("Has encontrado \(foundPairs.count) pares de palabras.\nXP ganado: +\(earnedXP)")
        }
    }
    
    private func setupGame() {
        // Reset game state
        selectedCards = []
        matchedIndices = []
        foundPairs = []
        gameEnded = false
        earnedXP = 0
        xpUpdated = false
        timeRemaining = 120
        
        // Select a random set of word pairs
        let selectedSet = wordPairSets.randomElement() ?? wordPairSets[0]
        
        // Create an array of all words
        words = []
        for pair in selectedSet {
            words.append(pair.0)
            words.append(pair.1)
        }
        
        // Shuffle the words
        words.shuffle()
        
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
    
    private func cardTapped(at index: Int) {
        // Add logic to handle card selection and matching
        if selectedCards.count == 0 {
            // First card selection
            selectedCards.append(index)
        } else if selectedCards.count == 1 && selectedCards[0] != index {
            // Second card selection (asegurarse de que no sea la misma carta)
            let firstIndex = selectedCards[0]
            let firstWord = words[firstIndex]
            let secondWord = words[index]
            
            selectedCards.append(index)
            disableCards = true
            
            // Check if they form a pair
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let isPair = checkIfPair(word1: firstWord, word2: secondWord)
                
                if isPair {
                    // Match found
                    matchedIndices.insert(firstIndex)
                    matchedIndices.insert(index)
                    foundPairs.append((firstWord, secondWord))
                    
                    // Check if game is over (all pairs found)
                    if matchedIndices.count == words.count {
                        gameEnded = true
                        endGame(withVictory: true)
                    }
                }
                
                selectedCards.removeAll()
                disableCards = false
            }
        }
    }
    
    private func checkIfPair(word1: String, word2: String) -> Bool {
        // Check if these two words form a pair in any of our word sets
        for set in wordPairSets {
            for (first, second) in set {
                if (word1 == first && word2 == second) || (word1 == second && word2 == first) {
                    return true
                }
            }
        }
        return false
    }
    
    private func endGame(withVictory: Bool = false) {
        timer?.invalidate()
        gameEnded = true
        
        // Calcula y guarda la XP ganada
        earnedXP = calculatedXP
        
        // Actualizar la XP usando el XPManager
        if !xpUpdated {
            xpManager.addXP(earnedXP)
            xpUpdated = true
        }
        
        showGameOverAlert = true
    }
}

// Card view for individual words
struct WordCardView: View {
    let word: String
    let isFlipped: Bool
    let isMatched: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(cardColor)
                .shadow(radius: 3)
            
            if isFlipped {
                Text(word)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(5)
                    .multilineTextAlignment(.center)
            } else {
                // Diseño del reverso de la carta
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .rotation3DEffect(
            .degrees(isFlipped ? 0 : 180),
            axis: (x: 0.0, y: 1.0, z: 0.0)
        )
        .animation(.easeInOut(duration: 0.3), value: isFlipped)
    }
    
    var cardColor: Color {
        if isMatched {
            return Color.green
        } else if isFlipped {
            return Color.blue
        } else {
            return Color(red: 0.2, green: 0.2, blue: 0.8)
        }
    }
}
