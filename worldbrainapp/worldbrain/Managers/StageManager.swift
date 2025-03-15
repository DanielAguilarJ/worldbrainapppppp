//
//  StageManager.swift
//  worldbrain
//
//  Ejemplo con lecturas variadas y preguntas reales para la Etapa Verde (Principiante).
//

import SwiftUI

class StageManager: ObservableObject {
    @Published var stages: [Stage] = []
    @Published var selectedStage: Stage?
    
    init() {
        loadStages()
        unlockFirstStage()
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
            lessons: [], // sin contenido por ahora
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
    
    /// Genera las 10 lecciones de la Etapa Verde con lecturas de distintos temas y 2 entrenamientos oculares
    private func generateGreenStageLessons() -> [Lesson] {
        var lessons: [Lesson] = []
        
        // Lección 1 (Lectura: Historia)
        lessons.append(
            Lesson(
                title: "Principiante - Lección 1",
                description: "Breve introducción a la historia de la escritura",
                type: .reading,
                timeLimit: 180,
                content: """
                Desde los antiguos sumerios hasta las civilizaciones modernas, la escritura ha sido una herramienta esencial para transmitir conocimiento. Los sumerios desarrollaron una de las primeras formas de escritura llamadas 'cuneiforme', hecha a base de marcas en tablillas de arcilla...
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
                eyeExercises: nil
            )
        )
        
        // Lección 2 (Lectura: Ciencia)
        lessons.append(
            Lesson(
                title: "Principiante - Lección 2",
                description: "La maravilla de las células en el cuerpo humano",
                type: .reading,
                timeLimit: 180,
                content: """
                El cuerpo humano está compuesto por trillones de células que trabajan de forma coordinada. Cada célula contiene información genética almacenada en el ADN, el cual dirige el crecimiento y funcionamiento del organismo...
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
                eyeExercises: nil
            )
        )
        
        // Lección 3 (Lectura: Cultura)
        lessons.append(
            Lesson(
                title: "Principiante - Lección 3",
                description: "El arte del café en distintas culturas",
                type: .reading,
                timeLimit: 180,
                content: """
                El café es una de las bebidas más consumidas en el mundo. Desde el espresso italiano hasta el café de olla en México, cada cultura ha desarrollado su forma única de prepararlo. El ritual de tomar café puede variar, pero en todas partes es símbolo de hospitalidad y convivencia...
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
                eyeExercises: nil
            )
        )
        
        // Lección 4 (Lectura: Desarrollo personal)
        lessons.append(
            Lesson(
                title: "Principiante - Lección 4",
                description: "La importancia de la respiración consciente",
                type: .reading,
                timeLimit: 180,
                content: """
                Practicar la respiración consciente puede mejorar la concentración y disminuir el estrés. Al inhalar profundamente y exhalar lentamente, el ritmo cardiaco se regula y la mente se vuelve más clara...
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
                eyeExercises: nil
            )
        )
        
        // Lección 5 (Entrenamiento Ocular)
        // Cada 5 lecciones es un ejercicio ocular
        lessons.append(
            Lesson(
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
                ]
            )
        )
        
        // Lección 6 (Lectura: Medio ambiente)
        lessons.append(
            Lesson(
                title: "Principiante - Lección 6",
                description: "Bosques tropicales y su biodiversidad",
                type: .reading,
                timeLimit: 180,
                content: """
                Los bosques tropicales cubren solo un pequeño porcentaje de la superficie terrestre, pero albergan cerca de la mitad de las especies animales y vegetales del planeta. Proteger estos ecosistemas es vital para el equilibrio climático y la conservación de la diversidad biológica...
                """,
                questions: [
                    Question(
                        text: "¿Qué porcentaje aproximado de la superficie terrestre cubren los bosques tropicales?",
                        options: [
                            "Menos del 10%",
                            "Cerca del 25%",
                            "Más del 50%",
                            "Entre 30% y 40%"
                        ],
                        correctAnswer: 0
                    ),
                    Question(
                        text: "¿Por qué es crucial la protección de los bosques tropicales?",
                        options: [
                            "Porque los seres humanos no viven allí",
                            "Contienen gran parte de la biodiversidad y regulan el clima",
                            "No afectan el clima, solo la economía",
                            "Son la base de la agricultura intensiva"
                        ],
                        correctAnswer: 1
                    )
                ],
                eyeExercises: nil
            )
        )
        
        // Lección 7 (Lectura: Historia de la ciencia)
        lessons.append(
            Lesson(
                title: "Principiante - Lección 7",
                description: "Galileo y el telescopio",
                type: .reading,
                timeLimit: 180,
                content: """
                Galileo Galilei fue uno de los primeros en utilizar el telescopio para observar el cielo. Sus descubrimientos, como las lunas de Júpiter y las fases de Venus, desafiaron la visión geocéntrica y allanaron el camino para la astronomía moderna...
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
                eyeExercises: nil
            )
        )
        
        // Lección 8 (Lectura: Tecnología)
        lessons.append(
            Lesson(
                title: "Principiante - Lección 8",
                description: "Inteligencia Artificial en la vida diaria",
                type: .reading,
                timeLimit: 180,
                content: """
                La inteligencia artificial se ha vuelto cada vez más común en aplicaciones cotidianas. Desde los asistentes virtuales en nuestros teléfonos hasta los algoritmos de recomendación en redes sociales, la IA analiza datos masivos para ofrecer respuestas rápidas y personalizadas...
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
                eyeExercises: nil
            )
        )
        
        // Lección 9 (Lectura: Nutrición)
        lessons.append(
            Lesson(
                title: "Principiante - Lección 9",
                description: "Vitaminas y minerales esenciales",
                type: .reading,
                timeLimit: 180,
                content: """
                Las vitaminas y minerales son micronutrientes fundamentales para el correcto funcionamiento del cuerpo. Por ejemplo, la vitamina C fortalece el sistema inmunológico, mientras que el hierro interviene en el transporte de oxígeno en la sangre...
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
                eyeExercises: nil
            )
        )
        
        // Lección 10 (Entrenamiento Ocular)
        lessons.append(
            Lesson(
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
                ]
            )
        )
        
        // Listo, 10 lecciones
        return lessons
    }
    
    /// Desbloquea la primera etapa y su primera lección
    private func unlockFirstStage() {
        if !stages.isEmpty {
            stages[0].isLocked = false
            stages[0].lessons[0].isLocked = false
        }
    }
    
    /// Marca lección como completada y desbloquea la siguiente
    func completeLesson(stageIndex: Int, lessonId: UUID) {
        guard stageIndex < stages.count,
              let lessonIndex = stages[stageIndex].lessons.firstIndex(where: { $0.id == lessonId }) else { return }
        
        // Marcar la lección actual como completada
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
        
        // Notificar cambios
        objectWillChange.send()
    }
}
