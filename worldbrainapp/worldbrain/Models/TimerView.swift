//
//  TimerView.swift
//  worldbrain
//
//  Created by Daniel on 20/01/2025.
//
import SwiftUI
import AVFoundation

struct TimerView: View {
    let timeRemaining: Int
    
    var body: some View {
        Text("\(timeRemaining / 60):\(String(format: "%02d", timeRemaining % 60))")
            .font(.title)
            .padding()
    }
}
