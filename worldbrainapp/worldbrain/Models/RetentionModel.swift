//
//  RetentionModel.swift
//  worldbrainapp
//
//  Modelos y datos de ejemplo para los ejercicios de retención
//

import Foundation

/// Representa una pregunta de retención
struct RetentionQuestion {
    let text: String
    let options: [String]
    let correctIndex: Int
}

/// Representa un ejercicio de retención (un párrafo + un quiz)
struct RetentionExercise {
    let paragraph: String
    let questions: [RetentionQuestion]
    let readingTime: Int
}

/// Arreglo con varias lecturas de ejemplo
/// NOTA: Asegúrate de que cada exercise tenga >= 1 pregunta
/// y, si quieres que necesite 2 aciertos, inclúyeles 2+ preguntas.
let retentionExercises: [RetentionExercise] = [
    RetentionExercise(
        paragraph: """
        El colibrí es uno de los pájaros más pequeños del mundo. 
        Puede batir sus alas a una velocidad de hasta 50 veces por segundo, 
        lo que le permite flotar en el aire e incluso desplazarse hacia atrás.
        """,
        questions: [
            RetentionQuestion(
                text: "¿Cuántas veces por segundo puede batir sus alas un colibrí?",
                options: ["50", "10", "100", "25"],
                correctIndex: 0
            ),
            RetentionQuestion(
                text: "¿Cuál de estas aves puede volar hacia atrás?",
                options: ["Águila", "Paloma", "Colibrí", "Canario"],
                correctIndex: 2
            )
        ],
        readingTime: 10
    ),
    RetentionExercise(
        paragraph: """
        Los romanos construyeron grandes acueductos para llevar agua a sus ciudades. 
        Estas obras de ingeniería permitieron un suministro continuo de agua limpia 
        y contribuyeron a mejorar la higiene y la salud pública.
        """,
        questions: [
            RetentionQuestion(
                text: "¿Para qué usaban los romanos los acueductos?",
                options: [
                    "Para transportar mercancía",
                    "Para llevar agua a sus ciudades",
                    "Para defenderse de invasores",
                    "Para cultivar trigo en invierno"
                ],
                correctIndex: 1
            ),
            RetentionQuestion(
                text: "¿Qué beneficio ofrecían los acueductos?",
                options: [
                    "Agua limpia y mejora en la salud pública",
                    "Reducción de impuestos",
                    "Transformar vino en agua",
                    "Proteger contra terremotos"
                ],
                correctIndex: 0
            )
        ],
        readingTime: 10
    )
    // Agrega más RetentionExercise con 2 o más preguntas para un mejor umbral.
]
