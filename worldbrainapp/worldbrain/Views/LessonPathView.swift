//
//  LessonPathView.swift
//  worldbrainapp
//
//  Created by Daniel on 20/01/2025.
//

import SwiftUI

struct LessonPathView: View {
    let stage: Stage
    let stageIndex: Int
    @ObservedObject var stageManager: StageManager
    @ObservedObject var xpManager: XPManager   // Agregamos xpManager aquí
    
    @State private var selectedLesson: Lesson?
    @State private var showingLessonModal = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header: Título, progreso y descripción de la etapa
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(stage.completedLessonsCount)/\(stage.requiredLessons)")
                        .font(.title3)
                        .bold()
                        .foregroundColor(stage.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(stage.color.opacity(0.1))
                        .clipShape(Capsule())
                    
                    Spacer()
                }
                
                Text(stage.name)
                    .font(.title)
                    .bold()
                
                Text(stage.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            
            // Camino de lecciones (Lesson Path)
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(stage.lessons.enumerated()), id: \.element.id) { index, lesson in
                        VStack(spacing: 0) {
                            // Línea conectora (si no es la primera lección)
                            if index > 0 {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 4, height: 40)
                            }
                            
                            // Círculo de la lección
                            Button {
                                if !lesson.isLocked {
                                    selectedLesson = lesson
                                    showingLessonModal = true
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(lesson.isLocked ? Color.gray : stage.color)
                                        .frame(width: 60, height: 60)
                                    
                                    if lesson.isLocked {
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(.white)
                                    } else {
                                        VStack {
                                            Image(systemName: getLessonIcon(lesson))
                                                .font(.system(size: 20))
                                            Text("\(index + 1)")
                                                .font(.caption2)
                                        }
                                        .foregroundColor(.white)
                                    }
                                    
                                    if lesson.isCompleted {
                                        Circle()
                                            .strokeBorder(Color.yellow, lineWidth: 3)
                                            .frame(width: 66, height: 66)
                                    }
                                }
                            }
                            
                            // Estrellas para lecciones completadas
                            if lesson.isCompleted {
                                HStack(spacing: 4) {
                                    ForEach(0..<3) { _ in
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                            .font(.system(size: 12))
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
                .padding(.vertical)
            }
        }
        // Popup superpuesto para iniciar la lección
        .sheet(isPresented: $showingLessonModal) {
            if let lesson = selectedLesson {
                LessonStartModal(
                    lesson: lesson,
                    stage: stage,
                    stageManager: stageManager,
                    stageIndex: stageIndex,
                    xpManager: xpManager,         // Se pasa xpManager aquí
                    isPresented: $showingLessonModal
                )
            }
        }
    }
    
    private func getLessonIcon(_ lesson: Lesson) -> String {
        switch lesson.type {
        case .reading:
            return "book.fill"
        case .eyeTraining:
            return "eye.fill"
        case .speedReading:
            return "gauge.high"
        }
    }
}

 
