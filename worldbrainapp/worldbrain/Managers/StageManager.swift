//  StageManager.swift
//  worldbrain
//
//  Ejemplo con lecturas variadas y preguntas reales para la Etapa Verde (Principiante).
//

import SwiftUI

class StageManager: ObservableObject {
    @Published var stages: [Stage] = []
    @Published var selectedStage: Stage?
    
    // Claves para persistencia
    private let userDefaults = UserDefaults.standard
    private let completedLessonsKey = "completedLessons"
    private let unlockedLessonsKey = "unlockedLessons"
    private let unlockedStagesKey = "unlockedStages"
    
    init() {
        loadStages()
        loadSavedProgress()
        unlockFirstStage()
        
        // Debug: Imprimir IDs de todas las lecciones para diagnosticar el problema
        printAllLessonIDs()
    }
    
    private func loadStages() {
        // ETAPA VERDE (PRINCIPIANTE) - solo 10 lecciones de ejemplo
        let greenStage = Stage(
            name: "Etapa Verde",
            color: .green,
            description: "Fundamentos de la fotolectura",
            requiredLessons: 10, // en este ejemplo, pedimos 10 para completarla
            lessons: generateGreenStageLessons(),
            isLocked: true
        )
        
        // Etapas vacías solo para que exista la estructura
        let blueStage = Stage(
            name: "Etapa Azul",
            color: .blue,
            description: "Técnicas intermedias",
            requiredLessons: 30,
            lessons: [],
            isLocked: true
        )
        
        let redStage = Stage(
            name: "Etapa Roja",
            color: .red,
            description: "Técnicas avanzadas",
            requiredLessons: 30,
            lessons: [],
            isLocked: true
        )
        
        let blackStage = Stage(
            name: "Etapa Negra",
            color: .black,
            description: "Dominio de la fotolectura",
            requiredLessons: 30,
            lessons: [],
            isLocked: true
        )
        
        stages = [greenStage, blueStage, redStage, blackStage]
    }
    
    // NUEVO: Cargar progreso guardado
    private func loadSavedProgress() {
        let completedLessons = userDefaults.array(forKey: completedLessonsKey) as? [String] ?? []
        let unlockedLessons = userDefaults.array(forKey: unlockedLessonsKey) as? [String] ?? []
        let unlockedStages = userDefaults.array(forKey: unlockedStagesKey) as? [Int] ?? []
        
        print("Cargando progreso: \(completedLessons.count) lecciones completadas y \(unlockedLessons.count) desbloqueadas")
        
        // Aplicar estados guardados a las etapas
        for stageIndex in 0..<stages.count {
            if unlockedStages.contains(stageIndex) {
                stages[stageIndex].isLocked = false
            }
            
            // Restaurar estado de lecciones
            for lessonIndex in 0..<stages[stageIndex].lessons.count {
                let lessonId = stages[stageIndex].lessons[lessonIndex].id.uuidString
                
                // Marcar lecciones completadas
                if completedLessons.contains(lessonId) {
                    stages[stageIndex].lessons[lessonIndex].isCompleted = true
                }
                
                // Desbloquear lecciones guardadas
                if unlockedLessons.contains(lessonId) {
                    stages[stageIndex].lessons[lessonIndex].isLocked = false
                }
            }
        }
    }
    
    // NUEVO: Guardar progreso
    private func saveProgress() {
        var completedLessons: [String] = []
        var unlockedLessons: [String] = []
        var unlockedStages: [Int] = []
        
        for stageIndex in 0..<stages.count {
            if !stages[stageIndex].isLocked {
                unlockedStages.append(stageIndex)
            }
            
            for lesson in stages[stageIndex].lessons {
                if lesson.isCompleted {
                    completedLessons.append(lesson.id.uuidString)
                }
                
                if !lesson.isLocked {
                    unlockedLessons.append(lesson.id.uuidString)
                }
            }
        }
        
        userDefaults.set(completedLessons, forKey: completedLessonsKey)
        userDefaults.set(unlockedLessons, forKey: unlockedLessonsKey)
        userDefaults.set(unlockedStages, forKey: unlockedStagesKey)
        userDefaults.synchronize()
        
        print("Progreso guardado: \(completedLessons.count) lecciones completadas")
        print("Lecciones desbloqueadas: \(unlockedLessons.count)")
    }
    
