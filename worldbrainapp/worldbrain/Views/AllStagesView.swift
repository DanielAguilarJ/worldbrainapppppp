//
//  AllStagesView.swift
//  worldbrain
//
//  Created by Daniel on 20/01/2025.
//
import SwiftUI
import AVFoundation

struct AllStagesView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var stageManager: StageManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(Array(stageManager.stages.enumerated()), id: \.element.id) { index, stage in
                        StageCard(stage: stage)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Etapas de Aprendizaje")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cerrar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
