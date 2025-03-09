//
//  StageLessonsView.swift
//  worldbrainapp
//
//  Vista mejorada con animaciones y diseño moderno
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
    
    // Para animaciones
    @State private var appearElements = false
    
    var body: some View {
        ZStack {
            // Fondo con gradiente
            LinearGradient(
                gradient: Gradient(colors: [stage.color.opacity(0.15), Color.white]),
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Encabezado de la etapa
                    stageHeader
                    
                    // Camino de lecciones
                    lessonPath
                }
                .padding(.bottom, 50)
            }
        }
        // Overlay para el popup de lección
        .overlay(lessonPopupOverlay)
        // FullScreenCover para mostrar la lección
        .fullScreenCover(isPresented: $showingLesson) {
            if let lesson = selectedLesson {
                LessonView(
                    lesson: lesson,
                    stage: stage,
                    stageManager: stageManager,
                    xpManager: xpManager,
                    stageIndex: stageIndex
                ) {
                    showingLesson = false
                }
            }
        }
        .onAppear {
            // Activar animaciones al aparecer la vista
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    appearElements = true
                }
            }
        }
    }
    
    // MARK: - Vista del encabezado
    
    private var stageHeader: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Información y progreso
            HStack {
                // Título y descripción
                VStack(alignment: .leading, spacing: 5) {
                    Text(stage.name)
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(stage.color)
                        .opacity(appearElements ? 1 : 0)
                        .offset(y: appearElements ? 0 : -10)
                        .animation(.easeOut(duration: 0.5), value: appearElements)
                    
                    Text(stage.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .opacity(appearElements ? 1 : 0)
                        .offset(y: appearElements ? 0 : -5)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: appearElements)
                }
                
                Spacer()
                
                // Progreso circular
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                        .frame(width: 70, height: 70)
                    
                    // Arco de progreso
                    CircleProgressView(
                        progress: CGFloat(stage.completedLessonsCount) / CGFloat(stage.requiredLessons),
                        color: stage.color,
                        animated: appearElements
                    )
                    .frame(width: 70, height: 70)
                    
                    // Texto de progreso
                    Text("\(stage.completedLessonsCount)/\(stage.requiredLessons)")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(stage.color)
                }
                .opacity(appearElements ? 1 : 0)
                .scaleEffect(appearElements ? 1 : 0.7)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: appearElements)
            }
            
            // Barra de progreso
            stageProgressBar
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 15)
    }
    
    // Barra de progreso horizontal
    private var stageProgressBar: some View {
        VStack(spacing: 5) {
            // Barra base
            ZStack(alignment: .leading) {
                // Fondo de la barra
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                
                // Progreso
                let progressWidth = calculateProgressBarWidth()
                
                RoundedRectangle(cornerRadius: 5)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [stage.color.opacity(0.7), stage.color]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: progressWidth, height: 8)
                    .animation(.easeOut(duration: 1.0).delay(0.5), value: appearElements)
            }
            
            Text("Progreso de la etapa")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .opacity(appearElements ? 1 : 0)
        .animation(.easeOut(duration: 0.6).delay(0.4), value: appearElements)
    }
    
    // Calcula el ancho de la barra de progreso
    private func calculateProgressBarWidth() -> CGFloat {
        if !appearElements {
            return 0
        }
        
        let screenWidth = UIScreen.main.bounds.width * 0.9
        let progress = CGFloat(stage.completedLessonsCount) / CGFloat(stage.requiredLessons)
        return progress * screenWidth
    }
    
    // MARK: - Vista del camino de lecciones
    
    private var lessonPath: some View {
        VStack(spacing: 0) {
            ForEach(Array(stage.lessons.enumerated()), id: \.element.id) { index, lesson in
                VStack(spacing: 0) {
                    // Línea conectora (excepto para la primera lección)
                    if index > 0 {
                        lessonConnector(for: lesson, index: index)
                    }
                    
                    // Nodo de la lección
                    lessonNode(for: lesson, index: index)
                }
            }
        }
        .padding(.vertical, 30)
    }
    
    // Conector entre lecciones
    private func lessonConnector(for lesson: Lesson, index: Int) -> some View {
        Group {
            if lesson.isLocked {
                // Línea punteada para lecciones bloqueadas
                VStack(spacing: 6) {
                    ForEach(0..<5) { _ in
                        Circle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: 4, height: 4)
                    }
                }
                .frame(height: 40)
            } else {
                // Línea sólida para lecciones desbloqueadas
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [stage.color.opacity(0.5), stage.color]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 4, height: 40)
            }
        }
        .opacity(appearElements ? 1 : 0)
        .animation(.easeInOut(duration: 0.5).delay(0.3 + Double(index) * 0.1), value: appearElements)
    }
    
    // Nodo individual de lección
    private func lessonNode(for lesson: Lesson, index: Int) -> some View {
        Button {
            if !lesson.isLocked {
                selectedLesson = lesson
                showingLessonPopup = true
            }
        } label: {
            ZStack {
                // Efecto de resplandor para lecciones actuales
                if !lesson.isLocked && !lesson.isCompleted {
                    Circle()
                        .fill(stage.color.opacity(0.3))
                        .frame(width: 70, height: 70)
                        .blur(radius: 8)
                        .opacity(0.7)
                }
                
                // Círculo principal
                Circle()
                    .fill(lesson.isLocked ?
                          Color.gray.opacity(0.5) :
                          stage.color)
                    .frame(width: 60, height: 60)
                    .shadow(color: lesson.isLocked ? Color.clear : stage.color.opacity(0.4),
                            radius: 8, x: 0, y: 4)
                
                // Contenido del nodo
                lessonNodeContent(for: lesson, index: index)
                
                // Borde para lecciones completadas
                if lesson.isCompleted {
                    lessonCompletionDecorations()
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(lesson.isLocked)
        .padding(.vertical, 10)
        .opacity(appearElements ? 1 : 0)
        .offset(y: appearElements ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2 + Double(index) * 0.1), value: appearElements)
    }
    
    // Contenido interior del nodo de lección
    private func lessonNodeContent(for lesson: Lesson, index: Int) -> some View {
        Group {
            if lesson.isLocked {
                Image(systemName: "lock.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 22))
            } else {
                VStack(spacing: 3) {
                    Image(systemName: getLessonIcon(lesson))
                        .font(.system(size: 20))
                    Text("\(index + 1)")
                        .font(.caption2.bold())
                }
                .foregroundColor(.white)
            }
        }
    }
    
    // Decoraciones para lecciones completadas
    private func lessonCompletionDecorations() -> some View {
        ZStack {
            Circle()
                .strokeBorder(Color.yellow, lineWidth: 3)
                .frame(width: 66, height: 66)
                .shadow(color: Color.yellow.opacity(0.3), radius: 5, x: 0, y: 0)
            
            // Estrellas
            HStack(spacing: 4) {
                ForEach(0..<3) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 12))
                        .shadow(color: Color.orange.opacity(0.5), radius: 2, x: 0, y: 1)
                }
            }
            .offset(y: 38)
        }
    }
    
    // MARK: - Popup de lección
    
    private var lessonPopupOverlay: some View {
        ZStack {
            if showingLessonPopup, let lesson = selectedLesson {
                // Fondo oscuro
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showingLessonPopup = false
                    }
                
                // Popup
                lessonPopupContent(lesson)
            }
        }
    }
    
    private func lessonPopupContent(_ lesson: Lesson) -> some View {
        VStack(spacing: 20) {
            // Ícono de la lección
            lessonPopupIcon(lesson)
            
            // Información de la lección
            Text("\(stage.name) - Lección \(lessonTitleIndex(lesson))")
                .font(.title2.bold())
                .foregroundColor(stage.color)
                .multilineTextAlignment(.center)
            
            Text("Lección \(lessonTitleIndex(lesson)) de \(stage.lessons.count)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Descripción
            Text(lesson.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                )
                .padding(.horizontal, 10)
            
            // Información adicional
            lessonPopupInfo(lesson)
            
            // Botones
            lessonPopupButtons(lesson)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 20)
    }
    
    private func lessonPopupIcon(_ lesson: Lesson) -> some View {
        ZStack {
            // Círculo principal
            Circle()
                .fill(stage.color)
                .frame(width: 110, height: 110)
                .shadow(color: stage.color.opacity(0.5), radius: 10, x: 0, y: 5)
                .overlay(
                    VStack {
                        Image(systemName: getLessonIcon(lesson))
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                        
                        Text("\(lessonTitleIndex(lesson))")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                )
        }
        .padding(.top, 20)
    }
    
    private func lessonPopupInfo(_ lesson: Lesson) -> some View {
        HStack(spacing: 15) {
            // Duración
            InfoBadge(icon: "clock.fill", text: "\(lesson.timeLimit / 60) min", color: .blue)
            
            // Preguntas (si hay)
            if !lesson.questions.isEmpty {
                InfoBadge(icon: "questionmark.circle", text: "\(lesson.questions.count) preguntas", color: .orange)
            }
            
            // XP a ganar
            InfoBadge(icon: "star.fill", text: "+\(xpManager.lessonXP) XP", color: .purple)
        }
        .padding(.vertical, 5)
    }
    
    private func lessonPopupButtons(_ lesson: Lesson) -> some View {
        VStack(spacing: 15) {
            // Botón para iniciar la lección
            Button(action: {
                showingLessonPopup = false
                showingLesson = true
            }) {
                HStack {
                    Image(systemName: "play.fill")
                        .font(.headline)
                    Text("EMPEZAR MI LECCIÓN")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(stage.color)
                .cornerRadius(15)
                .shadow(color: stage.color.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            
            // Botón para cancelar
            Button(action: {
                showingLessonPopup = false
            }) {
                Text("Cancelar")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 10)
        }
    }
    
    // MARK: - Helpers
    
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
    
    private func lessonTitleIndex(_ lesson: Lesson) -> Int {
        if let idx = stage.lessons.firstIndex(where: { $0.id == lesson.id }) {
            return idx + 1
        }
        return 0
    }
}

// MARK: - Componentes auxiliares

// Vista de progreso circular animada
struct CircleProgressView: View {
    let progress: CGFloat
    let color: Color
    let animated: Bool
    
    var body: some View {
        Circle()
            .trim(from: 0.0, to: animated ? progress : 0.0)
            .stroke(
                color,
                style: StrokeStyle(lineWidth: 8, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
            .animation(.easeInOut(duration: 1.2), value: animated)
    }
}

// Insignia informativa
struct InfoBadge: View {
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

// Estilo de botón con animación
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