    /// Genera las 11 lecciones de la Etapa Verde con lecturas de distintos temas, entrenamientos oculares y visión periférica
    private func generateGreenStageLessons() -> [LessonFromModelsFile] {
        var lessons: [LessonFromModelsFile] = []
        
            // Lección 1 (Lectura: Historia)
            lessons.append(
                LessonFromModelsFile(
                    title: "Principiante - Lección 1",
                    description: "Breve introducción a la historia de la escritura",
                    type: .reading,
                    timeLimit: 180,
                    content: """
                    Desde los antiguos sumerios hasta las civilizaciones modernas, la escritura ha sido una herramienta esencial para transmitir conocimiento. Los sumerios desarrollaron una de las primera[...]
                    """,
                    questions: [
                        Question(
                            text: "¿Cuál fue una de las primeras formas de escritura?",
                            options: [
                                "Jeroglíficos egipcios",
                                "Alfabeto romano",
                                "Cuneiforme sumerio",
                                "Kanji japonés"
                            ],
                            correctAnswer: 2
                        ),
                        Question(
                            text: "¿En qué material solían escribir los sumerios?",
                            options: [
                                "Piedra tallada",
                                "Tabla de madera",
                                "Pergamino de seda",
                                "Tablillas de arcilla"
                            ],
                            correctAnswer: 3
                        )
                    ],
                    eyeExercises: nil,
                    pyramidExercise: nil
                )
            )
            
            // Lección 2 (Lectura: Ciencia)
            lessons.append(
                LessonFromModelsFile(
                    title: "Principiante - Lección 2",
                    description: "La maravilla de las células en el cuerpo humano",
                    type: .reading,
                    timeLimit: 180,
                    content: """
                    El cuerpo humano está compuesto por trillones de células que trabajan de forma coordinada. Cada célula contiene información genética almacenada en el ADN, el cual dirige el crecim[...]
                    """,
                    questions: [
                        Question(
                            text: "¿Qué contiene la información genética en las células?",
                            options: [
                                "Proteínas especiales",
                                "ARN mensajero",
                                "ADN",
                                "Azúcares"
                            ],
                            correctAnswer: 2
                        ),
                        Question(
                            text: "¿Cuántas células se estima que tiene el cuerpo humano?",
                            options: [
                                "Miles",
                                "Millones",
                                "Billones",
                                "Trillones"
                            ],
                            correctAnswer: 3
                        )
                    ],
                    eyeExercises: nil,
                    pyramidExercise: nil
                )
            )
            
            // Lección 3 (Lectura: Cultura)
            lessons.append(
                LessonFromModelsFile(
                    title: "Principiante - Lección 3",
                    description: "El arte del café en distintas culturas",
                    type: .reading,
                    timeLimit: 180,
                    content: """
                    El café es una de las bebidas más consumidas en el mundo. Desde el espresso italiano hasta el café de olla en México, cada cultura ha desarrollado su forma única de prepararlo. El[...]
                    """,
                    questions: [
                        Question(
                            text: "¿Qué país se destaca por el espresso?",
                            options: [
                                "Francia",
                                "Italia",
                                "Suecia",
                                "Perú"
                            ],
                            correctAnswer: 1
                        ),
                        Question(
                            text: "¿Con qué se hierve comúnmente el café de olla en México?",
                            options: [
                                "Canela y piloncillo",
                                "Mantequilla y especias",
                                "Miel y pimienta",
                                "Azúcar mascabado y jengibre"
                            ],
                            correctAnswer: 0
                        )
                    ],
                    eyeExercises: nil,
                    pyramidExercise: nil
                )
            )
            
            // Lección 4 (Lectura: Desarrollo personal)
            lessons.append(
                LessonFromModelsFile(
                    title: "Principiante - Lección 4",
                    description: "La importancia de la respiración consciente",
                    type: .reading,
                    timeLimit: 180,
                    content: """
                    Practicar la respiración consciente puede mejorar la concentración y disminuir el estrés. Al inhalar profundamente y exhalar lentamente, el ritmo cardiaco se regula y la mente se vu[...]
                    """,
                    questions: [
                        Question(
                            text: "¿Qué beneficio principal se asocia con la respiración consciente?",
                            options: [
                                "Aumentar el apetito",
                                "Disminuir la concentración",
                                "Mejorar la flexibilidad",
                                "Regular el ritmo cardiaco y reducir estrés"
                            ],
                            correctAnswer: 3
                        )
                    ],
                    eyeExercises: nil,
                    pyramidExercise: nil
                )
            )
            
            // Lección 5 (Entrenamiento Ocular)
            lessons.append(
                LessonFromModelsFile(
                    title: "Principiante - Entrenamiento Ocular 5",
                    description: "Ejercicios para mejorar la movilidad y resistencia ocular",
                    type: .eyeTraining,
                    timeLimit: 180,
                    content: "",
                    questions: [],
                    eyeExercises: [
                        EyeExercise(
                            type: .horizontalMovement,
                            duration: 60,
                            instructions: "Sigue el punto rojo de izquierda a derecha sin mover la cabeza"
                        ),
                        EyeExercise(
                            type: .verticalMovement,
                            duration: 60,
                            instructions: "Sigue el punto rojo de arriba a abajo sin mover la cabeza"
                        ),
                        EyeExercise(
                            type: .circularMovement,
                            duration: 60,
                            instructions: "Sigue el punto rojo en movimiento circular"
                        )
                    ],
                    pyramidExercise: nil
                )
            )
            
            // Lección 6 (Visión periférica - NUEVA LECCIÓN)
            lessons.append(
                LessonFromModelsFile(
                    title: "Principiante - Visión Periférica 6",
                    description: "Entrenamiento de visión periférica con textos en pirámide",
                    type: .peripheralVision,
                    timeLimit: 240,
                    content: "",
                    questions: [
                        Question(
                            text: "¿Cuál es uno de los principales beneficios de entrenar la visión periférica?",
                            options: [
                                "Mejorar la visión central únicamente",
                                "Aumentar la velocidad de lectura",
                                "Reducir la capacidad de concentración",
                                "Eliminar la necesidad de anteojos"
                            ],
                            correctAnswer: 1
                        ),
                        Question(
                            text: "Durante el ejercicio de texto en pirámide, ¿en qué parte debe enfocarse la mirada?",
                            options: [
                                "En todo el texto completo",
                                "En la palabra resaltada en verde",
                                "En la primera línea solamente",
                                "En la última línea solamente"
                            ],
                            correctAnswer: 1
                        )
                    ],
                    eyeExercises: nil,
                    pyramidExercise: PyramidTextExercise(
                        title: "Naturaleza y Bienestar",
                        description: "Ejercicio para expandir tu visión periférica con texto sobre la naturaleza",
                        introText: "Mantén la mirada en la palabra resaltada y trata de percibir todo el párrafo sin mover tus ojos.",
                        paragraphs: [
                            PyramidTextExercise.PyramidParagraph(
                                text: "Los       bosques       son\npulmones    naturales    que\npurifican   el   aire   que\nrespiramos  cada  día\ny nos dan vida.",
                                focusPoint: "aire"
                            ),
                            PyramidTextExercise.PyramidParagraph(
                                text: "El     contacto     con\nla   naturaleza   reduce\nel    estrés    mental\ny   nos   conecta\ncon la tierra.",
                                focusPoint: "estrés"
                            ),
                            PyramidTextExercise.PyramidParagraph(
                                text: "Caminar       entre       árboles\nmejora      nuestro      estado\nde     ánimo     y     nos\nayuda a encontrar paz\ny tranquilidad.",
                                focusPoint: "encontrar"
                            )
                        ],
                        difficulty: 1
                    )
                )
            )
            
            // Lección 7 (Lectura: Historia de la ciencia)
            lessons.append(
                LessonFromModelsFile(
                    title: "Principiante - Lección 7",
                    description: "Galileo y el telescopio",
                    type: .reading,
                    timeLimit: 180,
                    content: """
                    Galileo Galilei fue uno de los primeros en utilizar el telescopio para observar el cielo. Sus descubrimientos, como las lunas de Júpiter y las fases de Venus, desafiaron la visión ge[...]
                    """,
                    questions: [
                        Question(
                            text: "¿Qué instrumento popularizó Galileo para estudiar el cielo?",
                            options: [
                                "El microscopio",
                                "El telescopio",
                                "El astrolabio",
                                "La brújula"
                            ],
                            correctAnswer: 1
                        ),
                        Question(
                            text: "Uno de los hallazgos de Galileo fue:",
                            options: [
                                "Las anchas calles de Marte",
                                "El cometa Halley",
                                "Las lunas de Júpiter",
                                "La órbita de Plutón"
                            ],
                            correctAnswer: 2
                        )
                    ],
                    eyeExercises: nil,
                    pyramidExercise: nil
                )
            )
            
            // Lección 8 (Lectura: Tecnología)
            lessons.append(
                LessonFromModelsFile(
                    title: "Principiante - Lección 8",
                    description: "Inteligencia Artificial en la vida diaria",
                    type: .reading,
                    timeLimit: 180,
                    content: """
                    La inteligencia artificial se ha vuelto cada vez más común en aplicaciones cotidianas. Desde los asistentes virtuales en nuestros teléfonos hasta los algoritmos de recomendación en[...]
                    """,
                    questions: [
                        Question(
                            text: "¿Cuál es una aplicación cotidiana de la inteligencia artificial?",
                            options: [
                                "Accionamiento manual de automóviles",
                                "Asistentes virtuales en smartphones",
                                "El sol como fuente de calor",
                                "Ninguna de las anteriores"
                            ],
                            correctAnswer: 1
                        )
                    ],
                    eyeExercises: nil,
                    pyramidExercise: nil
                )
            )
            
            // Lección 9 (Lectura: Nutrición)
            lessons.append(
                LessonFromModelsFile(
                    title: "Principiante - Lección 9",
                    description: "Vitaminas y minerales esenciales",
                    type: .reading,
                    timeLimit: 180,
                    content: """
                    Las vitaminas y minerales son micronutrientes fundamentales para el correcto funcionamiento del cuerpo. Por ejemplo, la vitamina C fortalece el sistema inmunológico, mientras que el h[...]
                    """,
                    questions: [
                        Question(
                            text: "¿Cuál de estas funciones realiza el hierro?",
                            options: [
                                "Producir energía eléctrica en el organismo",
                                "Regular la temperatura corporal",
                                "Transportar oxígeno en la sangre",
                                "Desinflamar tejidos"
                            ],
                            correctAnswer: 2
                        )
                    ],
                    eyeExercises: nil,
                    pyramidExercise: nil
                )
            )
            
            // Lección 10 (Entrenamiento Ocular)
            lessons.append(
                LessonFromModelsFile(
                    title: "Principiante - Entrenamiento Ocular 10",
                    description: "Ejercicios para perfeccionar velocidad y enfoque",
                    type: .eyeTraining,
                    timeLimit: 180,
                    content: "",
                    questions: [],
                    eyeExercises: [
                        EyeExercise(
                            type: .dotTracking,
                            duration: 60,
                            instructions: "Sigue el punto que se moverá diagonalmente en la pantalla"
                        ),
                        EyeExercise(
                            type: .focusChange,
                            duration: 60,
                            instructions: "Enfócate en un objeto cercano y luego en otro lejano repetidamente"
                        ),
                        EyeExercise(
                            type: .peripheralVision,
                            duration: 60,
                            instructions: "Amplía tu visión lateral intentando detectar estímulos en los bordes de la pantalla"
                        )
                    ],
                    pyramidExercise: nil
                )
            )
            
            // Lección 11 (Visión periférica - Segunda lección)
            lessons.append(
                LessonFromModelsFile(
                    title: "Principiante - Visión Periférica 11",
                    description: "Texto en pirámide de dificultad media para ampliar tu percepción visual",
                    type: .peripheralVision,
                    timeLimit: 240,
                    content: "",
                    questions: [
                        Question(
                            text: "¿Cuál es la principal diferencia entre la lectura normal y la lectura con visión periférica?",
                            options: [
                                "La primera requiere movimientos oculares y la segunda mantiene la mirada fija",
                                "La primera utiliza el cerebro y la segunda solo los ojos",
                                "La primera es más rápida que la segunda",
                                "No hay diferencia significativa entre ambas"
                            ],
                            correctAnswer: 0
                        )
                    ],
                    eyeExercises: nil,
                    pyramidExercise: PyramidTextExercise(
                        title: "Astronomía y Universo",
                        description: "Amplía tu visión periférica con información sobre el cosmos",
                        introText: "Enfoca tu mirada en la palabra destacada e intenta percibir todo el texto sin mover los ojos.",
                        paragraphs: [
                            PyramidTextExercise.PyramidParagraph(
                                text: "Las        galaxias        contienen\nmillones     de     estrellas     que\nbrillaron   mucho   antes   de\nque    existiera    la\nhumanidad en la Tierra.",
                                focusPoint: "mucho"
                            ),
                            PyramidTextExercise.PyramidParagraph(
                                text: "Nuestro      sol      es\nuna    estrella    de\ntamaño   medio   que\nilumina  nuestro\nsistema solar.",
                                focusPoint: "medio"
                            ),
                            PyramidTextExercise.PyramidParagraph(
                                text: "El      universo      se\nexpande   constantemente   hacia\nel    infinito    desde\nel  Big  Bang\nhasta hoy.",
                                focusPoint: "infinito"
                            )
                        ],
                        difficulty: 2
                    )
                )
            )
            
            
            return lessons
        }
        
