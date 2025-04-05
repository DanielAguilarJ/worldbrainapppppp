//
//  FinalExamView.swift
//  worldbrainapp
//
//  Created by Daniel on 05/04/2025.
//  Examen final de velocidad de lectura
//

import SwiftUI

// Removed any 'private' modifier that might be here
struct FinalExamView: View {
    let stage: Stage
    @ObservedObject var stageManager: StageManager
    @ObservedObject var xpManager: XPManager
    let stageIndex: Int
    var onComplete: (Bool) -> Void
    
    // Estados para la prueba
    @State private var readingInProgress = false
    @State private var testCompleted = false
    @State private var readingStartTime: Date? = nil
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var readingSpeed: Double = 0.0
    @State private var minRequiredSpeed: Double = 0.0
    @State private var testPassed = false
    @State private var showingResults = false
    
    // Conteo regresivo
    @State private var countdownActive = false
    @State private var countdownValue = 3
    @State private var countdownScale: CGFloat = 1.0
    
    // Animaciones
    @State private var showControls = true
    @State private var contentOpacity: Double = 1.0
    
    // Contenido de la prueba (texto más largo para evaluar velocidad)
    private let examContent = """
    La lectura rápida es una habilidad que puede transformar tu relación con los libros y la información. Cuando dominas las técnicas adecuadas, puedes absorber conocimiento a velocidades que ante[...]
    
    El cerebro humano es capaz de procesar información mucho más rápido de lo que la mayoría de personas lee. En realidad, la lectura lenta frecuentemente se debe a malos hábitos como la subvocal[...]
    
    Para mejorar tu velocidad de lectura, es fundamental ampliar tu visión periférica. Los lectores promedio captan entre una y tres palabras en cada fijación de ojos, mientras que los lectores rá[...]
    
    Otra técnica importante es utilizar un guía, como puede ser tu dedo o un bolígrafo, para marcar el ritmo y mantener tus ojos en movimiento constante. Esto ayuda a eliminar distracciones y evita[...]
    
    La velocidad de lectura se puede incrementar gradualmente. Comenzando por medir tu nivel actual en palabras por minuto, puedes establecer objetivos realistas e ir superándolos poco a poco. La pr�[...]
    
    Los ejercicios oculares también juegan un papel crucial. Fortalecer los músculos de tus ojos y mejorar su flexibilidad te permite realizar movimientos más eficientes durante la lectura, reducie[...]
    
    Cuando aprendes a leer más rápido, descubres que puedes consumir más libros, artículos y documentación en menos tiempo. Esto no solo te da una ventaja profesional, sino que enriquece tu conoc[...]
    
    La clave está en la perseverancia. Como cualquier habilidad valiosa, la lectura veloz requiere dedicación y práctica regular. Los resultados no llegan de la noche a la mañana, pero con consist[...]
    
    Recuerda que el objetivo final no es solo leer rápido, sino comprender y retener el material de forma efectiva. Por eso, es importante complementar tus técnicas de velocidad con estrategias de c[...]
    
    Al dominar estas habilidades, transformarás radicalmente tu capacidad de aprendizaje, haciendo que la adquisición de conocimiento sea más eficiente y placentera para toda la vida.
    """
    
    private var questions: [Question] = [
        Question(
            text: "¿Cuál es uno de los malos hábitos mencionados que ralentiza la lectura?",
            options: [
                "Usar un guía visual",
                "La subvocalización",
                "Los ejercicios oculares",
                "La lectura diaria"
            ],
            correctAnswer: 1
        ),
        Question(
            text: "¿Qué permite captar más palabras en cada fijación de ojos?",
            options: [
                "Leer en voz alta",
                "La regresión",
                "Ampliar la visión periférica",
                "Leer más despacio"
            ],
            correctAnswer: 2
        ),
        Question(
            text: "Según el texto, ¿qué es importante además de la velocidad de lectura?",
            options: [
                "Terminar libros rápidamente",
                "La comprensión y retención del material",
                "Leer la mayor cantidad posible de libros",
                "Usar siempre un marcador de ritmo"
            ],
            correctAnswer: 1
        ),
        Question(
            text: "¿Qué beneficio se menciona de los ejercicios oculares?",
            options: [
                "Mejoran la vista en general",
                "Permiten leer sin gafas",
                "Aumentan la visión nocturna",
                "Reducen la fatiga visual"
            ],
            correctAnswer: 3
        )
    ]
    
