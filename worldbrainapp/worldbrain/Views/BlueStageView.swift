import SwiftUI

struct BlueStageView: View {
    @EnvironmentObject var progressManager: ProgressManager
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            // Encabezado
            HStack {
                VStack(alignment: .leading) {
                    Text("Etapa Azul")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Objetivo: 130 PPM - 95% comprensión")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                // Indicador de progreso
                ZStack {
                    Circle()
                        .stroke(lineWidth: 8.0)
                        .opacity(0.3)
                        .foregroundColor(Color.blue)
                    
                    Circle()
                        .trim(from: 0.0, to: progressManager.blueStageProgress)
                        .stroke(style: StrokeStyle(lineWidth: 8.0, lineCap: .round, lineJoin: .round))
                        .foregroundColor(Color.blue)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(progressManager.blueStageProgress * 100))%")
                        .font(.caption)
                        .bold()
                }
                .frame(width: 50, height: 50)
            }
            .padding()
            
            // Pestañas
            Picker("", selection: $selectedTab) {
                Text("Lecciones").tag(0)
                Text("Desafíos").tag(1)
                Text("Examen").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Contenido
            TabView(selection: $selectedTab) {
                LessonsListView(stage: .blue)
                    .tag(0)
                
                ChallengesListView(stage: .blue)
                    .tag(1)
                
                ExamView(stage: .blue)
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .onAppear {
            // Verificar si la etapa está desbloqueada
            if !progressManager.isStageUnlocked(.blue) {
                showLockScreen()
            }
        }
    }
    
    func showLockScreen() {
        selectedTab = 0 // Asegurarse de que estamos en la pestaña de lecciones
    }
}

struct BlueStageView_Previews: PreviewProvider {
    static var previews: some View {
        BlueStageView()
            .environmentObject(ProgressManager())
    }
}