import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var isLessonActive = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                ContentView()
            }
            .tabItem {
                Image(systemName: "book.fill")
                Text("Lecciones")
            }
            .tag(0)
            
            LeagueView()
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Liga")
                }
                .tag(1)
            
            ChallengesView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Desafíos")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Perfil")
                }
                .tag(3)
            
            NewsView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("Novedades")
                }
                .tag(4)
        }
        .accentColor(.blue)
        .opacity(isLessonActive ? 0 : 1)
    }
}

