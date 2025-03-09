//
//  ProgressHeader.swift
//  worldbrain
//
//  Created by Daniel on 20/01/2025.
//

import SwiftUI
import AVFoundation

struct ProgressHeader: View {
    let progress: Double
    
    var body: some View {
        VStack {
            ProgressView(value: progress)
            Text("\(Int(progress * 100))% completado")
                .font(.caption)
        }
        .padding()
    }
}
