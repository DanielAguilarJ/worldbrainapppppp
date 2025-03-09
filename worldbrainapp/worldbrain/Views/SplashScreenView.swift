import SwiftUI
import AVFoundation

struct SplashScreenView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack {
                Text("WorldBrain")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.blue)
                Text("Fotolectura")
                    .font(.system(size: 35, weight: .medium))
                    .foregroundColor(.gray)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}
