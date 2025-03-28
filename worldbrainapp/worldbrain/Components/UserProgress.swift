import Foundation
import Combine

class UserProgress: ObservableObject {
    // Propiedades principales de progreso
    @Published var lessonsCompleted: Int = 0
    @Published var xp: Int = 0
    @Published var level: Int = 1
    @Published var xpForNextLevel: Int = 1000
    @Published var dailyStreak: Int = 0
    
    // Nuevas propiedades para seguimiento de etapas
    @Published var completedStages: [Int] = []
    @Published var highestUnlockedStageIndex: Int = 0
    @Published var lastCompletedLessonId: UUID?
    
    // Referencia al StageManager (opcional, puede ser nil)
    private weak var stageManager: StageManager?
    
    // Fecha de la última actividad
    private var lastActivityDate: Date?
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadSavedProgress()
        print("📊 UserProgress inicializado - XP: \(xp), Nivel: \(level)")
    }
    
    // Conectar con StageManager para sincronización
    func connectStageManager(_ manager: StageManager) {
        self.stageManager = manager
        print("🔄 UserProgress conectado con StageManager")
        syncProgressWithStageManager()
    }
    
    // Calcular el progreso como porcentaje para mostrar en barras de progreso
    var progress: Double {
        return Double(xp) / Double(xpForNextLevel)
    }
    
    // Completar una lección y actualizar el progreso
    func completeLesson(xpGained: Int, lessonId: UUID? = nil, stageIndex: Int? = nil) {
        print("🎮 Completando lección - XP ganado: \(xpGained)")
        
        // Incrementar contador y XP
        lessonsCompleted += 1
        xp += xpGained
        lastCompletedLessonId = lessonId
        
        // Actualizar fecha de última actividad
        lastActivityDate = Date()
        
        // Verificar si subimos de nivel
        if xp >= xpForNextLevel {
            levelUp()
        }
        
        // Si tenemos stage índice, actualizar etapas completadas
        if let stageIndex = stageIndex {
            updateStageProgress(stageIndex)
        }
        
        // Sincronizar con StageManager si está disponible y tenemos el ID de lección
        if let stageManager = stageManager, let lessonId = lessonId, let stageIndex = stageIndex {
            print("🔄 Sincronizando compleción con StageManager - Etapa: \(stageIndex), ID: \(lessonId)")
            stageManager.completeLesson(stageIndex: stageIndex, lessonId: lessonId)
        }
        
        // Guardar progreso
        saveProgress()
        
        // Notificar cambios para actualización de UI
        objectWillChange.send()
    }
    
    // Subir de nivel y actualizar requisitos
    private func levelUp() {
        level += 1
        xp = xp - xpForNextLevel
        
        // Cada nivel requiere 20% más XP que el anterior
        xpForNextLevel = Int(Double(xpForNextLevel) * 1.2)
        
        print("🏆 ¡Nivel subido! Ahora nivel \(level)")
    }
    
    // Actualizar progreso de etapas
    private func updateStageProgress(_ stageIndex: Int) {
        if !completedStages.contains(stageIndex) && isStageCompleted(stageIndex) {
            completedStages.append(stageIndex)
            completedStages.sort()
            print("🏆 Etapa \(stageIndex) completada")
            
            // Actualizar etapa más alta desbloqueada
            if stageIndex + 1 > highestUnlockedStageIndex {
                highestUnlockedStageIndex = stageIndex + 1
                print("🔓 Nueva etapa desbloqueada: \(highestUnlockedStageIndex)")
            }
        }
    }
    
    // Verificar si una etapa está completada
    private func isStageCompleted(_ stageIndex: Int) -> Bool {
        // Esta verificación debería idealmente consultar al StageManager
        // Por ahora, usamos una implementación simplificada
        guard let stageManager = stageManager else { return false }
        
        if stageIndex < stageManager.stages.count {
            let requiredLessons = stageManager.stages[stageIndex].requiredLessons
            let completedCount = stageManager.stages[stageIndex].completedLessonsCount
            return completedCount >= requiredLessons
        }
        return false
    }
    
    // Sincronizar con StageManager
    private func syncProgressWithStageManager() {
        guard let stageManager = stageManager else { return }
        
        // Contar lecciones completadas
        var totalCompletedLessons = 0
        for stage in stageManager.stages {
            let stageCompletedLessons = stage.lessons.filter { $0.isCompleted }.count
            totalCompletedLessons += stageCompletedLessons
        }
        
        // Actualizar solo si hay discrepancia
        if totalCompletedLessons != lessonsCompleted {
            print("🔄 Sincronizando conteo de lecciones: \(lessonsCompleted) -> \(totalCompletedLessons)")
            lessonsCompleted = totalCompletedLessons
        }
        
        // Otros procesos de sincronización si son necesarios
    }
    
    // Guardar el progreso actual
    private func saveProgress() {
        userDefaults.set(lessonsCompleted, forKey: "lessonsCompleted")
        userDefaults.set(xp, forKey: "userXP")
        userDefaults.set(level, forKey: "userLevel")
        userDefaults.set(xpForNextLevel, forKey: "xpForNextLevel")
        userDefaults.set(dailyStreak, forKey: "dailyStreak")
        userDefaults.set(completedStages, forKey: "completedStages")
        userDefaults.set(highestUnlockedStageIndex, forKey: "highestUnlockedStage")
        userDefaults.set(lastActivityDate?.timeIntervalSince1970, forKey: "lastActivityDate")
        
        if let lastLessonId = lastCompletedLessonId {
            userDefaults.set(lastLessonId.uuidString, forKey: "lastCompletedLessonId")
        }
        
        userDefaults.synchronize()
        print("💾 Progreso guardado")
    }
    
    // Cargar el progreso guardado
    private func loadSavedProgress() {
        lessonsCompleted = userDefaults.integer(forKey: "lessonsCompleted")
        xp = userDefaults.integer(forKey: "userXP")
        level = userDefaults.integer(forKey: "userLevel")
        if level == 0 { level = 1 } // Garantizar que el nivel nunca sea menor que 1
        
        xpForNextLevel = userDefaults.integer(forKey: "xpForNextLevel")
        if xpForNextLevel == 0 { xpForNextLevel = 1000 } // Valor predeterminado
        
        dailyStreak = userDefaults.integer(forKey: "dailyStreak")
        completedStages = userDefaults.array(forKey: "completedStages") as? [Int] ?? []
        highestUnlockedStageIndex = userDefaults.integer(forKey: "highestUnlockedStage")
        
        if let lastActivityTimeInterval = userDefaults.object(forKey: "lastActivityDate") as? TimeInterval {
            lastActivityDate = Date(timeIntervalSince1970: lastActivityTimeInterval)
        }
        
        if let lastLessonIdString = userDefaults.string(forKey: "lastCompletedLessonId") {
            lastCompletedLessonId = UUID(uuidString: lastLessonIdString)
        }
        
        print("📋 Progreso cargado - Lecciones: \(lessonsCompleted), Nivel: \(level), XP: \(xp)/\(xpForNextLevel)")
    }
    
    // Verificar y actualizar racha diaria
    func checkDailyStreak() {
        guard let lastActivity = lastActivityDate else {
            // Primera actividad, iniciar racha
            dailyStreak = 1
            lastActivityDate = Date()
            saveProgress()
            return
        }
        
        // Obtener componentes de fecha
        let calendar = Calendar.current
        let now = Date()
        
        // Verificar si es un nuevo día
        if !calendar.isDate(lastActivity, inSameDayAs: now) {
            // Verificar si no ha pasado más de un día
            let components = calendar.dateComponents([.day], from: lastActivity, to: now)
            if let days = components.day, days == 1 {
                // Día consecutivo
                dailyStreak += 1
                print("🔥 Racha diaria aumentada: \(dailyStreak) días")
            } else if let days = components.day, days > 1 {
                // Se perdió la racha
                dailyStreak = 1
                print("⚠️ Racha diaria reiniciada")
            }
            
            lastActivityDate = now
            saveProgress()
        }
    }
    
    // Añadir XP directamente sin completar lección
    func addXP(_ amount: Int) {
        if amount <= 0 { return }
        
        print("💎 Añadiendo \(amount) XP")
        xp += amount
        
        // Verificar si subimos de nivel
        if xp >= xpForNextLevel {
            levelUp()
        }
        
        // Actualizar fecha de actividad
        lastActivityDate = Date()
        saveProgress()
        
        // Notificar cambios
        objectWillChange.send()
    }
}
