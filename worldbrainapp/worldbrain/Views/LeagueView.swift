import SwiftUI

struct LeagueView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Liga")
                    .font(.title)
                // Aquí irá el contenido de las ligas
            }
            .navigationTitle("Liga")
        }
    }
}