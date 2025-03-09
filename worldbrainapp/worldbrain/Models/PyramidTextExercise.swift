import SwiftUI

struct PyramidTextExercise: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let introText: String
    let paragraphs: [PyramidParagraph]
    let difficulty: Int // 1-3
    
    struct PyramidParagraph: Identifiable {
        let id = UUID()
        let text: String
        let focusPoint: String // The word or phrase to focus on
    }
}

// Sample exercises for both lessons and challenges
extension PyramidTextExercise {
    static let sampleExercises: [PyramidTextExercise] = [
        PyramidTextExercise(
            title: "Naturaleza y Bienestar",
            description: "Ejercicio para expandir tu visión periférica con texto sobre la naturaleza",
            introText: "Mantén la mirada en la palabra resaltada y trata de percibir todo el párrafo sin mover tus ojos.",
            paragraphs: [
                PyramidParagraph(
                    text: "Los       bosques       son\npulmones    naturales    que\npurifican   el   aire   que\nrespiramos  cada  día\ny nos dan vida.",
                    focusPoint: "aire"
                ),
                PyramidParagraph(
                    text: "El     contacto     con\nla   naturaleza   reduce\nel    estrés    mental\ny   nos   conecta\ncon la tierra.",
                    focusPoint: "estrés"
                ),
                PyramidParagraph(
                    text: "Caminar       entre       árboles\nmejora      nuestro      estado\nde     ánimo     y     nos\nayuda a encontrar paz\ny tranquilidad.",
                    focusPoint: "encontrar"
                )
            ],
            difficulty: 1
        ),
        
        PyramidTextExercise(
            title: "Astronomía y Universo",
            description: "Amplía tu visión periférica con información sobre el cosmos",
            introText: "Enfoca tu mirada en la palabra destacada e intenta percibir todo el texto sin mover los ojos.",
            paragraphs: [
                PyramidParagraph(
                    text: "Las        galaxias        contienen\nmillones     de     estrellas     que\nbrillaron   mucho   antes   de\nque    existiera    la\nhumanidad en la Tierra.",
                    focusPoint: "mucho"
                ),
                PyramidParagraph(
                    text: "Nuestro      sol      es\nuna    estrella    de\ntamaño   medio   que\nilumina  nuestro\nsistema solar.",
                    focusPoint: "medio"
                ),
                PyramidParagraph(
                    text: "El      universo      se\nexpande   constantemente   hacia\nel    infinito    desde\nel  Big  Bang\nhasta hoy.",
                    focusPoint: "infinito"
                )
            ],
            difficulty: 2
        ),
        
        PyramidTextExercise(
            title: "Nutrición y Salud",
            description: "Entrena tu percepción visual con información sobre alimentación saludable",
            introText: "Concentra tu mirada en la palabra central y percibe el resto del texto con tu visión periférica.",
            paragraphs: [
                PyramidParagraph(
                    text: "Los       alimentos       frescos\ncontienen    más    nutrientes    que\nlos   procesados   y   son\nesenciales  para  una\nvida saludable.",
                    focusPoint: "procesados"
                ),
                PyramidParagraph(
                    text: "El      agua      hidrata\ncada    célula    de    nuestro\ncuerpo   y   facilita   todas\nlas  funciones  vitales\ndiarias.",
                    focusPoint: "facilita"
                ),
                PyramidParagraph(
                    text: "Una       dieta       balanceada\ndebe     incluir     proteínas\nvegetales   y   animales\npara  un  óptimo\nrendimiento.",
                    focusPoint: "vegetales"
                )
            ],
            difficulty: 1
        ),
        
        PyramidTextExercise(
            title: "Tecnología e Innovación",
            description: "Mejora tu visión periférica con texto sobre avances tecnológicos",
            introText: "Fija tu mirada en la palabra destacada y trata de absorber todo el párrafo sin mover tus ojos.",
            paragraphs: [
                PyramidParagraph(
                    text: "La      inteligencia      artificial\ntransforma    nuestra    sociedad\ny   cambia   cómo   nos\nrelacionamos  con  la\ntecnología moderna.",
                    focusPoint: "cambia"
                ),
                PyramidParagraph(
                    text: "Los     dispositivos     móviles\nevolucionan    cada    año\npara  ser  más  potentes\ny   más   pequeños\nsimultáneamente.",
                    focusPoint: "potentes"
                ),
                PyramidParagraph(
                    text: "El     internet     conecta\npersonas   de   todo   el\nmundo  en  tiempo  real\nrompiendo  barreras\ngeográficas.",
                    focusPoint: "tiempo"
                )
            ],
            difficulty: 2
        ),
        
        PyramidTextExercise(
            title: "Historia y Civilizaciones",
            description: "Entrena tu visión periférica con textos históricos fascinantes",
            introText: "Centra tu mirada en la palabra resaltada y trata de percibir todo el contexto alrededor.",
            paragraphs: [
                PyramidParagraph(
                    text: "Las      grandes      civilizaciones\nantíguas    construyeron    monumentos\nque   perduran   hasta\nnuestros  días  como\ntestigos silenciosos.",
                    focusPoint: "perduran"
                ),
                PyramidParagraph(
                    text: "El      conocimiento      acumulado\ndurante    milenios    nos\nha  permitido  avanzar\ny   desarrollar   nuevas\nformas de vida.",
                    focusPoint: "avanzar"
                ),
                PyramidParagraph(
                    text: "La        escritura        fue\nun    invento    revolucionario    que\npermitió   preservar   el\npensamiento  humano  a\ntravés del tiempo.",
                    focusPoint: "preservar"
                )
            ],
            difficulty: 3
        )
    ]
}