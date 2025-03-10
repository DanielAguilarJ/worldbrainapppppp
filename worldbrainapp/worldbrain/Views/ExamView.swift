//
//  ExamView.swift
//  worldbrainapp
//
//  Created by msc on 10/03/2025.
//


//
//  ExamView.swift
//  worldbrainapp
//
//  Created by msc on 10/03/2025.
//

import SwiftUI

struct ExamView: View {
    let stage: StageType
    @EnvironmentObject var progressManager: ProgressManager
    
    @State private var showingExamContent = false
    @State private var showingExamLocked = true
    
    var body: some View {
        VStack {
            if !progressManager.isStageUnlocked(stage) || !progressManager.areAllLessonsCompleted(for: stage) {
                // Si la etapa está bloqueada o no se han completado todas las lecciones
                examLockedView()
            } else if showingExamContent {
                // Contenido del examen
                examContentView()
            } else {
                // Vista de inicio del examen
                examStartView()
            }
        }
    }
    
    // Vista cuando el examen está bloqueado
    private func examLockedView() -> some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "lock.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70, height: 80)
                .foregroundColor(.gray)
            
            Text("Examen no disponible")
                .font(.title)
                .fontWeight(.bold)
            
            if !progressManager.isStageUnlocked(stage) {
                Text("Debes completar la etapa anterior para acceder a este examen.")
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                Text("Completa todas las lecciones de esta etapa para desbloquear el examen.")
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Mostrar progreso
                HStack {
                    Text("Progreso: \(Int(progressManager.blueStageProgress * 100))%")
                    Spacer()
                    ProgressView(value: progressManager.blueStageProgress)
                        .frame(width: 150)
                }
                .padding()
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // Vista de inicio del examen
    private func examStartView() -> some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "graduationcap.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            
            Text("Examen Final - Etapa \(stage.rawValue)")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Este examen evaluará tu capacidad para leer a 130 palabras por minuto con una comprensión del 95%.")
                .multilineTextAlignment(.center)
                .padding()
            
            VStack(alignment: .leading, spacing: 15) {
                ExamInfoRow(icon: "clock.fill", text: "Tiempo: 15-20 minutos")
                ExamInfoRow(icon: "book.fill", text: "Lectura: Texto de mediana complejidad")
                ExamInfoRow(icon: "list.bullet.clipboard", text: "Preguntas: 5 de comprensión")
                ExamInfoRow(icon: "speedometer", text: "Objetivo: 130 PPM mínimo")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .padding()
            
            Button(action: {
                withAnimation {
                    showingExamContent = true
                }
            }) {
                Text("Comenzar Examen")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // Vista del contenido del examen
    private func examContentView() -> some View {
        VStack {
            Text("Examen en Construcción")
                .font(.headline)
                .padding()
            
            Text("Esta función estará disponible en la próxima actualización.")
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                withAnimation {
                    showingExamContent = false
                }
            }) {
                Text("Volver")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}

// Fila informativa para la vista del examen
struct ExamInfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 25)
            
            Text(text)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct ExamView_Previews: PreviewProvider {
    static var previews: some View {
        ExamView(stage: .blue)
            .environmentObject(ProgressManager(stageManager: StageManager(), xpManager: XPManager()))
    }
}