    /// Desbloquea la primera etapa y su primera lección
    private func unlockFirstStage() {
        if !stages.isEmpty {
            stages[0].isLocked = false
            if !stages[0].lessons.isEmpty {
                stages[0].lessons[0].isLocked = false
                saveProgress() // Guardar este estado inicial
            }
        }
    }
    
    /// Marca lección como completada y desbloquea la siguiente
    /// - Parameters:
    ///   - stageIndex: Índice de la etapa (0 para Verde, 1 para Azul, etc.)
    ///   - lessonId: UUID identificador único de la lección
    func completeLesson(stageIndex: Int, lessonId: UUID) {
        print("🔄 Intentando completar lección - Etapa: \(stageIndex), Lección ID: \(lessonId)")
        
        // Verificar que la etapa existe
        guard stageIndex < stages.count else {
            print("❌ Error: El índice de etapa \(stageIndex) está fuera de rango")
            return
        }
        
        // NUEVO: Comprobar por índice en lugar de por ID
        // Primero intentamos encontrar por ID exacto
        if let lessonIndex = stages[stageIndex].lessons.firstIndex(where: { $0.id == lessonId }) {
            completeLessonByIndex(stageIndex: stageIndex, lessonIndex: lessonIndex)
        } else {
            // Si no encontramos por ID, buscar lección por posición en la lista
            print("⚠️ No se encontró lección con ID \(lessonId). Verificando lecciones actuales...")
            printAllLessonIDs()
            
            // Estrategia alternativa: completar la primera lección que no esté completada
            if let firstIncompleteLessonIndex = stages[stageIndex].lessons.firstIndex(where: { !$0.isCompleted }) {
                print("🔍 Se encontró una lección incompleta (índice \(firstIncompleteLessonIndex)). Intentando completarla...")
                completeLessonByIndex(stageIndex: stageIndex, lessonIndex: firstIncompleteLessonIndex)
            } else {
                print("❌ No se pudo encontrar una lección para completar en la etapa \(stageIndex)")
            }
        }
    }
    
