import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Mi Perfil")
                    .font(.title)
                // Aquí irá el contenido del perfil
            }
            .navigationTitle("Mi Perfil")
        }
    }
}