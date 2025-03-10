import SwiftUI

struct LessonsListView: View {
    @EnvironmentObject var progressManager: ProgressManager
    let stage: StageType
    
    var lessons: [Lesson] {
        progressManager.getLessons(for: stage)
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
                    ForEach(lessons) { lesson in
                        LessonCardView(lesson: lesson)
                            .padding(.horizontal)
                    }
                    
                    // Mensaje de completado si todas las lecciones están terminadas
                    if progressManager.areAllLessonsCompleted(for: stage) {
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.green)
                            
                            Text("¡Todas las lecciones completadas!")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Puedes continuar con los desafíos o realizar el examen para avanzar a la siguiente etapa.")
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.1))
                        )
                        .padding()
                    }
                }
                .padding(.vertical)
            }
        }
    }
}

struct LessonCardView: View {
    let lesson: Lesson
    @EnvironmentObject var progressManager: ProgressManager
    @State private var showingLesson = false
    
    var body: some View {
        Button(action: {
            showingLesson = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(lesson.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(lesson.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Label("\(lesson.targetWPM) PPM", systemImage: "speedometer")
                            .font(.caption)
                        
                        if let userWPM = lesson.userWPM {
                            Text("Tu mejor: \(userWPM) PPM")
                                .font(.caption)
                                .foregroundColor(userWPM >= lesson.targetWPM ? .green : .orange)
                        }
                    }
                }
                
                Spacer()
                
                // Indicador de estado
                ZStack {
                    Circle()
                        .fill(lesson.isCompleted ? Color.green : Color.blue.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    if lesson.isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "book")
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingLesson) {
            LessonDetailView(lesson: lesson)
        }
    }
}

struct StageLockedView: View {
    let stage: StageType
    @EnvironmentObject var progressManager: ProgressManager
    
    var previousStage: StageType? {
        switch stage {
        case .green: return nil
        case .blue: return .green
        case .red: return .blue
        case .black: return .red
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .resizable()
                .frame(width: 70, height: 100)
                .foregroundColor(.gray)
                .padding()
            
            Text("Etapa \(stage.rawValue) Bloqueada")
                .font(.title)
                .fontWeight(.bold)
            
            if let previous = previousStage {
                Text("Completa el examen de la etapa \(previous.rawValue) para desbloquear esta etapa.")
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button(action: {
                    // Navegar al examen de la etapa anterior
                    progressManager.navigateToExam(of: previous)
                }) {
                    Text("Ir al examen de la etapa \(previous.rawValue)")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue)
                        )
                }
            } else {
                Text("Esta etapa no está disponible todavía.")
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding()
    }
}

struct LessonsListView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsListView(stage: .blue)
            .environmentObject(ProgressManager())
    }
}