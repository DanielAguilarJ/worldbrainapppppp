import SwiftUI

struct LessonStartModal: View {
    let lesson: Lesson
    let stage: Stage
    let stageManager: StageManager
    let stageIndex: Int
    @ObservedObject var xpManager: XPManager
    @Binding var isPresented: Bool
    @State private var showingLesson = false
    
    // Animaciones
    @State private var appearAnimation = false
    @State private var iconRotation = false
    
    var body: some View {
        ZStack {
            // Fondo con gradiente
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }
            
            // Tarjeta principal con contenido
            VStack(spacing: 25) {
                // Ícono animado
                ZStack {
                    // Círculos decorativos
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(stage.color.opacity(0.3), lineWidth: 2)
                            .frame(width: 120 + CGFloat(i * 20), height: 120 + CGFloat(i * 20))
                            .scaleEffect(appearAnimation ? 1 : 0.8)
                            .opacity(appearAnimation ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2 + Double(i) * 0.1), value: appearAnimation)
                    }
                    
                    // Círculo principal con ícono
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [stage.color, stage.color.opacity(0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 110, height: 110)
                        .shadow(color: stage.color.opacity(0.5), radius: 10, x: 0, y: 5)
                        .overlay(
                            VStack {
                                Image(systemName: getLessonIcon(lesson))
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                                    .rotationEffect(.degrees(iconRotation ? 360 : 0))
                                    .animation(.spring(response: 1.5, dampingFraction: 0.8).delay(0.3), value: iconRotation)
                                
                                Text("\(getLessonNumber())")
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        )
                        .scaleEffect(appearAnimation ? 1 : 0.5)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: appearAnimation)
                }
                .padding(.top)
                
                // Información de la lección
                VStack(spacing: 12) {
                    Text("\(stage.name) - Lección \(getLessonNumber())")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(stage.color)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(0.2), value: appearAnimation)
                    
                    Text("Lección \(getLessonNumber()) de \(stage.lessons.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 15)
                        .animation(.easeOut(duration: 0.4).delay(0.3), value: appearAnimation)
                    
                    // Descripciones
                    Text(lesson.description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary.opacity(0.8))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 15)
                        .animation(.easeOut(duration: 0.4).delay(0.4), value: appearAnimation)
                }
                
                // Botones de acción
                VStack(spacing: 15) {
                    Button {
                        withAnimation {
                            showingLesson = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                                .font(.headline)
                            Text("COMENZAR LECCIÓN")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [stage.color, stage.color.opacity(0.8)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(15)
                        .shadow(color: stage.color.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .opacity(appearAnimation ? 1 : 0)
                    .scaleEffect(appearAnimation ? 1 : 0.9)
                    .animation(.easeOut(duration: 0.4).delay(0.5), value: appearAnimation)
                    
                    Button {
                        withAnimation {
                            isPresented = false
                        }
                    } label: {
                        Text("CANCELAR")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.6), value: appearAnimation)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 25)
            }
            .frame(width: UIScreen.main.bounds.width - 60)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        Color(.systemBackground)
                            .opacity(0.98)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
        }
        .fullScreenCover(isPresented: $showingLesson) {
            LessonView(
                lesson: lesson,
                stage: stage,
                stageManager: stageManager,
                xpManager: xpManager,
                stageIndex: stageIndex,
                onCloseLesson: {
                    isPresented = false
                }
            )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                appearAnimation = true
                iconRotation = true
            }
        }
    }
    
    private func getLessonNumber() -> Int {
        if let index = stage.lessons.firstIndex(where: { $0.id == lesson.id }) {
            return index + 1
        }
        return 0
    }
    
    private func getLessonIcon(_ lesson: Lesson) -> String {
        switch lesson.type {
        case .reading:
            return "book.fill"
        case .eyeTraining:
            return "eye.fill"
        case .speedReading:
            return "gauge.high"
        case .peripheralVision:
            return "eye.circle.fill"
        }
    }
}
