import SwiftUI

struct NewsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Novedades")
                    .font(.title)
                // Aquí irá el contenido de las novedades
            }
            .navigationTitle("Novedades")
        }
    }
}