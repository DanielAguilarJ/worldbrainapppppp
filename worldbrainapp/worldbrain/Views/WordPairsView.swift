//
//  WordPairsView.swift
//  worldbrainapp
//
//  Vista para el desafío de pares de palabras
//

import SwiftUI

struct WordPairsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var timeRemaining = 120
    @State private var timer: Timer? = nil
    @State private var foundPairs: [(String, String)] = []
    @State private var selectedCards: [Int] = []
    @State private var words: [String] = []
    @State private var matchedIndices: Set<Int> = []
    @State private var disableCards = false
    
    // Conjuntos de pares de palabras para variedad
    let wordPairSets: [[(String, String)]] = [
        // Set 1
        [("perro", "gato"), ("sol", "luna"), ("día", "noche"), ("agua", "fuego"), 
         ("blanco", "negro"), ("alto", "bajo"), ("frío", "calor"), ("feliz", "triste"),
         ("amor", "odio"), ("dulce", "salado"), ("abrir", "cerrar"), ("rápido", "lento"),
         ("grande", "pequeño"), ("rico", "pobre"), ("joven", "viejo")],
         
        // Set 2
        [("cielo", "tierra"), ("mar", "montaña"), ("entrada", "salida"), ("arriba", "abajo"),
         ("comenzar", "terminar"), ("primero", "último"), ("ganar", "perder"), ("nacer", "morir"),
         ("verdad", "mentira"), ("amigo", "enemigo"), ("lleno", "vacío"), ("duro", "suave"),
         ("fuerte", "débil"), ("seco", "mojado"), ("nuevo", "viejo")],
         
        // Set 3
        [("niño", "adulto"), ("hablar", "escuchar"), ("izquierda", "derecha"), ("pasado", "futuro"),
         ("pregunta", "respuesta"), ("fácil", "difícil"), ("guerra", "paz"), ("éxito", "fracaso"),
         ("llegar", "partir"), ("bonito", "feo"), ("comprar", "vender"), ("recordar", "olvidar"),
         ("bueno", "malo"), ("ruido", "silencio"), ("permitir", "prohibir")]
    ]
    
    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
            
            VStack {
                // Timer and score header
                HStack {
                    Spacer()
                    
                    VStack {
                        Text(formattedTime)
                            .font(.system(size: 42, weight: .bold))
                        
                        Text("Pares encontrados: \(foundPairs.count)")
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        timer?.invalidate()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cerrar")
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
                .padding(.top)
                
                // Word cards grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                    ForEach(0..<words.count, id: \.self) { index in
                        WordCardView(
                            word: words[index],
                            isFlipped: selectedCards.contains(index) || matchedIndices.contains(index),
                            isMatched: matchedIndices.contains(index)
                        )
                        .aspectRatio(1, contentMode: .fit)
                        .onTapGesture {
                            cardTapped(at: index)
                        }
                        .disabled(disableCards || matchedIndices.contains(index) || selectedCards.contains(index))
                    }
                }
                .padding()
                
                Spacer()
            }
            .padding()
            .onAppear {
                setupGame()
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }
    
    private func setupGame() {
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
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                endGame()
            }
        }
    }
    
    private func cardTapped(at index: Int) {
        // Add logic to handle card selection and matching
        if selectedCards.count == 0 {
            // First card selection
            selectedCards.append(index)
        } else if selectedCards.count == 1 {
            // Second card selection
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
                }
                
                selectedCards.removeAll()
                disableCards = false
                
                // Check if game is over (all pairs found)
                if matchedIndices.count == words.count {
                    endGame()
                }
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
    
    private func endGame() {
        timer?.invalidate()
        // Could show an alert or game over screen here
    }
}

// Card view for individual words
struct WordCardView: View {
    let word: String
    let isFlipped: Bool
    let isMatched: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(cardColor)
                .shadow(radius: 2)
            
            if isFlipped {
                Text(word)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(5)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    var cardColor: Color {
        if isMatched {
            return Color.green
        } else if isFlipped {
            return Color.blue
        } else {
            return Color.indigo
        }
    }
}