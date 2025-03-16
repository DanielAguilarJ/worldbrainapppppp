//
//  StageLessonsView.swift
//  worldbrainapp
//
//  Vista mejorada para mostrar etapas y lecciones
//

import SwiftUI

struct StageLessonsView: View {
    let stage: Stage
    let stageIndex: Int
    @ObservedObject var stageManager: StageManager
    @ObservedObject var xpManager: XPManager
    
    // Para mostrar/ocultar el popup
    @State private var selectedLesson: LessonFromModelsFile?
    @State private var showingLessonPopup = false
    
    // Control para la LessonView a full screen
    @State private var showingLesson = false
    
    // Animación de elementos
    @State private var appearElements = false
    
    var body: some View {
        ZStack {
            // Gradiente de fondo
            LinearGradient(
                gradient: Gradient(colors: [stage.color.opacity(0.15), Color.white]),
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 5) {
                    // Encabezado de la Etapa con animación
                    stageHeaderView()
                    
                    // Camino de Lecciones
                    lessonsPathView()
                }
            }
        }
        .overlay(
            lessonPopupView()
        )
        .fullScreenCover(isPresented: $showingLesson) {
            if let lesson = selectedLesson {
                LessonView(
                    lesson: convertToLesson(lesson),
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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    appearElements = true
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private func stageHeaderView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(stage.name)
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(stage.color)
                    
                    Text(stage.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .opacity(appearElements ? 1 : 0)
                .offset(x: appearElements ? 0 : -20)
                .animation(.easeOut(duration: 0.5), value: appearElements)
                
                Spacer()
                
                // Progreso circular animado
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                        .frame(width: 70, height: 70)
                    
                    Circle()
                        .trim(from: 0.0, to: appearElements ? CGFloat(stage.completedLessonsCount) / CGFloat(stage.requiredLessons) : 0.0)
                        .stroke(stage.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.2).delay(0.5), value: appearElements)
                    
                    Text("\(stage.completedLessonsCount)/\(stage.requiredLessons)")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(stage.color)
                }
                .opacity(appearElements ? 1 : 0)
                .scaleEffect(appearElements ? 1 : 0.7)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: appearElements)
            }
            
