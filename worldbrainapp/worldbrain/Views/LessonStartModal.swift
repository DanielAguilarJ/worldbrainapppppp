//
//  LessonStartModal.swift
//  worldbrainapp
//
//  Created by Daniel on 20/01/2025.
//


struct LessonStartModal: View {
    let lesson: Lesson
    let stage: Stage
    @ObservedObject var stageManager: StageManager
    let stageIndex: Int
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text(lesson.title)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                
                Text("Lección \(stageManager.getLessonNumber(for: lesson)) de \(stage.lessons.count)")
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
                isPresented = false
                // Aquí puedes agregar una pequeña demora antes de navegar a la lección
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    // Navegar a la lección
                }
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
        }
        .padding(.bottom)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .padding()
    }
}