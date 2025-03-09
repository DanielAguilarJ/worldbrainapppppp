import SwiftUI

struct LessonCompletedView: View {
    let lesson: Lesson
    let stage: Stage
    let score: Int
    let totalQuestions: Int
    @State private var showingPoints = false
    @State private var showingStars = false
    @State private var animateProgress = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            stage.color.opacity(0.1).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Corona de estrellas
                ZStack {
                    ForEach(0..<3) { index in
                        Image(systemName: "star.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.yellow)
                            .offset(x: CGFloat(index - 1) * 40)
                            .opacity(showingStars ? 1 : 0)
                            .scaleEffect(showingStars ? 1 : 0.1)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6).delay(Double(index) * 0.1),
                                     value: showingStars)
                    }
                }
                .padding(.top, 40)
                
                // Círculo con icono
                Circle()
                    .fill(stage.color)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    )
                    .scaleEffect(showingPoints ? 1 : 0.1)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showingPoints)
                
                Text("¡Lección Completada!")
                    .font(.title)
                    .bold()
                    .opacity(showingPoints ? 1 : 0)
                    .animation(.easeIn.delay(0.3), value: showingPoints)
                
                VStack(spacing: 10) {
                    Text("\(score) de \(totalQuestions) respuestas correctas")
                        .font(.title3)
                    
                    // Barra de progreso
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 20)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(stage.color)
                            .frame(width: animateProgress ? UIScreen.main.bounds.width * 0.7 * CGFloat(score) / CGFloat(totalQuestions) : 0,
                                   height: 20)
                            .animation(.easeOut(duration: 1.0).delay(0.5), value: animateProgress)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.7)
                }
                .opacity(showingPoints ? 1 : 0)
                .animation(.easeIn.delay(0.4), value: showingPoints)
                
                // Puntos XP
                VStack(spacing: 5) {
                    Text("+50 XP")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(stage.color)
                    
                    Text("¡Sigue así!")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .opacity(showingPoints ? 1 : 0)
                .offset(y: showingPoints ? 0 : 20)
                .animation(.easeIn.delay(0.5), value: showingPoints)
                
                Spacer()
                
                // Botón continuar
                Button {
                    withAnimation {
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Text("CONTINUAR")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(stage.color)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
                .opacity(showingPoints ? 1 : 0)
                .animation(.easeIn.delay(0.6), value: showingPoints)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Secuencia de animaciones
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showingStars = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showingPoints = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            animateProgress = true
        }
    }
}

struct LessonCompletedView_Previews: PreviewProvider {
    static var previews: some View {
        LessonCompletedView(
            lesson: Lesson(
                title: "Lección de prueba",
                description: "Descripción",
                type: .reading,
                timeLimit: 180,
                content: "Contenido",
                questions: [],
                eyeExercises: nil
            ),
            stage: Stage(
                name: "Etapa Verde",
                color: .green,
                description: "Fundamentos",
                requiredLessons: 30,
                lessons: [],
                isLocked: false
            ),
            score: 8,
            totalQuestions: 10
        )
    }
}