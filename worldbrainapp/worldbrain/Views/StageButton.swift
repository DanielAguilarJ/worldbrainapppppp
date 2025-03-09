//
//  StageButton.swift
//  worldbrain
//
//  Created by Daniel on 20/01/2025.
//
import SwiftUI
import AVFoundation

struct StageButton: View {
    let stage: Stage
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Circle()
                    .fill(stage.isLocked ? Color.gray : stage.color)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Group {
                            if stage.isLocked {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.white)
                            } else {
                                Text("\(stage.completedLessonsCount)/\(stage.requiredLessons)")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .bold()
                            }
                        }
                    )
                
                Text(stage.name)
                    .font(.caption)
                    .foregroundColor(stage.isLocked ? .gray : .primary)
            }
        }
        .disabled(stage.isLocked)
    }
}
