//
//  ControlPanel.swift
//  worldbrain
//
//  Created by Daniel on 20/01/2025.
//

import SwiftUI
import AVFoundation

struct ControlPanel: View {
    @Binding var isReading: Bool
    let onStart: () -> Void
    let onPause: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            Button(action: {
                if isReading {
                    onPause()
                } else {
                    onStart()
                }
            }) {
                Image(systemName: isReading ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 44))
            }
        }
        .padding()
    }
}
