import SwiftUI

struct LessonView: View {
    let lesson: Lesson
    let stage: Stage
    @ObservedObject var stageManager: StageManager
    @ObservedObject var xpManager: XPManager
    let stageIndex: Int
    
    // Callback para notificar a StageLessonsView que se cierre esta fullScreenCover
    var onCloseLesson: (() -> Void)?
    
    // Estados para lecturas y conteo
    @State private var readingInProgress = false
    @State private var readingStartTime: Date? = nil
    @State private var readingSpeed: Double = 0.0
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    
    // Conteo regresivo
    @State private var countdownActive = false
    @State private var countdownValue = 3
    @State private var countdownScale: CGFloat = 1.0
    
    // Estados para eyeTraining
    @State private var showingEyeExercise = false
    @State private var finishedAllEyeExercises = false
    
    // Muestra un quiz al final
    @State private var showingQuiz = false
    
    // Alerta de salir
    @State private var showingExitAlert = false
    
    // Animaciones
    @State private var showControls = true
    @State private var contentOpacity: Double = 1.0
    
    // Para cerrar esta vista si el usuario decide "Salir"
    @Environment(\.presentationMode) var presentationMode
    
    // NUEVO: Para guardar el índice de la lección en la etapa
    @State private var lessonIndex: Int = -1
    
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
                // ENCABEZADO con botón "Atrás" y título
                customHeader
                