    // NUEVA FUNCIÓN: Completar lección por índice
    private func completeLessonByIndex(stageIndex: Int, lessonIndex: Int) {
        print("✅ Completando lección en etapa \(stageIndex), índice \(lessonIndex)")
        
        // Verificar índices válidos
        guard stageIndex < stages.count && lessonIndex < stages[stageIndex].lessons.count else {
            print("❌ Índices fuera de rango: stageIndex=\(stageIndex), lessonIndex=\(lessonIndex)")
            return
        }
        
        // Obtener info sobre la lección para depurar
        let lesson = stages[stageIndex].lessons[lessonIndex]
        print("📝 Detalles de la lección: Título='\(lesson.title)', ID=\(lesson.id)")
        
        // Marcar la lección actual como completada (solo si no lo estaba)
        if !stages[stageIndex].lessons[lessonIndex].isCompleted {
            print("✅ Marcando como completada la lección \(lessonIndex + 1) de la etapa \(stageIndex)")
            stages[stageIndex].lessons[lessonIndex].isCompleted = true
            
            // Contar lecciones completadas para verificar el estado de la etapa
            let completedLessonsCount = stages[stageIndex].lessons.filter { $0.isCompleted }.count
            print("📊 Lecciones completadas en etapa \(stageIndex): \(completedLessonsCount)/\(stages[stageIndex].requiredLessons)")
            
            // Desbloquear siguiente lección si existe y no está ya desbloqueada
            if lessonIndex + 1 < stages[stageIndex].lessons.count {
                if stages[stageIndex].lessons[lessonIndex + 1].isLocked {
                    print("🔓 Desbloqueando siguiente lección: \(lessonIndex + 2)")
                    stages[stageIndex].lessons[lessonIndex + 1].isLocked = false
                } else {
                    print("ℹ️ La siguiente lección ya estaba desbloqueada")
                }
            } else {
                print("ℹ️ No hay más lecciones para desbloquear en esta etapa")
            }
            
            // Si se cumplió el requisito para completar la etapa, desbloquear la siguiente
            if completedLessonsCount >= stages[stageIndex].requiredLessons {
                print("🏆 ¡Etapa \(stageIndex) completada! Requisito cumplido: \(completedLessonsCount)/\(stages[stageIndex].requiredLessons)")
                
                // Verificar si hay una siguiente etapa para desbloquear
                if stageIndex + 1 < stages.count {
                    if stages[stageIndex + 1].isLocked {
                        print("🔓 Desbloqueando siguiente etapa: \(stageIndex + 1)")
                        stages[stageIndex + 1].isLocked = false
                        
                        // Desbloquear primera lección de la siguiente etapa
                        if !stages[stageIndex + 1].lessons.isEmpty {
                            print("🔓 Desbloqueando primera lección de la etapa \(stageIndex + 1)")
                            stages[stageIndex + 1].lessons[0].isLocked = false
                        } else {
                            print("⚠️ La etapa \(stageIndex + 1) no tiene lecciones para desbloquear")
                        }
                    } else {
                        print("ℹ️ La siguiente etapa ya estaba desbloqueada")
                    }
                } else {
                    print("🎉 ¡Felicidades! Has completado todas las etapas disponibles")
                }
            }
            
            // IMPORTANTE: Guardar el progreso después de los cambios
            saveProgress()
            
            // Notificar cambios para actualizar la interfaz
            objectWillChange.send()
            print("💾 Progreso guardado y UI actualizada")
        } else {
            print("ℹ️ La lección ya estaba marcada como completada")
        }
    }
    
