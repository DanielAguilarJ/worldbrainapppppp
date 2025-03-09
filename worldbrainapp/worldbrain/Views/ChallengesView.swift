import SwiftUI

struct ChallengesView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Desafíos")
                    .font(.title)
                // Aquí irá el contenido de los desafíos
            }
            .navigationTitle("Desafíos")
        }
    }
}