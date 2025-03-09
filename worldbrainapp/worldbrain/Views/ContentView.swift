import SwiftUI

struct ContentView: View {
    @StateObject private var stageManager = StageManager()
    @StateObject private var xpManager = XPManager()
    
    // Control para abrir/cerrar el selector de curso
    @State private var showingCourseSelector = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Barra superior
            HStack {
                // Botón para seleccionar curso
                Button(action: {
                    showingCourseSelector = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "book.fill")
                            .foregroundColor(.blue)
                        Text("Fotolectura")
                            .font(.headline)
                            .foregroundColor(.blue)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                Spacer()
                
                // Mostrar XP y nivel usando XPManager
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(xpManager.currentXP)")
                        .font(.headline)
                    Text("(\(xpManager.readerLevel.rawValue))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
            
            // Mostrar la primera etapa disponible (se asume que stageManager.stages no está vacío)
            if let firstUnlockedStage = stageManager.stages.first(where: { !$0.isLocked }) {
                StageLessonsView(
                    stage: firstUnlockedStage,
                    stageIndex: stageManager.stages.firstIndex(where: { $0.id == firstUnlockedStage.id }) ?? 0,
                    stageManager: stageManager,
                    xpManager: xpManager
                )
            } else {
                Text("No hay etapas disponibles")
                    .padding()
            }
        }
        .sheet(isPresented: $showingCourseSelector) {
            CourseSelectorView()
        }
    }
}

