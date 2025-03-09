//
//  StageManager.swift
//  worldbrain
//
//  Created by Daniel on 20/01/2025.
//
import SwiftUI
import AVFoundation

class StageManager: ObservableObject {
    @Published var stages: [Stage] = []
    @Published var selectedStage: Stage?
    
    init() {
        loadStages()
        unlockFirstStage()
    }
    
    private func loadStages() {
        // Etapa Verde (Principiante)
        let greenStage = Stage(
            name: "Etapa Verde",
            color: .green,
            description: "Fundamentos de la fotolectura",
            requiredLessons: 30,
            lessons: generateLessons(count: 30, prefix: "Principiante"),
            isLocked: true
        )
        
        // Etapa Azul (Intermedio)
        let blueStage = Stage(
            name: "Etapa Azul",
            color: .blue,
            description: "Técnicas intermedias",
            requiredLessons: 30,
            lessons: generateLessons(count: 30, prefix: "Intermedio"),
            isLocked: true
        )
        
        // Etapa Roja (Avanzado)
        let redStage = Stage(
            name: "Etapa Roja",
            color: .red,
            description: "Técnicas avanzadas",
            requiredLessons: 30,
            lessons: generateLessons(count: 30, prefix: "Avanzado"),
            isLocked: true
        )
        
        // Etapa Negra (Experto)
        let blackStage = Stage(
            name: "Etapa Negra",
            color: .black,
            description: "Dominio de la fotolectura",
            requiredLessons: 30,
            lessons: generateLessons(count: 30, prefix: "Experto"),
            isLocked: true
        )
        
        stages = [greenStage, blueStage, redStage, blackStage]
    }
    
    private func generateLessons(count: Int, prefix: String) -> [Lesson] {
        var lessons: [Lesson] = []
        for i in 1...count {
            lessons.append(Lesson(
                title: "\(prefix) - Lección \(i)",
                description: "Descripción de la lección \(i) del nivel \(prefix)",
                content: "Contenido de la lección \(i)...",
                timeLimit: 180,
                questions: [
                    Question(
                        text: "Pregunta de prueba para \(prefix) lección \(i)",
                        options: [
                            "Opción 1",
                            "Opción 2",
                            "Opción 3",
                            "Opción 4"
                        ],
                        correctAnswer: 0
                    )
                ]
            ))
        }
        return lessons
    }
    
    private func unlockFirstStage() {
        if !stages.isEmpty {
            stages[0].isLocked = false
            stages[0].lessons[0].isLocked = false
        }
    }
    
    func completeLesson(stageIndex: Int, lessonId: UUID) {
        guard stageIndex < stages.count,
              let lessonIndex = stages[stageIndex].lessons.firstIndex(where: { $0.id == lessonId }) else { return }
        
        // Marcar la lección como completada
        stages[stageIndex].lessons[lessonIndex].isCompleted = true
        
        // Desbloquear siguiente lección si existe
        if lessonIndex + 1 < stages[stageIndex].lessons.count {
            stages[stageIndex].lessons[lessonIndex + 1].isLocked = false
        }
        
        // Si se completó la etapa, desbloquear la siguiente
        if stages[stageIndex].isCompleted && stageIndex + 1 < stages.count {
            stages[stageIndex + 1].isLocked = false
            stages[stageIndex + 1].lessons[0].isLocked = false
        }
        
        objectWillChange.send()
    }
}

