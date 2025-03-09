//
//  ProfileView.swift
//  worldbrainapp
//
//  Esta vista muestra el perfil del usuario (al estilo Duolingo) y se actualiza
//  automáticamente cuando se completan lecciones o ejercicios.
//  Asegúrate de tener en Assets una imagen llamada "profile_placeholder" o cámbiala por la que uses.
//  También define (o reemplaza) los colores "ProfileGradientStart" y "ProfileGradientEnd" según tu diseño.
//

import SwiftUI

struct ProfileView: View {
    // Se inyecta el objeto de progreso global; así, cualquier cambio se reflejará aquí.
    @EnvironmentObject var userProgress: UserProgress
    @State private var avatarImageName: String = "profile_placeholder"

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // CABECERA CON FONDO DEGRADADO
                    ZStack(alignment: .bottom) {
                        LinearGradient(
                            gradient: Gradient(colors: [Color("ProfileGradientStart"), Color("ProfileGradientEnd")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 300)
                        .ignoresSafeArea(edges: .top)
                        
                        // Información principal: avatar, nombre y datos
                        VStack(spacing: 16) {
                            Image(avatarImageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(Color.white, lineWidth: 4)
                                )
                                .shadow(radius: 10)
                            
                            // Puedes reemplazar "Mi Usuario" por el nombre real del usuario si lo tienes
                            Text("Mi Usuario")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            // Datos: Nivel, XP, Racha y Lecciones Completadas
                            HStack(spacing: 20) {
                                VStack {
                                    Text("Nivel")
                                        .font(.caption)
                                        .foregroundColor(Color.white.opacity(0.8))
                                    Text("\(userProgress.level)")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                VStack {
                                    Text("XP")
                                        .font(.caption)
                                        .foregroundColor(Color.white.opacity(0.8))
                                    Text("\(userProgress.xp)/\(userProgress.xpForNextLevel)")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                VStack {
                                    Text("Racha")
                                        .font(.caption)
                                        .foregroundColor(Color.white.opacity(0.8))
                                    Text("\(userProgress.dailyStreak) días")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                VStack {
                                    Text("Lecciones")
                                        .font(.caption)
                                        .foregroundColor(Color.white.opacity(0.8))
                                    Text("\(userProgress.lessonsCompleted)")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.bottom, 40)
                    }
                    
                    // BARRA DE PROGRESO AL SIGUIENTE NIVEL
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Progreso al siguiente nivel")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        ProgressView(value: userProgress.progress)
                            .accentColor(.green)
                            .progressViewStyle(LinearProgressViewStyle())
                        
                        Text("\(Int(userProgress.progress * 100))% completado")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    
                    // SECCIÓN DE LOGROS Y ESTADÍSTICAS
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Logros")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                AchievementView(iconName: "star.fill", title: "Estrella Dorada")
                                AchievementView(iconName: "flame.fill", title: "Racha 10 días")
                                AchievementView(iconName: "clock.fill", title: "Tiempo Inverso")
                            }
                            .padding(.horizontal)
                        }
                        
                        Text("Estadísticas")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack {
                            StatisticView(title: "Lecciones Completadas", value: "\(userProgress.lessonsCompleted)")
                            StatisticView(title: "Ejercicios", value: "15")
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                    
                    Spacer()
                }
            }
            .navigationBarTitle("Mi Perfil", displayMode: .inline)
        }
    }
}

// Vistas auxiliares

struct AchievementView: View {
    let iconName: String
    let title: String
    
    var body: some View {
        VStack {
            Image(systemName: iconName)
                .font(.system(size: 40))
                .foregroundColor(.yellow)
                .padding()
                .background(Color.yellow.opacity(0.2))
                .clipShape(Circle())
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .frame(width: 100)
    }
}

struct StatisticView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // Inyecta el objeto UserProgress para que la vista se actualice automáticamente
        ProfileView().environmentObject(UserProgress())
    }
}

