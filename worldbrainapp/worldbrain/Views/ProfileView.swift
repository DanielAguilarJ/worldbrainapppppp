//
//  ProfileView.swift
//  worldbrainapp
//
//  Vista mejorada del perfil de usuario
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var xpManager: XPManager
    @StateObject private var achievementManager = AchievementManager()
    @StateObject private var analyticsManager = AnalyticsManager()
    @AppStorage("userName") private var userName: String = "Usuario"
    @AppStorage("userEmail") private var userEmail: String = "usuario@ejemplo.com"
    @State private var showEditProfile = false
    @State private var showAnalyticsDashboard = false
    @State private var selectedAvatar: Int = UserDefaults.standard.integer(forKey: "selectedAvatar")
    @State private var showingLogoutAlert = false
    
    // Configuración
    @AppStorage("notifications") private var notificationsEnabled = true
    @AppStorage("darkMode") private var darkModeEnabled = false
    @AppStorage("soundEffects") private var soundEffectsEnabled = true
    
    // Estadísticas de usuario
    @AppStorage("completedSessions") private var completedSessions: Int = 0
    @AppStorage("streakDays") private var streakDays: Int = 0
    @AppStorage("totalTimeSpent") private var totalTimeSpent: Int = 0 // en minutos
    
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
    
    // Formateo del tiempo total
    var formattedTimeSpent: String {
        let hours = totalTimeSpent / 60
        let minutes = totalTimeSpent % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    // Avatares disponibles
    let avatars = ["person.crop.circle.fill", "person.crop.circle.fill.badge.checkmark", "person.circle", "person.circle.fill", "person.bust.fill", "person.fill.viewfinder", "person.fill.badge.plus"]
    
    var body: some View {
        GeometryReader { geometry in
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
                    .padding(.top, 20)
                    
                    // Estadísticas del usuario
                    StatsCardView(
                        completedSessions: completedSessions,
                        streakDays: streakDays,
                        timeSpent: formattedTimeSpent
                    )
                    
                    // Botón para acceder a Analíticas Avanzadas
                    AnalyticsPreviewCard(
                        analyticsManager: analyticsManager,
                        onShowDashboard: { showAnalyticsDashboard = true }
                    )
                    
                    // Logros
                    AchievementsView(
                        xp: xpManager.currentXP,
                        completedSessions: completedSessions,
                        streakDays: streakDays,
                        achievementManager: achievementManager
                    )
                    
                    // Historial de actividad
                    ActivityHistoryView(xpManager: xpManager)
                    
                    // Configuración y opciones
                    SettingsCardView(
                        notificationsEnabled: $notificationsEnabled,
                        darkModeEnabled: $darkModeEnabled,
                        soundEffectsEnabled: $soundEffectsEnabled,
                        onLogout: { showingLogoutAlert = true }
                    )
                    
                    // Espacio extra para la barra de tabs
                    Spacer(minLength: 90)
                }
                .padding(.horizontal)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.4)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                )
            }
            .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(
                userName: $userName,
                userEmail: $userEmail,
                selectedAvatar: $selectedAvatar,
                avatars: avatars
            )
        }
        .sheet(isPresented: $showAnalyticsDashboard) {
            AnalyticsDashboardView()
        }
        .alert("Cerrar sesión", isPresented: $showingLogoutAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Cerrar sesión", role: .destructive) {
                // Aquí iría la lógica para cerrar sesión
                userName = "Usuario"
                userEmail = "usuario@ejemplo.com"
            }
        } message: {
            Text("¿Estás seguro de que quieres cerrar sesión?")
        }
        .onChange(of: darkModeEnabled) { newValue in
            applyDarkMode(newValue)
        }
        .onChange(of: soundEffectsEnabled) { newValue in
            applySoundEffects(newValue)
        }
        .onChange(of: notificationsEnabled) { newValue in
            applyNotifications(newValue)
        }
        .onAppear {
            // Verificar y actualizar logros cuando aparece la vista
            achievementManager.checkAndUpdateAchievements(
                xp: xpManager.currentXP,
                completedSessions: completedSessions,
                streakDays: streakDays
            )
        }
    }
    
    // Funciones para aplicar configuraciones
    private func applyDarkMode(_ enabled: Bool) {
        // Utiliza UIApplication para configurar el modo de apariencia
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.overrideUserInterfaceStyle = enabled ? .dark : .light
    }
    
    private func applySoundEffects(_ enabled: Bool) {
        // Aquí se configuraría el sistema de sonido
        // Por ahora solo guardamos la preferencia
        UserDefaults.standard.set(enabled, forKey: "soundEffects")
    }
    
    private func applyNotifications(_ enabled: Bool) {
        if enabled {
            // Solicitar permisos de notificaciones
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    // Permisos concedidos, configurar notificaciones
                    configureNotifications()
                } else {
                    // Permisos denegados, actualizar el estado
                    DispatchQueue.main.async {
                        notificationsEnabled = false
                    }
                }
            }
        } else {
            // Desactivar notificaciones
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }
    
    private func configureNotifications() {
        // Configurar recordatorio diario
        let content = UNMutableNotificationContent()
        content.title = "¡Hora de practicar!"
        content.body = "No pierdas tu racha diaria. Un breve ejercicio te ayudará a mejorar."
        content.sound = UNNotificationSound.default
        
        // Notificar a las 5 PM cada día
        var dateComponents = DateComponents()
        dateComponents.hour = 17
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
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
    let timeSpent: String
    
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
                
                // Tiempo de estudio
                StatItem(
                    value: timeSpent,
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

// MARK: - Gestor de logros

class AchievementManager: ObservableObject {
    @Published var unlockedAchievements: [Achievement] = []
    
    // Logros disponibles con sus condiciones
    var availableAchievements: [Achievement] {
        let baseAchievements = [
            ("first_exercise", "Primer ejercicio", "Completaste tu primer ejercicio", "star.fill", AchievementCategory.special, AchievementRarity.common, { (xp: Int, sessions: Int, streak: Int) in sessions >= 1 }),
            ("memory_master", "Maestro de la memoria", "Completa 10 ejercicios de retención", "brain.head.profile", AchievementCategory.mastery, AchievementRarity.rare, { (xp: Int, sessions: Int, streak: Int) in sessions >= 10 }),
            ("speed_reading", "Velocidad lectora", "Alcanza 300 puntos de XP", "speedometer", AchievementCategory.speed, AchievementRarity.epic, { (xp: Int, sessions: Int, streak: Int) in xp >= 300 }),
            ("weekly_streak", "Racha semanal", "7 días seguidos de práctica", "calendar.badge.clock", AchievementCategory.consistency, AchievementRarity.rare, { (xp: Int, sessions: Int, streak: Int) in streak >= 7 })
            )
        ]
    }
    
    init() {
        // Cargar logros desbloqueados previamente
        loadUnlockedAchievements()
    }
    
    func checkAndUpdateAchievements(xp: Int, completedSessions: Int, streakDays: Int) {
        // Verificar cada logro
        for achievement in availableAchievements {
            // Si cumple la condición y no está ya desbloqueado
            if achievement.isUnlocked(xp, completedSessions, streakDays) &&
               !isAchievementUnlocked(id: achievement.id) {
                // Desbloquear logro
                unlockAchievement(achievement.id)
                
                // Añadir actividad para mostrar en la lista reciente
                ActivityManager.addActivity(
                    name: "¡Logro desbloqueado: \(achievement.title)!",
                    xp: 50, // XP de bonificación por logro
                    icon: achievement.iconName
                )
            }
        }
    }
    
    func isAchievementUnlocked(id: String) -> Bool {
        return unlockedAchievements.contains { $0.id.uuidString == id }
    }
    
    private func unlockAchievement(_ id: String) {
        // Buscar el logro en la lista de disponibles
        if let achievement = availableAchievements.first(where: { $0.id.uuidString == id }) {
            // Añadir a los desbloqueados
            unlockedAchievements.append(achievement)
            
            // Guardar estado actualizado
            saveUnlockedAchievements()
        }
    }
    
    private func loadUnlockedAchievements() {
        if let data = UserDefaults.standard.data(forKey: "unlockedAchievements"),
           let achievementIds = try? JSONDecoder().decode([String].self, from: data) {
            // Convertir los IDs desbloqueados en objetos Achievement
            unlockedAchievements = availableAchievements.filter { achievement in
                achievementIds.contains(achievement.id.uuidString)
            }
        }
    }
    
    private func saveUnlockedAchievements() {
        // Guardar solo los IDs de los logros desbloqueados
        let achievementIds = unlockedAchievements.map { $0.id.uuidString }
        if let data = try? JSONEncoder().encode(achievementIds) {
            UserDefaults.standard.set(data, forKey: "unlockedAchievements")
        }
    }
}

// MARK: - Vista de logros

struct AchievementsView: View {
    let xp: Int
    let completedSessions: Int
    let streakDays: Int
    @ObservedObject var achievementManager: AchievementManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Logros")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(achievementManager.availableAchievements) { achievement in
                        let isUnlocked = achievement.isUnlocked ||
                                        achievementManager.isAchievementUnlocked(id: achievement.id.uuidString)
                        
                        AchievementItem(
                            title: achievement.title,
                            description: achievement.description,
                            icon: achievement.iconName,
                            category: achievement.category,
                            isUnlocked: isUnlocked
                        )
                    }
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
    let category: AchievementCategory
    let isUnlocked: Bool
    
    private var categoryColor: Color {
        switch category {
        case .speed:
            return .red
        case .consistency:
            return .blue
        case .improvement:
            return .green
        case .mastery:
            return .purple
        case .social:
            return .orange
        case .special:
            return .yellow
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? categoryColor : Color.gray.opacity(0.5))
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

// MARK: - Modelo y gestión de actividades

struct Activity: Identifiable, Codable {
    let id: UUID
    let name: String
    let date: String
    let xp: Int
    let icon: String
    
    init(id: UUID = UUID(), name: String, date: String, xp: Int, icon: String) {
        self.id = id
        self.name = name
        self.date = date
        self.xp = xp
        self.icon = icon
    }
}

struct ActivityManager {
    // Método estático para añadir una nueva actividad desde cualquier parte de la app
    static func addActivity(name: String, xp: Int, icon: String) {
        // Obtener la fecha actual formateada
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let currentDate = dateFormatter.string(from: Date())
        
        // Crear la nueva actividad
        let newActivity = Activity(name: name, date: currentDate, xp: xp, icon: icon)
        
        // Obtener actividades existentes
        var currentActivities: [Activity] = []
        if let data = UserDefaults.standard.data(forKey: "recentActivities") {
            do {
                currentActivities = try JSONDecoder().decode([Activity].self, from: data)
            } catch {
                print("Error decodificando actividades existentes: \(error)")
            }
        }
        
        // Añadir la nueva actividad al principio
        currentActivities.insert(newActivity, at: 0)
        
        // Limitar a las 20 actividades más recientes
        if currentActivities.count > 20 {
            currentActivities = Array(currentActivities.prefix(20))
        }
        
        // Guardar en UserDefaults
        do {
            let encodedData = try JSONEncoder().encode(currentActivities)
            UserDefaults.standard.set(encodedData, forKey: "recentActivities")
        } catch {
            print("Error codificando actividades: \(error)")
        }
        
        // Incrementar contador de sesiones completadas
        let completedSessions = UserDefaults.standard.integer(forKey: "completedSessions")
        UserDefaults.standard.set(completedSessions + 1, forKey: "completedSessions")
        
        // Actualizar tiempo total (supongamos que cada actividad consume X minutos en promedio)
        let timeSpent = UserDefaults.standard.integer(forKey: "totalTimeSpent")
        UserDefaults.standard.set(timeSpent + 15, forKey: "totalTimeSpent") // Añade 15 minutos por actividad
        
        // Actualizar racha diaria si es necesario
        updateStreak()
    }
    
    // Actualizar la racha diaria
    static func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastActiveDay = UserDefaults.standard.object(forKey: "lastActiveDay") as? Date {
            let lastActive = Calendar.current.startOfDay(for: lastActiveDay)
            
            if lastActive == today {
                // Ya se registró actividad hoy, no hacer nada
                return
            } else if let daysBetween = Calendar.current.dateComponents([.day], from: lastActive, to: today).day, daysBetween == 1 {
                // Día consecutivo
                let streak = UserDefaults.standard.integer(forKey: "streakDays")
                UserDefaults.standard.set(streak + 1, forKey: "streakDays")
            } else {
                // Se rompió la racha
                UserDefaults.standard.set(1, forKey: "streakDays")
            }
        } else {
            // Primera actividad
            UserDefaults.standard.set(1, forKey: "streakDays")
        }
        
        // Actualizar último día activo
        UserDefaults.standard.set(today, forKey: "lastActiveDay")
    }
}

// MARK: - Historial de actividad

struct ActivityHistoryView: View {
    @ObservedObject var xpManager: XPManager
    @State private var activities: [Activity] = []
    @State private var refreshFlag: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Actividad reciente")
                .font(.headline)
                .foregroundColor(.white)
            
            if activities.isEmpty {
                // Mensaje cuando no hay actividades
                VStack(spacing: 10) {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("No hay actividades recientes")
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)
            } else {
                // Lista de actividades
                ForEach(activities.prefix(4)) { activity in
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
                        
                        if activity.xp > 0 {
                            Text("+\(activity.xp) XP")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        } else {
                            Text("Pendiente")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    if activity.id != activities.prefix(4).last?.id {
                        Divider()
                            .background(Color.white.opacity(0.2))
                    }
                }
            }
            
            // Botón para crear actividad de prueba
            HStack(spacing: 15) {
                Button(action: {
                    // Registrar actividad de lectura rápida
                    ActivityManager.addActivity(
                        name: "Ejercicio de Lectura Rápida",
                        xp: 25,
                        icon: "bolt.fill"
                    )
                    
                    // Actualizar la XP del usuario
                    xpManager.addXP(25)
                    
                    // Disparar recargar actividades
                    loadActivities()
                    refreshFlag.toggle()
                }) {
                    Text("Registrar actividad")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.blue.opacity(0.5))
                        .cornerRadius(10)
                }
                
                Button(action: {
                    // Registrar actividad de memoria
                    ActivityManager.addActivity(
                        name: "Ejercicio de Memoria",
                        xp: 35,
                        icon: "brain.head.profile"
                    )
                    
                    // Actualizar la XP del usuario
                    xpManager.addXP(35)
                    
                    // Disparar recargar actividades
                    loadActivities()
                    refreshFlag.toggle()
                }) {
                    Text("Otro ejercicio")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.purple.opacity(0.5))
                        .cornerRadius(10)
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
        .onAppear(perform: loadActivities)
        .onChange(of: refreshFlag) { _ in
            loadActivities()
        }
    }
    
    func loadActivities() {
        if let data = UserDefaults.standard.data(forKey: "recentActivities") {
            do {
                activities = try JSONDecoder().decode([Activity].self, from: data)
            } catch {
                print("Error decodificando actividades: \(error)")
                activities = []
            }
        } else {
            // Si no hay datos, crear actividades de ejemplo
            activities = [
                Activity(
                    name: "Bienvenido a WorldBrain",
                    date: "Hoy",
                    xp: 50,
                    icon: "star.fill"
            ]
        
        return baseAchievements.map { (id, title, description, iconName, category, rarity, condition) in
            let isUnlocked = condition(xp, completedSessions, streakDays)
            return Achievement(
                title: title,
                description: description,
                iconName: iconName,
                isUnlocked: isUnlocked,
                earnedDate: isUnlocked ? Date() : nil,
                category: category,
                rarity: rarity,
                progress: isUnlocked ? 1.0 : 0.5,
                requirements: [description]
            )
        }
    }
                Activity(
                        name: "Completa tu primer ejercicio",
                        date: "Pendiente",
                        xp: 0,
                        icon: "flag.fill"
                    )
                ]
            }
        }
    }

    // MARK: - Configuración

    struct SettingsCardView: View {
        @Binding var notificationsEnabled: Bool
        @Binding var darkModeEnabled: Bool
        @Binding var soundEffectsEnabled: Bool
        let onLogout: () -> Void
        
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

// MARK: - Analytics Preview Card
struct AnalyticsPreviewCard: View {
    @ObservedObject var analyticsManager: AnalyticsManager
    let onShowDashboard: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("📊 Analíticas Avanzadas")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Descubre insights detallados de tu progreso")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Button(action: onShowDashboard) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                        .font(.title3)
                }
            }
            
            // Mini preview de estadísticas
            if let userAnalytics = analyticsManager.userAnalytics {
                HStack(spacing: 20) {
                    MiniStatView(
                        title: "Velocidad",
                        value: "\(Int(userAnalytics.averageReadingSpeed)) PPM",
                        icon: "speedometer"
                    )
                    
                    MiniStatView(
                        title: "Precisión",
                        value: "\(Int(userAnalytics.averageAccuracy * 100))%",
                        icon: "target"
                    )
                    
                    MiniStatView(
                        title: "Ranking",
                        value: "#\(userAnalytics.globalRank)",
                        icon: "trophy"
                    )
                }
            } else {
                HStack {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 40)
                    }
                }
                .redacted(reason: .placeholder)
            }
            
            Button(action: onShowDashboard) {
                HStack {
                    Text("Ver Dashboard Completo")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Image(systemName: "arrow.right")
                        .font(.caption)
                }
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.2))
                )
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .onAppear {
            analyticsManager.refreshAnalytics()
        }
    }
}

struct MiniStatView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
}

    // Extension para añadir métodos a Color para que sea codificable
    extension Color {
        // Estas funciones ayudan a codificar/decodificar el color
        func toData() -> Data? {
            let uiColor = UIColor(self)
            return try? NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
        }
        
        static func fromData(_ data: Data) -> Color {
            let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) ?? UIColor.blue
            return Color(uiColor!)
        }
    }

    // Vista previa
    struct ProfileView_Previews: PreviewProvider {
        static var previews: some View {
            ProfileView(xpManager: XPManager())
        }
    }
