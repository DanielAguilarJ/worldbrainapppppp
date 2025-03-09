import SwiftUI

struct LessonStartModal: View {
    let lesson: Lesson
    let stage: Stage
    let stageManager: StageManager
    let stageIndex: Int
    @ObservedObject var xpManager: XPManager
    @Binding var isPresented: Bool
    @State private var showingLesson = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text(lesson.title)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                
                Text("Lección \(getLessonNumber()) de \(stage.lessons.count)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.top)
            
            // Descripción
            Text(lesson.description)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Botón de inicio
            Button {
                showingLesson = true
            } label: {
                Text("EMPEZAR MI LECCIÓN")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(stage.color)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .fullScreenCover(isPresented: $showingLesson) {
                LessonView(
                    lesson: lesson,
                    stage: stage,
                    stageManager: stageManager,
                    xpManager: xpManager,
                    stageIndex: stageIndex
                )
            }
        }
        .padding(.bottom)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .padding()
    }
    
    private func getLessonNumber() -> Int {
        if let index = stage.lessons.firstIndex(where: { $0.id == lesson.id }) {
            return index + 1
        }
        return 0
    }
}

