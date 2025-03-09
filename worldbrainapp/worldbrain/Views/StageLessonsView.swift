//
//  StageLessonsView.swift
//  worldbrainapp
//
//  Regresamos al ZStack overlay con popup para “Iniciar Lección”
//

import SwiftUI

struct StageLessonsView: View {
    let stage: Stage
    let stageIndex: Int
    @ObservedObject var stageManager: StageManager
    @ObservedObject var xpManager: XPManager
    
    // Para mostrar/ocultar el popup
    @State private var selectedLesson: Lesson?
    @State private var showingLessonPopup = false
    
    // Control para la LessonView a full screen
    @State private var showingLesson = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Encabezado de la Etapa
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
                
                // Camino de Lecciones
                VStack(spacing: 0) {
                    ForEach(Array(stage.lessons.enumerated()), id: \.element.id) { index, lesson in
                        VStack(spacing: 0) {
                            // Línea conectora
                            if index > 0 {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 4, height: 40)
                            }
                            
                            // Círculo de la lección
                            Button {
                                if !lesson.isLocked {
                                    selectedLesson = lesson
                                    showingLessonPopup = true
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
                            .disabled(lesson.isLocked)
                            .padding(.vertical, 10)
                        }
                    }
                }
                .padding(.vertical, 30)
            }
        }
        // ZStack overlay con el popup
        .overlay(
            ZStack {
                if showingLessonPopup, let lesson = selectedLesson {
                    // Fondo semitransparente
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showingLessonPopup = false
                        }
                    
                    // Contenido del popup
                    VStack(spacing: 20) {
                        // Ícono/círculo
                        Circle()
                            .fill(stage.color)
                            .frame(width: 100, height: 100)
                            .overlay(
                                VStack {
                                    Image(systemName: getLessonIcon(lesson))
                                        .font(.system(size: 40))
                                    Text("\(lessonTitleIndex(lesson))")
                                        .font(.title3)
                                }
                                .foregroundColor(.white)
                            )
                        
                        Text("\(stage.name) - Lección \(lessonTitleIndex(lesson))")
                            .font(.title2.bold())
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                        
                        Text("Lección \(lessonTitleIndex(lesson)) de \(stage.lessons.count)")
                            .foregroundColor(.gray)
                        
                        Text(lesson.description)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            // Al iniciar lección, cerramos popup y abrimos la LessonView
                            showingLessonPopup = false
                            showingLesson = true
                        }) {
                            Text("EMPEZAR MI LECCIÓN")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(stage.color)
                                .cornerRadius(12)
                        }
                    }
                    .padding(24)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding(.horizontal, 20)
                }
            }
        )
        // fullScreenCover para la LessonView
        .fullScreenCover(isPresented: $showingLesson) {
            if let lesson = selectedLesson {
                LessonView(
                    lesson: lesson,
                    stage: stage,
                    stageManager: stageManager,
                    xpManager: xpManager,
                    stageIndex: stageIndex
                ) {
                    // Al terminar la lección (o quiz), cierra la LessonView
                    showingLesson = false
                }
            }
        }
    }
    
    // Helper para íconos
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
    
    // Helper para mostrar en el popup
    private func lessonTitleIndex(_ lesson: Lesson) -> Int {
        if let idx = stage.lessons.firstIndex(where: { $0.id == lesson.id }) {
            return idx + 1
        }
        return 0
    }
}