    // NUEVO: Método para resetear progreso (útil para pruebas)
    func resetProgress() {
        userDefaults.removeObject(forKey: completedLessonsKey)
        userDefaults.removeObject(forKey: unlockedLessonsKey)
        userDefaults.removeObject(forKey: unlockedStagesKey)
        userDefaults.synchronize()
        
        // Recargar etapas
        loadStages()
        unlockFirstStage()
        
        objectWillChange.send()
        print("Progreso reseteado")
    }
    
    // NUEVA FUNCIÓN: Imprimir IDs de todas las lecciones para diagnóstico
    func printAllLessonIDs() {
        print("🔍 LISTADO DE LECCIONES E IDs:")
        for (stageIndex, stage) in stages.enumerated() {
            print("📋 ETAPA \(stageIndex): \(stage.name)")
            for (lessonIndex, lesson) in stage.lessons.enumerated() {
                print("  - Lección \(lessonIndex + 1): '\(lesson.title)'")
                print("    ID: \(lesson.id)")
                print("    Estado: \(lesson.isCompleted ? "Completada ✓" : "Pendiente ○"), \(lesson.isLocked ? "Bloqueada 🔒" : "Desbloqueada 🔓")")
            }
        }
    }
    
    // Método para obtener una lección por su número (índice + 1)
    func getLessonByNumber(stageIndex: Int, lessonNumber: Int) -> LessonFromModelsFile? {
        guard stageIndex < stages.count else { return nil }
        
        let lessonIndex = lessonNumber - 1
        guard lessonIndex >= 0 && lessonIndex < stages[stageIndex].lessons.count else { return nil }
        
        return stages[stageIndex].lessons[lessonIndex]
    }
}
