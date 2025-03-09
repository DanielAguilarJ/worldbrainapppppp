//
//  LessonPathView.swift
//  worldbrainapp
//
//  Created by Daniel on 20/01/2025.
//  Vista mejorada para el camino de lecciones
//

import SwiftUI

struct LessonPathView: View {
    let stage: Stage
    let stageIndex: Int
    @ObservedObject var stageManager: StageManager
    @ObservedObject var xpManager: XPManager
    
    @State private var selectedLesson: Lesson?
    @State private var showingLessonModal = false
    @State private var animateItems = false
    
    var body: some View {
        ZStack {
            // Fondo con gradiente suave
            LinearGradient(
                gradient: Gradient(colors: [stage.color.opacity(0.1), Color.white]),
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header: Título, progreso y descripción de la etapa
                VStack(alignment: .leading, spacing: 15) {
                    // Banner de progreso
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(stage.color.opacity(0.1))
                            .frame(height: 60)
                            .cornerRadius(15)
                        
                        HStack {
                            // Círculo de progreso
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 5)
                                    .frame(width: 45, height: 45)
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(stage.completedLessonsCount) / CGFloat(stage.requiredLessons))
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [stage.color, stage.color.opacity(0.7)]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                                    )
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 45, height: 45)
                                    .animation(.easeInOut(duration: 1.0), value: animateItems)
                                
                                Text("\(stage.completedLessonsCount)/\(stage.requiredLessons)")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(stage.color)
                            }
                            .padding(.leading, 15)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(stage.name)
                                    .font(.headline)
                                    .foregroundColor(stage.color)
                                
                                Text("Progreso de la etapa")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 10)
                            
                            Spacer()
                        }
                    }
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .opacity(animateItems ? 1 : 0)
                    .offset(y: animateItems ? 0 : -10)
                    .animation(.easeOut(duration: 0.5), value: animateItems)
                    
                    Text(stage.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 5)
                        .padding(.horizontal, 2)
                        .opacity(animateItems ? 1 : 0)
                        .offset(y: animateItems ? 0 : -5)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: animateItems)
                }
                .padding(.horizontal)
                .padding(.top, 15)
                .padding(.bottom, 10)
                
                // Camino de lecciones (Lesson Path)
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(stage.lessons.enumerated()), id: \.element.id) { index, lesson in
                            VStack(spacing: 0) {
                                // Línea conectora (si no es la primera lección)
                                if index > 0 {
                                    if lesson.isLocked {
                                        // Línea punteada para lecciones bloqueadas
                                        VStack(spacing: 6) {
                                            ForEach(0..<5) { _ in
                                                Circle()
                                                    .fill(Color.gray.opacity(0.4))
                                                    .frame(width: 4, height: 4)
                                            }
                                        }
                                        .frame(height: 45)
                                    } else {
                                        // Línea sólida con gradiente para lecciones desbloqueadas
                                        Rectangle()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [stage.color.opacity(0.7), stage.color]),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .frame(width: 3, height: 45)
                                            .shadow(color: stage.color.opacity(0.3), radius: 3, x: 0, y: 0)
                                    }
                                }
                                
                                // Nodo de la lección
                                LessonNode(
                                    lesson: lesson,
                                    lessonNumber: index + 1,
                                    stageColor: stage.color,
                                    delay: Double(index) * 0.1,
                                    isAnimated: animateItems,
                                    onTap: {
                                        if !lesson.isLocked {
                                            selectedLesson = lesson
                                            showingLessonModal = true
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 50)
                }
            }
        }
        .sheet(isPresented: $showingLessonModal) {
            if let lesson = selectedLesson {
                LessonStartModal(
                    lesson: lesson,
                    stage: stage,
                    stageManager: stageManager,
                    stageIndex: stageIndex,
                    xpManager: xpManager,
                    isPresented: $showingLessonModal
                )
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .onAppear {
            // Activar animaciones cuando aparece la vista
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    animateItems = true
                }
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

// MARK: - Componentes personalizados

struct LessonNode: View {
    let lesson: Lesson
    let lessonNumber: Int
    let stageColor: Color
    let delay: Double
    let isAnimated: Bool
    let onTap: () -> Void
    
    @State private var isPulsing = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Efecto pulsante para lecciones actuales (desbloqueadas pero no completadas)
                if !lesson.isLocked && !lesson.isCompleted {
                    Circle()
                        .fill(stageColor.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .scaleEffect(isPulsing ? 1.2 : 0.9)
                        .opacity(isPulsing ? 0.6 : 0)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                }
                
                // Círculo principal
                Circle()
                    .fill(
                        lesson.isLocked ?
                            LinearGradient(
                                gradient: Gradient(colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.4)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [stageColor, stageColor.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .frame(width: 65, height: 65)
                    .shadow(
                        color: lesson.isLocked ? Color.clear : stageColor.opacity(0.4),
                        radius: 8, x: 0, y: 4
                    )
                
                // Contenido interior
                VStack(spacing: 4) {
                    if lesson.isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: getLessonIcon(lesson))
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                        
                        Text("\(lessonNumber)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                // Borde para lecciones completadas
                if lesson.isCompleted {
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 73, height: 73)
                    
                    // Estrellas que indican compleción
                    HStack(spacing: 4) {
                        ForEach(0..<3) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 12))
                                .shadow(color: Color.orange.opacity(0.5), radius: 1, x: 0, y: 0)
                        }
                    }
                    .offset(y: 40)
                }
                
                // Información de la lección
                if !lesson.isLocked {
                    HStack {
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(lesson.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            Text(lesson.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            // Badges informativos
                            HStack(spacing: 8) {
                                LessonBadge(
                                    icon: "clock",
                                    text: "\(lesson.timeLimit / 60)m",
                                    color: .blue
                                )
                                
                                if !lesson.questions.isEmpty {
                                    LessonBadge(
                                        icon: "questionmark.circle",
                                        text: "\(lesson.questions.count)",
                                        color: .orange
                                    )
                                }
                                
                                if lesson.type == .eyeTraining {
                                    LessonBadge(
                                        icon: "eye",
                                        text: "Ejercicio",
                                        color: .purple
                                    )
                                }
                            }
                        }
                    }
                    .padding(.leading, 80)
                    .padding(.trailing, 15)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .opacity(lesson.isLocked ? 0.5 : 1)
                    )
                    .padding(.trailing)
                    .padding(.leading, 40)
                    .opacity(lesson.isLocked ? 0 : 1)
                }
            }
            .opacity(isAnimated ? 1 : 0)
            .offset(x: isAnimated ? 0 : -20)
            .animation(.easeOut(duration: 0.5).delay(delay), value: isAnimated)
            .padding(.vertical, 5)
        }
        .disabled(lesson.isLocked)
        .onAppear {
            if !lesson.isLocked && !lesson.isCompleted {
                withAnimation {
                    isPulsing = true
                }
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

struct LessonBadge: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9))
            Text(text)
                .font(.system(size: 9, weight: .medium))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .foregroundColor(color)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(color.opacity(0.1))
        )
    }
}
