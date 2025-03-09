import SwiftUI

struct CourseSelectorView: View {
    var body: some View {
        NavigationView {
            List {
                HStack {
                    Image(systemName: "book.fill")
                        .foregroundColor(.blue)
                    Text("Fotolectura")
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Image(systemName: "book.fill")
                        .foregroundColor(.gray)
                    Text("Más cursos próximamente")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Seleccionar Curso")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
