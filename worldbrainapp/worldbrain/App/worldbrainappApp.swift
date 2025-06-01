import SwiftUI
import Appwrite      // <-- SDK de Appwrite

// 1) AppDelegate para configurar Appwrite
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        // Appwrite no requiere configuración aquí
        return true
    }
    
    // Para manejar URLs de OAuth de Appwrite (si se usa UIKit)
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url,
              url.absoluteString.contains("appwrite-callback") else {
            return
        }
        // WebAuthComponent.handleIncomingCookie(from: url) // Descomenta si usas OAuth
    }
}

// 2) Tu struct principal con @main
@main
struct WorldBrainApp: App {
    // Registramos el AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var userProgress = UserProgress()
    
    var body: some Scene {
        WindowGroup {
            // La vista raíz de tu app
            MainTabView()
                .environmentObject(userProgress)
        }
    }
}