            // Barra de progreso horizontal
            ProgressBar(value: CGFloat(stage.completedLessonsCount), total: CGFloat(stage.requiredLessons), color: stage.color)
                .frame(height: 8)
                .clipShape(Capsule())
                .opacity(appearElements ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: appearElements)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 15)
    }
    
    @ViewBuilder
    private func lessonsPathView() -> some View {
        VStack(spacing: 0) {
            ForEach(Array(stage.lessons.enumerated()), id: \.element.id) { index, lesson in
                VStack(spacing: 0) {
                    // Línea conectora
                    if index > 0 {
                        if lesson.isLocked {
                            DashedConnector(color: Color.gray.opacity(0.5))
                                .frame(width: 4, height: 40)
                                .opacity(appearElements ? 1 : 0)
                                .animation(.easeOut(duration: 0.4).delay(0.3 + 0.05 * Double(index)), value: appearElements)
                        } else {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [stage.color.opacity(0.7), stage.color]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 4, height: 40)
                                .opacity(appearElements ? 1 : 0)
                                .animation(.easeOut(duration: 0.4).delay(0.3 + 0.05 * Double(index)), value: appearElements)
                        }
                    }
                    
                    // Nodo de la lección
                    LessonCircleNode(
                        lesson: lesson,
                        lessonNumber: index + 1,
                        stageColor: stage.color,
                        onClick: {
                            if !lesson.isLocked {
                                selectedLesson = lesson
                                showingLessonPopup = true
                            }
                        }
                    )
                    .scaleEffect(appearElements ? 1 : 0.7)
                    .opacity(appearElements ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3 + 0.1 * Double(index)), value: appearElements)
                }
                .padding(.vertical, 8)
            }
        }
        .padding(.vertical, 20)
    }
    
    @ViewBuilder
    private func lessonPopupView() -> some View {
        ZStack {
            // Modal para iniciar lección
            if showingLessonPopup, let lesson = selectedLesson {
                LessonPopup(
                    lesson: lesson,
                    stage: stage,
                    lessonNumber: getLessonNumber(lesson),
                    totalLessons: stage.lessons.count,
                    xpManager: xpManager,  // Pasando el xpManager
                    onStart: {
                        showingLessonPopup = false
                        showingLesson = true
                    },
                    onClose: {
                        showingLessonPopup = false
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingLessonPopup)
    }
    
    // MARK: - Helper Functions
    
    private func getLessonNumber(_ lesson: LessonFromModelsFile) -> Int {
        if let idx = stage.lessons.firstIndex(where: { $0.id == lesson.id }) {
            return idx + 1
        }
        return 0
    }
    
    // Convert LessonFromModelsFile to Lesson type for LessonView
    private func convertToLesson(_ lessonFromModel: LessonFromModelsFile) -> Lesson {
        return Lesson(
            title: lessonFromModel.title,
            description: lessonFromModel.description,
            type: lessonFromModel.type,
            timeLimit: lessonFromModel.timeLimit,
            content: lessonFromModel.content,
            questions: lessonFromModel.questions,
            isCompleted: lessonFromModel.isCompleted,
            isLocked: lessonFromModel.isLocked,
            eyeExercises: lessonFromModel.eyeExercises,
            pyramidExercise: lessonFromModel.pyramidExercise
        )
    }
}

// MARK: - Componentes UI

// Barra de progreso personalizable
struct ProgressBar: View {
    var value: CGFloat
    var total: CGFloat
    var color: Color
    @State private var width: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
            
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [color.opacity(0.8), color]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width)
                .animation(.easeInOut(duration: 1.0), value: width)
        }
        .onAppear {
            self.width = (value / total) * UIScreen.main.bounds.width
        }
        .onChange(of: value) { newValue in
            self.width = (newValue / total) * UIScreen.main.bounds.width
        }
    }
}

// Línea conectora con forma de puntos
struct DashedConnector: View {
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<6) { _ in
                Circle()
                    .fill(color)
                    .frame(width: 3, height: 3)
            }
        }
    }
}

// Nodo del círculo de lección
struct LessonCircleNode: View {
    let lesson: LessonFromModelsFile
    let lessonNumber: Int
    let stageColor: Color
    let onClick: () -> Void
    
    @State private var isPulsing = false
    
    var body: some View {
        Button(action: onClick) {
            ZStack {
                // Sombra animada para lecciones desbloqueadas
                if !lesson.isLocked {
                    Circle()
                        .fill(stageColor.opacity(0.3))
                        .frame(width: 75, height: 75)
                        .scaleEffect(isPulsing ? 1.1 : 1)
                        .opacity(isPulsing ? 0.6 : 0)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                        .onAppear {
                            if !lesson.isLocked && !lesson.isCompleted {
                                self.isPulsing = true
                            }
                        }
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
                                gradient: Gradient(colors: [stageColor.opacity(0.9), stageColor]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .frame(width: 65, height: 65)
                    .shadow(color: lesson.isLocked ? Color.clear : stageColor.opacity(0.4), radius: 8, x: 0, y: 4)
                
                // Ícono o número
                Group {
                    if lesson.isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.system(size: 22))
                    } else {
                        VStack(spacing: 3) {
                            Image(systemName: getLessonIcon(lesson))
                                .font(.system(size: 20))
                            Text("\(lessonNumber)")
                                .font(.system(size: 12, weight: .bold))
                        }
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
                        .frame(width: 72, height: 72)
                    
                    // Estrellas para lecciones completadas
                    ForEach(0..<3) { starIndex in
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 12))
                            .offset(
                                x: CGFloat(starIndex - 1) * 15,
                                y: 42
                            )
                            .shadow(color: Color.orange.opacity(0.5), radius: 2, x: 0, y: 1)
                    }
                }
            }
        }
        .disabled(lesson.isLocked)
    }
    
    private func getLessonIcon(_ lesson: LessonFromModelsFile) -> String {
        switch lesson.type {
        case .reading:
            return "book.fill"
        case .eyeTraining:
            return "eye.fill"
        case .speedReading:
            return "gauge.high"
        case .peripheralVision:
            return "eye.circle.fill"
        }
    }
}