                // Contenido principal según tipo de lección
                if lesson.type == .reading || lesson.type == .speedReading {
                    readingContent
                } else if lesson.type == .eyeTraining {
                    eyeTrainingContent
                }
            }
            
            // Conteo "3,2,1" con animación mejorada
            if countdownActive {
                countdownOverlay
            }
        }
        // Al terminar la lección, mostrar quiz a pantalla completa
        .fullScreenCover(isPresented: $showingQuiz) {
            QuizView(
                questions: lesson.questions,
                lesson: lesson,
                stage: stage,
                stageManager: stageManager,
                xpManager: xpManager,
                stageIndex: stageIndex,
                readingSpeed: readingSpeed
            ) {
                // Al terminar quiz - Ahora invocamos la función para completar la lección
                completeLessonIfCorrect()
                presentationMode.wrappedValue.dismiss()
                onCloseLesson?()
            }
        }
        // Al entrenar ojos
        .fullScreenCover(isPresented: $showingEyeExercise) {
            if let ex = lesson.eyeExercises?.first {
                EyeExerciseView(exercise: ex)
                    .onDisappear {
                        finishedAllEyeExercises = true
                    }
            } else {
                Text("No hay ejercicios en esta lección.")
            }
        }
        // Alerta "¿Salir?"
        .alert(isPresented: $showingExitAlert) {
            Alert(
                title: Text("¿Seguro que quieres salir?"),
                message: Text("Si sales, perderás tu progreso actual."),
                primaryButton: .destructive(Text("Salir")) {
                    presentationMode.wrappedValue.dismiss()
                    onCloseLesson?()
                },
                secondaryButton: .cancel(Text("Continuar"))
            )
        }
        .onDisappear {
            timer?.invalidate()
        }
        .onAppear {
            // Imprime información sobre la lección cuando se carga la vista
            print("📱 Abriendo lección: \(lesson.title)")
            print("📊 Datos de la lección - ID: \(lesson.id), Etapa: \(stageIndex)")
            
            // NUEVO: Busca el índice de la lección en la etapa por su título o número
            findLessonIndex()
            
            // NUEVO: Imprimir todas las lecciones para diagnóstico
            stageManager.printAllLessonIDs()
        }
    }
    
    // MARK: - UI Components
    
    private var customHeader: some View {
        HStack {
            Button {
                showingExitAlert = true
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                    Text("Atrás")
                        .font(.headline)
                }
                .foregroundColor(stage.color)
                .padding(8)
                .background(
                    Capsule()
                        .fill(stage.color.opacity(0.15))
                )
            }
            
            Spacer()
            
            Text("\(stage.name) - Lección \(getLessonNumber())")
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Espaciador para equilibrar el diseño
            Circle()
                .fill(Color.clear)
                .frame(width: 35)
        }
        .padding(.top, 50)
        .padding(.horizontal)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    
    private var readingContent: some View {
        VStack(spacing: 15) {
            // Cabecera del contenido con título e instrucciones
            VStack(spacing: 8) {
                Text("Lectura Rápida")
                    .font(.title2.bold())
                    .foregroundColor(stage.color)
                    .padding(.top, 5)
                
                if !readingInProgress {
                    Text("Lee el texto lo más rápido que puedas manteniendo la comprensión")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 5)
                }
            }
            .padding(.vertical)
            .opacity(showControls ? 1 : 0.3)
            
            // Separador con gradiente
            if readingInProgress {
                LinearGradient(
                    gradient: Gradient(colors: [stage.color.opacity(0), stage.color, stage.color.opacity(0)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 1)
                .padding(.horizontal, 30)
            }
            
            // Área de lectura
            ZStack {
                if readingInProgress {
                    // Contenedor del texto con efecto de profundidad
                    ScrollView {
                        Text(lesson.content)
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
                } else {
                    // Vista previa antes de iniciar lectura
                    VStack(spacing: 20) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 60))
                            .foregroundColor(stage.color.opacity(0.7))
                        
                        Text("El texto se mostrará cuando inicies la lectura")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 30))
                            .foregroundColor(stage.color)
                            .opacity(0.7)
                    }
                    .frame(maxHeight: .infinity)
                    .padding()
                }
            }
            .frame(maxHeight: .infinity)
            
            // Botones de control
            VStack(spacing: 15) {
                if !readingInProgress && !countdownActive {
                    // Botón de iniciar
                    Button {
                        withAnimation {
                            startCountdown()
                        }
                    } label: {
                        Text("Iniciar Lectura")
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
                } else if readingInProgress {
                    // Botón de terminar
                    Button {
                        withAnimation {
                            finishReading()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.headline)
                            
                            Text("Finalizar Lectura")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.red.opacity(0.8), Color.red]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(15)
                        .shadow(color: Color.red.opacity(0.4), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal, 30)
                    
                    // Opción para ocultar/mostrar controles
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showControls.toggle()
                            contentOpacity = showControls ? 1.0 : 0.95
                        }
                    } label: {
                        Text(showControls ? "Modo inmersivo" : "Mostrar controles")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 5)
                }
            }
            .padding(.bottom, 30)
        }
    }
    private var eyeTrainingContent: some View {
        VStack(spacing: 15) {
            Text("Entrenamiento Ocular")
                .font(.title2.bold())
                .foregroundColor(stage.color)
                .padding(.vertical, 8)
            
            // Imagen ilustrativa
            Image(systemName: "eye.fill")
                .font(.system(size: 80))
                .foregroundColor(stage.color.opacity(0.8))
                .padding(.vertical, 20)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Descripción del ejercicio:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(lesson.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)
                    
                    Text("Beneficios:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    BenefitRow(text: "Mejora la capacidad de seguimiento visual", icon: "eye.circle.fill")
                    BenefitRow(text: "Reduce la fatiga ocular", icon: "bolt.shield.fill")
                    BenefitRow(text: "Incrementa la velocidad de lectura", icon: "speedometer")
                    BenefitRow(text: "Mejora la concentración", icon: "brain.head.profile")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                )
                .padding()
            }
            
            Spacer()
            
            if !finishedAllEyeExercises {
                Button {
                    showingEyeExercise = true
                } label: {
                    Text("Iniciar Entrenamiento Ocular")
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
            } else {
                // Si la lección ocular también tiene questions
                if hasQuestions {
                    Button {
                        showingQuiz = true
                    } label: {
                        Text("Responder Quiz")
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
                } else {
                    Button {
                        completeLessonIfCorrect()
                    } label: {
                        Text("Finalizar")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: Color.green.opacity(0.4), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                }
            }
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
    
    struct BenefitRow: View {
        let text: String
        let icon: String
        
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.system(size: 22))
                
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.vertical, 5)
        }
    }
    
    // MARK: - Helper Functions
    
    private var hasQuestions: Bool {
        !lesson.questions.isEmpty
    }
    
    private func getLessonNumber() -> Int {
        if let index = stage.lessons.firstIndex(where: { $0.id == lesson.id }) {
            return index + 1
        }
        
        // Si no encuentra por ID, intenta por título (más confiable)
        if let index = stage.lessons.firstIndex(where: { $0.title == lesson.title }) {
            return index + 1
        }
        
        // Si todo falla, busca el número de lección en el título
        let lessonTitle = lesson.title
        if let range = lessonTitle.range(of: "Lección (\\d+)", options: .regularExpression) {
            let numberString = lessonTitle[range].replacingOccurrences(of: "Lección ", with: "")
            if let number = Int(numberString) {
                return number
            }
        }
        
        return 1
    }
    
    // NUEVO: Método para encontrar el índice de la lección en StageManager
    private func findLessonIndex() {
        print("🔍 Buscando índice para la lección: \(lesson.title)")
        
        // 1. Primero intentar por ID exacto
        if let index = stageManager.stages[stageIndex].lessons.firstIndex(where: { $0.id == lesson.id }) {
            lessonIndex = index
            print("✅ Lección encontrada por ID. Índice: \(index)")
            return
        }
        
        // 2. Intentar por título
        if let index = stageManager.stages[stageIndex].lessons.firstIndex(where: { $0.title == lesson.title }) {
            lessonIndex = index
            print("✅ Lección encontrada por título. Índice: \(index)")
            return
        }
        
        // 3. Buscar el número de la lección en el título
        let lessonNumber = getLessonNumber()
        if lessonNumber > 0 && lessonNumber <= stageManager.stages[stageIndex].lessons.count {
            lessonIndex = lessonNumber - 1
            print("✅ Lección encontrada por número. Índice: \(lessonIndex)")
            return
        }
        
        print("⚠️ No se pudo encontrar el índice de la lección. Se usará estrategia alternativa.")
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
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
        
        guard let start = readingStartTime else {
            readingSpeed = 0
            showingQuiz = true
            return
        }
        
        let end = Date()
        let duration = end.timeIntervalSince(start) // en segundos
        let minutes = duration / 60.0
        
        let wordCount = lesson.content
            .split(separator: " ", omittingEmptySubsequences: true)
            .count
        
        if minutes > 0 {
            readingSpeed = Double(wordCount) / minutes
        } else {
            readingSpeed = 0
        }
        
        print("📚 Lectura finalizada - Velocidad: \(Int(readingSpeed)) palabras/minuto")
        
        // Mostrar cuestionario después de una pequeña pausa
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showingQuiz = true
        }
    }
    
    // MÉTODO CRÍTICO: Completa la lección usando diferentes estrategias
    private func completeLessonIfCorrect() {
        print("🔄 Intentando completar lección: \(lesson.title)")
        
        // Estrategia 1: Intentar completar por ID directo
        print("📊 Verificando parámetros - stageIndex: \(stageIndex), lessonId: \(lesson.id)")
        
        // Añadir XP siempre (independientemente de la estrategia usada)
        let xpToAdd = xpManager.lessonXP
        print("💎 Añadiendo \(xpToAdd) XP")
        xpManager.addXP(xpToAdd)
        
        // Primero intentamos completar utilizando el ID directo
        print("✅ Estrategia 1: Intentando completar por ID")
        stageManager.completeLesson(stageIndex: stageIndex, lessonId: lesson.id)
        
        // Verificamos si la estrategia 1 funcionó buscando si la lección está marcada como completada
        if let lessonInManager = stageManager.stages[stageIndex].lessons.first(where: { $0.id == lesson.id }) {
            if lessonInManager.isCompleted {
                print("✅ Lección completada exitosamente por ID")
                cerrarVista()
                return
            }
        }
        
        // Estrategia 2: Intentar completar usando el índice encontrado
        if lessonIndex >= 0 && lessonIndex < stageManager.stages[stageIndex].lessons.count {
            print("✅ Estrategia 2: Completando por índice: \(lessonIndex)")
            
            // Usamos el método interno del StageManager que acepta índice directo
            if let lessonToComplete = stageManager.stages[stageIndex].lessons[safe: lessonIndex] {
                print("🔄 Completando lección: \(lessonToComplete.title), ID: \(lessonToComplete.id)")
                stageManager.completeLesson(stageIndex: stageIndex, lessonId: lessonToComplete.id)
                
                // Verificar si ahora está marcada como completada
                if stageManager.stages[stageIndex].lessons[lessonIndex].isCompleted {
                    print("✅ Lección completada exitosamente por índice")
                    cerrarVista()
                    return
                }
            }
        }
        
        // Estrategia 3: Encontrar la primera lección no completada y marcarla
        print("✅ Estrategia 3: Buscando primera lección incompleta")
        if let firstIncompleteLessonIndex = stageManager.stages[stageIndex].lessons.firstIndex(where: { !$0.isCompleted }) {
            let lessonToComplete = stageManager.stages[stageIndex].lessons[firstIncompleteLessonIndex]
            print("🔄 Completando primera lección pendiente: \(lessonToComplete.title)")
            stageManager.completeLesson(stageIndex: stageIndex, lessonId: lessonToComplete.id)
            print("✅ Primera lección pendiente completada")
        }
        
        print("🎉 Lección completada y XP añadidos")
        cerrarVista()
    }
    
    // Función auxiliar para cerrar la vista actual
    private func cerrarVista() {
        presentationMode.wrappedValue.dismiss()
        onCloseLesson?()
    }
    
    // Función existente mantenida por compatibilidad
    private func completeLessonAndDismiss() {
        completeLessonIfCorrect()
    }
}

// EXTENSIÓN PARA ACCESO SEGURO A ARRAYS
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
