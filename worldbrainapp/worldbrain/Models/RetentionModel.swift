//
//  RetentionQuestion.swift
//  worldbrainapp
//
//  Created by Daniel on 24/01/2025.
//


//
//  RetentionModel.swift
//  worldbrainapp
//
//  Modelos y datos de ejemplo para los ejercicios de retención
//
import SwiftUI
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
    let readingTime: Int
    let questions: [RetentionQuestion]
}

/// Arreglo con varias lecturas de ejemplo. Se elige una al azar en ChallengesView.
let retentionExercises: [RetentionExercise] = [
    RetentionExercise(
        paragraph: """
        El colibrí es uno de los pájaros más pequeños del mundo. 
        Puede batir sus alas a una velocidad de hasta 50 veces por segundo, 
        lo que le permite flotar en el aire e incluso desplazarse hacia atrás.
        """,
        readingTime: 10,
        questions: [
            RetentionQuestion(
                text: "¿Cuántas veces por segundo puede batir sus alas un colibrí?",
                options: ["50", "10", "100", "25"],
                correctIndex: 0
            ),
            RetentionQuestion(
                text: "¿Qué ave puede volar hacia atrás?",
                options: ["Águila", "Paloma", "Colibrí", "Canario"],
                correctIndex: 2
            )
        ]
    ),
    RetentionExercise(
        paragraph: """
        Los romanos construyeron grandes acueductos para llevar agua a sus ciudades. 
        Estas obras de ingeniería permitieron un suministro continuo de agua limpia 
        y contribuyeron a mejorar la higiene y la salud pública.
        """,
        readingTime: 10,
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
            )
        ]
    ),
    // Agrega más RetentionExercise si deseas
]
