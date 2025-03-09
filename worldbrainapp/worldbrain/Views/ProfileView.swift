//
//  ProfileView.swift
//  worldbrainapp
//
//  Vista mejorada del perfil de usuario
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var xpManager: XPManager
    @AppStorage("userName") private var userName: String = "Usuario"
    @AppStorage("userEmail") private var userEmail: String = "usuario@ejemplo.com"
    @State private var showEditProfile = false
    @State private var tempUserName: String = ""
    @State private var tempUserEmail: String = ""
    @State private var selectedAvatar: Int = UserDefaults.standard.integer(forKey: "selectedAvatar")
    @State private var showingLogoutAlert = false
    
    // Cálculos para el nivel basado en XP
    var userLevel: Int {
        return max(1, xpManager.currentXP / 100)
    }
    
    // Progreso hacia el siguiente nivel (0-1)
    var levelProgress: Double {
        let nextLevelXP = (userLevel + 1) * 100
        let currentLevelXP = userLevel * 100
        return Double(xpManager.currentXP - currentLevelXP) / Double(nextLevelXP - currentLevelXP)
    }
    
    // XP necesaria para el siguiente nivel
    var xpForNextLevel: Int {
        return (userLevel + 1) * 100
    }
    
    // Total de sesiones completadas (demo)
    var completedSessions: Int {
        return UserDefaults.standard.integer(forKey: "completedSessions")
    }
    
    // Días consecutivos (demo)
    var streakDays: Int {
        return UserDefaults.standard.integer(forKey: "streakDays")
    }
    
    // Avatares disponibles
    let avatars = ["person.crop.circle.fill", "person.crop.circle.fill.badge.checkmark", "person.circle", "person.circle.fill", "person.bust.fill", "person.fill.viewfinder", "person.fill.badge.plus"]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fondo con gradiente
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.4)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Cabecera del perfil
                        ProfileHeaderView(
                            userName: userName,
                            userLevel: userLevel,
                            readerLevel: xpManager.readerLevel,
                            levelProgress: levelProgress,
                            xp: xpManager.currentXP,
                            xpForNextLevel: xpForNextLevel,
                            selectedAvatar: selectedAvatar,
                            avatars: avatars,
                            onEditProfile: { showEditProfile = true }
                        )
                        .padding(.top, geometry.safeAreaInsets.top + 20)
                        
                        // Estadísticas del usuario
                        StatsCardView(
                            completedSessions: completedSessions,
                            streakDays: streakDays
                        )
                        
                        // Logros
                        AchievementsView(xp: xpManager.currentXP)
                        
                        // Historial de actividad
                        ActivityHistoryView()
                        
                        // Configuración y opciones
                        SettingsCardView(
                            onLogout: { showingLogoutAlert = true }
                        )
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal)
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(
                    userName: $userName,
                    userEmail: $userEmail,
                    selectedAvatar: $selectedAvatar,
                    avatars: avatars
                )
            }
            .alert("Cerrar sesión", isPresented: $showingLogoutAlert) {
                Button("Cancelar", role: .cancel) {}
                Button("Cerrar sesión", role: .destructive) {
                    // Aquí puedes agregar la lógica para cerrar sesión
                }
            } message: {
                Text("¿Estás seguro de que quieres cerrar sesión?")
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Componentes de la interfaz

// Cabecera del perfil
struct ProfileHeaderView: View {
    let userName: String
    let userLevel: Int
    let readerLevel: ReaderLevel
    let levelProgress: Double
    let xp: Int
    let xpForNextLevel: Int
    let selectedAvatar: Int
    let avatars: [String]
    let onEditProfile: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            ZStack(alignment: .bottomTrailing) {
                // Avatar del usuario
                Image(systemName: avatars[selectedAvatar % avatars.count])
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 5)
                
                // Botón de editar
                Button(action: onEditProfile) {
                    Image(systemName: "pencil.circle.fill")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .offset(x: 5, y: 5)
            }
            
            // Nombre del usuario
            Text(userName)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Nivel de lector
            Text(readerLevel.rawValue)
                .font(.headline)
                .foregroundColor(.yellow)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.2))
                .cornerRadius(15)
            
            // Nivel y barra de progreso
            VStack(spacing: 6) {
                HStack {
                    Text("Nivel \(userLevel)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(xp) / \(xpForNextLevel) XP")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Barra de progreso
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Fondo de la barra
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.black.opacity(0.2))
                            .frame(height: 10)
                        
                        // Progreso
                        RoundedRectangle(cornerRadius: 5)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.yellow, .orange]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * levelProgress, height: 10)
                        
                    }
                }
                .frame(height: 10)
            }
            .padding()
            .background(Color.white.opacity(0.15))
            .cornerRadius(15)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
    }
}

// Estadísticas del usuario
struct StatsCardView: View {
    let completedSessions: Int
    let streakDays: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Estadísticas")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 15) {
                // Ejercicios completados
                StatItem(
                    value: "\(completedSessions)",
                    label: "Completados",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                Divider()
                    .frame(width: 1)
                    .background(Color.white.opacity(0.3))
                    .padding(.vertical, 5)
                
                // Racha diaria
                StatItem(
                    value: "\(streakDays)",
                    label: "Días seguidos",
                    icon: "flame.fill",
                    color: .orange
                )
                
                Divider()
                    .frame(width: 1)
                    .background(Color.white.opacity(0.3))
                    .padding(.vertical, 5)
                
                // Tiempo de estudio (demo)
                StatItem(
                    value: "2h 30m",
                    label: "Tiempo total",
                    icon: "clock.fill",
                    color: .blue
                )
            }
            .padding()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
    }
}

