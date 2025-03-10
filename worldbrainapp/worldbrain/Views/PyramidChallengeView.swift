import SwiftUI

struct PyramidChallengeView: View {
    @ObservedObject var xpManager: XPManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedExercise: PyramidTextExercise? = nil
    @State private var showingExercise = false
    @State private var animateElements = false
    
    private let exercises = PyramidTextExercise.sampleExercises
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.2), Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom header
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                            Text("Atrás")
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
                    
                    Text("Visión Periférica")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Invisible element for balanced layout
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 35)
                }
                .padding(.top, 50)
                .padding(.horizontal)
                
                // Introduction and info
                VStack(spacing: 20) {
                    Image(systemName: "eye.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                        .padding(.top, 20)
                        .opacity(animateElements ? 1 : 0)
                        .scaleEffect(animateElements ? 1 : 0.7)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animateElements)
                    
                    Text("Entrenamiento de Visión Periférica")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .opacity(animateElements ? 1 : 0)
                        .offset(y: animateElements ? 0 : 10)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: animateElements)
                    
                    Text("Estos ejercicios te ayudarán a expandir tu campo de visión para captar más información mientras mantienes la mirada fija en un punto específico.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 30)
                        .opacity(animateElements ? 1 : 0)
                        .offset(y: animateElements ? 0 : 10)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: animateElements)
                    
                    // Benefits
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Beneficios:")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        BenefitRow(icon: "book.fill", text: "Mayor velocidad de lectura")
                        BenefitRow(icon: "brain.head.profile", text: "Mejora la concentración visual")
                        BenefitRow(icon: "eyes.inverse", text: "Reduce la fatiga ocular")
                        BenefitRow(icon: "speedometer", text: "Aumenta la eficiencia lectora")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                    .opacity(animateElements ? 1 : 0)
                    .offset(y: animateElements ? 0 : 15)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: animateElements)
                }
                
                // Exercise list
                Text("Selecciona un ejercicio:")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 30)
                    .padding(.top, 25)
                    .padding(.bottom, 5)
                    .opacity(animateElements ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: animateElements)
                
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                            PyramidExerciseCard(
                                exercise: exercise,
                                index: index + 1,
                                onSelect: {
                                    print("Seleccionando ejercicio: \(exercise.title)")
                                    selectedExercise = exercise
                                    showingExercise = true
                                }
                            )
                            .opacity(animateElements ? 1 : 0)
                            .offset(y: animateElements ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.4 + Double(index) * 0.1), value: animateElements)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .fullScreenCover(isPresented: $showingExercise) {
            if let exercise = selectedExercise {
                PyramidTextView(exercise: exercise, xpManager: xpManager)
            } else {
                // Fallback por si el ejercicio es nil (no debería ocurrir)
                Text("Error: No se pudo cargar el ejercicio")
                    .onAppear {
                        print("Error: selectedExercise es nil")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            showingExercise = false
                        }
                    }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    animateElements = true
                }
            }
        }
    }
    
    // Benefit row component
    struct BenefitRow: View {
        let icon: String
        let text: String
        
        var body: some View {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.green)
                    .frame(width: 24)
                
                Text(text)
                    .font(.body)
                
                Spacer()
            }
        }
    }
    
    // Card for each exercise
    struct PyramidExerciseCard: View {
        let exercise: PyramidTextExercise
        let index: Int
        let onSelect: () -> Void
        
        var body: some View {
            Button(action: {
                // Llamada directa a la función onSelect
                onSelect()
            }) {
                HStack(spacing: 15) {
                    // Circular icon with exercise number
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.green, .green.opacity(0.7)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 50, height: 50)
                            .shadow(color: Color.green.opacity(0.3), radius: 3, x: 0, y: 2)
                        
                        Text("\(index)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // Exercise info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(exercise.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        // Difficulty indicator
                        HStack(spacing: 3) {
                            ForEach(0..<3) { i in
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(i < exercise.difficulty ? .green : .gray.opacity(0.3))
                            }
                            Text("Dificultad: \(difficultyString(level: exercise.difficulty))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 5)
                        }
                        .padding(.top, 5)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.green)
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
            // Efecto visual al presionar
            .scaleEffect(0.98)
            .animation(.spring(), value: 0.98)
        }
        
        private func difficultyString(level: Int) -> String {
            switch level {
            case 1: return "Básico"
            case 2: return "Intermedio"
            case 3: return "Avanzado"
            default: return "Personalizado"
            }
        }
    }
}
