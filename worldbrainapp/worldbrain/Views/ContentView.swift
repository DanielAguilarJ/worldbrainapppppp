import SwiftUI

struct ContentView: View {
    @StateObject private var stageManager = StageManager()
    @StateObject private var xpManager = XPManager()
    // Control para abrir/cerrar el selector de curso
    @State private var showingCourseSelector = false
    @State private var animateHeader = false
    @StateObject private var progressManager = ProgressManager(stageManager: stageManager, xpManager: xpManager)

    
    var body: some View {
        VStack(spacing: 0) {
            // Barra superior mejorada
            headerView
            
            // Mostrar la primera etapa disponible
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
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                animateHeader = true
            }
        }
    }
    
    private var headerView: some View {
        ZStack {
            // Fondo con gradiente basado en el color de la etapa actual
            if let currentStage = stageManager.stages.first(where: { !$0.isLocked }) {
                LinearGradient(
                    gradient: Gradient(colors: [currentStage.color.opacity(0.1), Color.white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 70)
            }
            
            HStack {
                // Botón mejorado para seleccionar curso
                Button(action: {
                    showingCourseSelector = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(
                                stageManager.stages.first(where: { !$0.isLocked })?.color ?? .blue
                            )
                        
                        Text("Fotolectura")
                            .font(.headline)
                            .foregroundColor(
                                stageManager.stages.first(where: { !$0.isLocked })?.color ?? .blue
                            )
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(
                                stageManager.stages.first(where: { !$0.isLocked })?.color ?? .blue
                            )
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                stageManager.stages.first(where: { !$0.isLocked })?.color.opacity(0.1) ??
                                Color.blue.opacity(0.1)
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                }
                .scaleEffect(animateHeader ? 1 : 0.9)
                .opacity(animateHeader ? 1 : 0)
                
                Spacer()
                
                // Indicador de XP y nivel mejorado
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 16))
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(xpManager.currentXP) XP")
                            .font(.system(size: 14, weight: .bold))
                        
                        Text("\(xpManager.readerLevel.rawValue)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.2),
                            Color.yellow.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                )
                .scaleEffect(animateHeader ? 1 : 0.9)
                .opacity(animateHeader ? 1 : 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
}
