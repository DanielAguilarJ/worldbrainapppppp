// MARK: - LeagueView.swift
import SwiftUI

struct LeagueView: View {
    // Asegúrate de que sólo exista una definición de LeaderboardManager en tu proyecto
    @StateObject private var leaderboardManager: LeaderboardManager = LeaderboardManager()
    
    // Controla si queremos rankear por XP semanal o XP total
    @State private var selection: RankingTipo = .semanal
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Tipo de Ranking", selection: $selection) {
                    Text("Semanal").tag(RankingTipo.semanal)
                    Text("Total").tag(RankingTipo.total)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Tabla de posiciones
                List(sortedUsers.indices, id: \.self) { index in
                    let user = sortedUsers[index]
                    
                    HStack {
                        Text("\(index + 1). \(user.nombre)")
                            .font(.headline)
                        
                        Spacer()
                        
                        if selection == .semanal {
                            Text("\(user.xpSemanal) XP/sem")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        } else {
                            Text("\(user.xpTotal) XP total")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .listStyle(.inset)
                .animation(.easeInOut, value: sortedUsers)
                
                Spacer()
            }
            .navigationTitle("Liga")
            .onAppear {
                // Orden inicial (por semanal, p.ej.)
                leaderboardManager.sortByWeeklyXP()
            }
            .onChange(of: selection) { newValue in
                switch newValue {
                case .semanal:
                    leaderboardManager.sortByWeeklyXP()
                case .total:
                    leaderboardManager.sortByTotalXP()
                }
            }
        }
    }
    
    private var sortedUsers: [LeaderboardUser] {
        // Devolvemos el array ya ordenado por el manager
        leaderboardManager.usuarios
    }
}

// MARK: - RankingTipo (enum)
enum RankingTipo {
    case semanal
    case total
}

