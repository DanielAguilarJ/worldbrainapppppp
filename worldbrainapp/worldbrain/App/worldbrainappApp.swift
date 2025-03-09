import SwiftUI
import FirebaseCore  // <-- Importante para Firebase

// 1) AppDelegate para configurar Firebase
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        // Inicializa Firebase
        FirebaseApp.configure()
        
        return true
    }
}

// 2) Tu struct principal con @main
@main
struct WorldBrainApp: App {
    // Registramos el AppDelegate de Firebase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            // La vista raíz de tu app
            MainTabView()
            // o ContentView(), etc., como tenías antes
        }
    }
}