// Item de estadística individual
struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
}

// Sección de logros
struct AchievementsView: View {
    let xp: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Logros")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    // Primer ejercicio
                    AchievementItem(
                        title: "Primer ejercicio",
                        description: "Completaste tu primer ejercicio",
                        icon: "star.fill",
                        color: .yellow,
                        isUnlocked: true
                    )
                    
                    // Maestro de la memoria
                    AchievementItem(
                        title: "Maestro de la memoria",
                        description: "Completa 10 ejercicios de retención",
                        icon: "brain.head.profile",
                        color: .green,
                        isUnlocked: xp >= 300
                    )
                    
                    // Velocidad lectora
                    AchievementItem(
                        title: "Velocidad lectora",
                        description: "Alcanza 300 palabras por minuto",
                        icon: "speedometer",
                        color: .red,
                        isUnlocked: xp >= 500
                    )
                    
                    // Racha semanal
                    AchievementItem(
                        title: "Racha semanal",
                        description: "7 días seguidos de práctica",
                        icon: "calendar.badge.clock",
                        color: .blue,
                        isUnlocked: false
                    )
                }
                .padding(.horizontal, 5)
                .padding(.bottom, 5)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
    }
}

// Item de logro individual
struct AchievementItem: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isUnlocked: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? color : Color.gray.opacity(0.5))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .offset(x: 20, y: 20)
                }
            }
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .frame(width: 120)
        }
        .frame(width: 130, height: 180)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

// Historial de actividad
struct ActivityHistoryView: View {
    // Datos de ejemplo para el historial
    let activities = [
        Activity(name: "Ejercicio de Retención", date: "Hoy", xp: 35, icon: "brain.head.profile"),
        Activity(name: "Pares de Palabras", date: "Ayer", xp: 55, icon: "text.bubble.fill"),
        Activity(name: "Palabras Desiguales", date: "02/03/2025", xp: 40, icon: "character.textbox"),
        Activity(name: "Ejercicio de Retención", date: "01/03/2025", xp: 30, icon: "brain.head.profile")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Actividad reciente")
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(activities) { activity in
                HStack {
                    Image(systemName: activity.icon)
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.blue.opacity(0.5))
                        .cornerRadius(10)
                    
                    VStack(alignment: .leading) {
                        Text(activity.name)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Text(activity.date)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text("+\(activity.xp) XP")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                }
                .padding(.vertical, 8)
                
                if activity.id != activities.last?.id {
                    Divider()
                        .background(Color.white.opacity(0.2))
                }
            }
            
            Button(action: {
                // Ver todo el historial
            }) {
                Text("Ver todo")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue.opacity(0.5))
                    .cornerRadius(10)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
    }
}

// Configuración
struct SettingsCardView: View {
    let onLogout: () -> Void
    @AppStorage("notifications") private var notificationsEnabled = true
    @AppStorage("darkMode") private var darkModeEnabled = false
    @AppStorage("soundEffects") private var soundEffectsEnabled = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Configuración")
                .font(.headline)
                .foregroundColor(.white)
            
            // Notificaciones
            ToggleSetting(
                title: "Notificaciones",
                icon: "bell.fill",
                isOn: $notificationsEnabled
            )
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // Modo oscuro
            ToggleSetting(
                title: "Modo oscuro",
                icon: "moon.fill",
                isOn: $darkModeEnabled
            )
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // Efectos de sonido
            ToggleSetting(
                title: "Efectos de sonido",
                icon: "speaker.wave.2.fill",
                isOn: $soundEffectsEnabled
            )
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // Cerrar sesión
            Button(action: onLogout) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                        .font(.system(size: 18))
                        .frame(width: 25)
                    
                    Text("Cerrar sesión")
                        .foregroundColor(.red)
                    
                    Spacer()
                }
                .padding(.vertical, 5)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
    }
}

// Toggle para configuración
struct ToggleSetting: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.system(size: 18))
                .frame(width: 25)
            
            Text(title)
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.vertical, 5)
    }
}

// Vista de edición de perfil
struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var userName: String
    @Binding var userEmail: String
    @Binding var selectedAvatar: Int
    let avatars: [String]
    @State private var tempUserName: String = ""
    @State private var tempUserEmail: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo
                Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // Selector de avatar
                    VStack(spacing: 15) {
                        Text("Escoge un avatar")
                            .font(.headline)
                            .padding(.top)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(0..<avatars.count, id: \.self) { index in
                                    Button(action: {
                                        selectedAvatar = index
                                        UserDefaults.standard.set(index, forKey: "selectedAvatar")
                                    }) {
                                        Image(systemName: avatars[index])
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 60, height: 60)
                                            .padding(10)
                                            .foregroundColor(.white)
                                            .background(selectedAvatar == index ? Color.blue : Color.gray)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .strokeBorder(selectedAvatar == index ? Color.white : Color.clear, lineWidth: 3)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Campos de edición
                    VStack(spacing: 20) {
                        TextField("Nombre", text: $tempUserName)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                        
                        TextField("Email", text: $tempUserEmail)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        userName = tempUserName
                        userEmail = tempUserEmail
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                tempUserName = userName
                tempUserEmail = userEmail
            }
        }
    }
}

// Modelos de datos
struct Activity: Identifiable {
    let id = UUID()
    let name: String
    let date: String
    let xp: Int
    let icon: String
}

// Vista previa
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(xpManager: XPManager())
    }
}