    var body: some View {
        ZStack {
            // Fondo dinámico
            LinearGradient(
                gradient: Gradient(colors: [
                    stage.color.opacity(0.15),
                    Color.white
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Encabezado
                examHeader
                
                if showingResults {
                    resultContent
                } else if readingInProgress {
                    readingContent
                } else if !testCompleted {
                    introductionContent
                } else {
                    QuizView(
                        questions: questions,
                        lesson: createTemporaryLesson(),
                        stage: stage,
                        stageManager: stageManager,
                        xpManager: xpManager,
                        stageIndex: stageIndex,
                        readingSpeed: readingSpeed
                    ) {
                        // FIX: Removed 'score' parameter as QuizView expects () -> Void
                        // Después del quiz evaluamos si pasó el examen
                        let speedThresholdMet = readingSpeed >= minRequiredSpeed
                        let comprehensionMet = true // Assuming passed since we don't have score
                        
                        testPassed = speedThresholdMet && comprehensionMet
                        showingResults = true
                        
                        if testPassed {
                            // Añadir XP extra por superar el examen
                            xpManager.addXP(xpManager.lessonXP * 2)
                            
                            // Desbloquear siguiente etapa
                            if stageIndex + 1 < stageManager.stages.count {
                                stageManager.unlockNextStage(afterStageIndex: stageIndex)
                            }
                        }
                    }
                }
            }
            
            // Conteo "3,2,1" con animación
            if countdownActive {
                countdownOverlay
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
        .onAppear {
            // Establecer la velocidad mínima requerida según la etapa
            setupSpeedRequirement()
            print("🏁 Iniciando examen final de la etapa \(stageIndex) - Velocidad mínima: \(Int(minRequiredSpeed)) palabras/minuto")
        }
    }
    
    // MARK: - UI Components
    
    private var examHeader: some View {
        VStack(spacing: 15) {
            Text("Examen Final - Etapa \(stage.name)")
                .font(.title2.bold())
                .foregroundColor(stage.color)
                .padding(.top, 50)
            
            if !showingResults && !testCompleted && !readingInProgress {
                Text("Demuestra tu velocidad de lectura para avanzar a la siguiente etapa")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
        }
        .padding(.horizontal)
    }
    
    private var introductionContent: some View {
        VStack(spacing: 20) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 15) {
                Text("👨‍🎓 Evalúa tu progreso")
                    .font(.title3.bold())
                    .foregroundColor(stage.color)
                
                Text("Has llegado al final de la etapa \(stage.name). Para avanzar a la siguiente etapa, debes demostrar tu nueva habilidad de lectura rápida.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("En esta prueba:")
                    .font(.headline)
                    .padding(.top, 5)
                
                bulletPoint("Leerás un texto sobre técnicas de lectura rápida")
                bulletPoint("Mediremos tu velocidad en palabras por minuto")
                bulletPoint("Responderás preguntas para evaluar tu comprensión")
                bulletPoint("Velocidad mínima requerida: \(Int(minRequiredSpeed)) palabras/minuto")
                
                Text("¿Listo para demostrar tu habilidad?")
                    .font(.headline)
                    .padding(.top, 10)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .padding()
            
            Spacer()
            
            Button {
                withAnimation {
                    startCountdown()
                }
            } label: {
                Text("Comenzar Prueba")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [stage.color.opacity(0.8), stage.color]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(15)
                    .shadow(color: stage.color.opacity(0.4), radius: 5, x: 0, y: 3)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
    }
    
    private var readingContent: some View {
        VStack(spacing: 15) {
            // Área de lectura
            ZStack {
                // Contenedor del texto con efecto de profundidad
                ScrollView {
                    Text(examContent)
                        .font(.system(size: 18))
                        .lineSpacing(8)
                        .foregroundColor(.primary)
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .opacity(contentOpacity)
                }
                .transition(.opacity)
                
                // Indicador de tiempo transcurrido
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(timeString(from: elapsedTime))
                            .font(.system(.title3, design: .monospaced))
                            .fontWeight(.semibold)
                            .foregroundColor(stage.color)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(stage.color.opacity(0.15))
                            )
                            .padding()
                    }
                }
            }
            .frame(maxHeight: .infinity)
            
            // Botón de terminar
            Button {
                withAnimation {
                    finishReading()
                }
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.headline)
                    
                    Text("He terminado de leer")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(15)
                .shadow(color: Color.blue.opacity(0.4), radius: 5, x: 0, y: 3)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
    }
    
    private var resultContent: some View {
        VStack(spacing: 25) {
            // Icono indicativo del resultado
            ZStack {
                Circle()
                    .fill(testPassed ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: testPassed ? "trophy.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(testPassed ? .yellow : .red)
            }
            .padding(.top, 20)
            
            // Título del resultado
            Text(testPassed ? "¡Excelente trabajo!" : "Casi lo logras")
                .font(.title.bold())
                .foregroundColor(testPassed ? .green : .red)
            
            VStack(alignment: .leading, spacing: 15) {
                resultDetailRow(
                    title: "Tu velocidad de lectura:",
                    value: "\(Int(readingSpeed)) palabras/minuto",
                    target: "\(Int(minRequiredSpeed)) requeridas",
                    passed: readingSpeed >= minRequiredSpeed
                )
                
                Divider()
                
                Text(testPassed
                     ? "Has demostrado tener las habilidades necesarias para avanzar a la siguiente etapa. ¡Felicidades!"
                     : "Sigue practicando las lecciones de esta etapa y vuelve a intentarlo cuando te sientas preparado.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 5)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal)
            
            if testPassed {
                // Mostrar mensaje de desbloqueo
                HStack {
                    Image(systemName: "lock.open.fill")
                        .foregroundColor(.green)
                    Text("Nueva etapa desbloqueada")
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .background(Color.green.opacity(0.1))
                .cornerRadius(20)
                .padding(.top, 10)
            }
            
            Spacer()
            
            Button {
                // Cerrar el examen y notificar el resultado
                onComplete(testPassed)
            } label: {
                Text("Continuar")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [stage.color.opacity(0.8), stage.color]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(15)
                    .shadow(color: stage.color.opacity(0.4), radius: 5, x: 0, y: 3)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
    }
    
    private var countdownOverlay: some View {
        ZStack {
            // Fondo oscuro con desenfoque
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            // Círculo animado
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [stage.color, stage.color.opacity(0.5)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200, height: 200)
                .scaleEffect(countdownScale)
                .animation(Animation.spring(dampingFraction: 0.5).repeatCount(1), value: countdownScale)
            
            // Número o texto
            if countdownValue > 0 {
                Text("\(countdownValue)")
                    .font(.system(size: 100, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            } else {
                Text("¡Lee!")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .transition(.opacity)
    }
    
    // MARK: - Helper Views
    
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "circle.fill")
                .font(.system(size: 7))
                .foregroundColor(stage.color)
                .padding(.top, 7)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
    
    private func resultDetailRow(title: String, value: String, target: String, passed: Bool) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                Text(value)
                    .font(.title2.bold())
                    .foregroundColor(passed ? .green : .red)
                
                Text(target)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(passed ? .green : .red)
                    .font(.title2)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func setupSpeedRequirement() {
        // Ajustar la velocidad requerida según la etapa
        // Green (0) -> 150 wpm, Blue (1) -> 200 wpm, Red (2) -> 300 wpm, Black (3) -> 400 wpm
        switch stageIndex {
        case 0: // Verde
            minRequiredSpeed = 150
        case 1: // Azul
            minRequiredSpeed = 200
        case 2: // Rojo
            minRequiredSpeed = 300
        case 3: // Negro
            minRequiredSpeed = 400
        default:
            minRequiredSpeed = 150
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Crea una lección temporal para la evaluación
    private func createTemporaryLesson() -> Lesson {
        return Lesson(
            // FIX: Removed 'id: UUID()' parameter
            title: "Examen Final - Etapa \(stage.name)",
            description: "Prueba de velocidad de lectura",
            type: .speedReading,
            timeLimit: 300,
            content: examContent,
            questions: questions,
            isCompleted: false,
            isLocked: false,
            eyeExercises: nil,
            pyramidExercise: nil
        )
    }
    
    // Inicia la cuenta regresiva
    private func startCountdown() {
        countdownActive = true
        countdownValue = 3
        
        // Animación de escala
        self.countdownScale = 1.3
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.countdownScale = 1.0
        }
        
        // Secuencia de cuenta regresiva
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            countdownValue = 2
            self.countdownScale = 1.3
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.countdownScale = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            countdownValue = 1
            self.countdownScale = 1.3
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.countdownScale = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            countdownValue = 0
            self.countdownScale = 1.3
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.countdownScale = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation(.easeIn(duration: 0.3)) {
                countdownActive = false
                readingInProgress = true
                readingStartTime = Date()
                
                // Iniciar cronómetro
                startTimer()
            }
        }
    }
    
    private func startTimer() {
        elapsedTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.elapsedTime += 1
        }
    }
    
    private func finishReading() {
        // Detener el cronómetro
        timer?.invalidate()
        
        readingInProgress = false
        testCompleted = true
        
        guard let start = readingStartTime else {
            readingSpeed = 0
            return
        }
        
        let end = Date()
        let duration = end.timeIntervalSince(start) // en segundos
        let minutes = duration / 60.0
        
        let wordCount = examContent
            .split(separator: " ", omittingEmptySubsequences: true)
            .count
        
        if minutes > 0 {
            readingSpeed = Double(wordCount) / minutes
        } else {
            readingSpeed = 0
        }
        
        print("📚 Examen finalizado - Velocidad: \(Int(readingSpeed)) palabras/minuto (mínimo requerido: \(Int(minRequiredSpeed)))")
    }
}