// Popup para iniciar lección
struct LessonPopup: View {
    let lesson: LessonFromModelsFile
    let stage: Stage
    let lessonNumber: Int
    let totalLessons: Int
    let xpManager: XPManager
    let onStart: () -> Void
    let onClose: () -> Void
    
    @State private var appearAnimation = false
    
    var body: some View {
        ZStack {
            // Fondo oscuro con desenfoque
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }
            
            // Contenido principal
            VStack(spacing: 20) {
                // Cabecera con imagen
                VStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [stage.color.opacity(0.8), stage.color]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: stage.color.opacity(0.4), radius: 10, x: 0, y: 5)
                        .overlay(
                            VStack {
                                Image(systemName: getLessonIcon(lesson))
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                                Text("\(lessonNumber)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        )
                        .scaleEffect(appearAnimation ? 1 : 0.7)
                        .opacity(appearAnimation ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: appearAnimation)
                }
                .padding(.top, 30)
                
                // Información de la lección
                VStack(spacing: 12) {
                    Text("\(stage.name) - Lección \(lessonNumber)")
                        .font(.title2.bold())
                        .foregroundColor(stage.color)
                        .multilineTextAlignment(.center)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 10)
                        .animation(.easeInOut(duration: 0.4).delay(0.1), value: appearAnimation)
                    
                    Text("Lección \(lessonNumber) de \(totalLessons)")
                        .foregroundColor(.secondary)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 10)
                        .animation(.easeInOut(duration: 0.4).delay(0.2), value: appearAnimation)
                    
                    // Descripción con bordes redondeados
                    Text(lesson.description)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                        )
                        .padding(.horizontal)
                        .padding(.top, 5)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 10)
                        .animation(.easeInOut(duration: 0.4).delay(0.3), value: appearAnimation)
                    
                    // Iconos informativos
                    HStack(spacing: 20) {
                        LessonInfoItem(icon: "clock", text: "\(lesson.timeLimit / 60) min", color: .blue)
                        
                        if !lesson.questions.isEmpty {
                            LessonInfoItem(icon: "list.bullet", text: "\(lesson.questions.count) preguntas", color: .orange)
                        }
                        
                        LessonInfoItem(icon: "star", text: "+\(xpManager.lessonXP) XP", color: .purple)
                    }
                    .padding(.vertical, 10)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.easeInOut(duration: 0.4).delay(0.4), value: appearAnimation)
                }
                
                // Botón de inicio
                Button(action: onStart) {
                    HStack {
                        Image(systemName: "play.fill")
                            .font(.headline)
                        Text("EMPEZAR MI LECCIÓN")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [stage.color.opacity(0.8), stage.color]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(15)
                    .shadow(color: stage.color.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                .padding(.top, 5)
                .opacity(appearAnimation ? 1 : 0)
                .scaleEffect(appearAnimation ? 1 : 0.9)
                .animation(.easeInOut(duration: 0.4).delay(0.5), value: appearAnimation)
                
                // Botón cancelar
                Button(action: onClose) {
                    Text("Cancelar")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 15)
                .opacity(appearAnimation ? 1 : 0)
                .animation(.easeInOut(duration: 0.4).delay(0.6), value: appearAnimation)
            }
            .frame(width: UIScreen.main.bounds.width - 60)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                appearAnimation = true
            }
        }
    }
    
    private func getLessonIcon(_ lesson: LessonFromModelsFile) -> String {
        switch lesson.type {
        case .reading:
            return "book.fill"
        case .eyeTraining:
            return "eye.fill"
        case .speedReading:
            return "gauge.high"
        case .peripheralVision:
            return "eye.circle.fill"
        }
    }
}

// Item informativo para el popup
struct LessonInfoItem: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 14))
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
        )
    }
}
