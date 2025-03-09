//
//  StageCard.swift
//  worldbrain
//
//  Created by Daniel on 20/01/2025.
//
import SwiftUI
import AVFoundation

struct StageCard: View {
    let stage: Stage
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Circle()
                    .fill(stage.isLocked ? Color.gray : stage.color)
                    .frame(width: 50, height: 50)
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
                
                VStack(alignment: .leading) {
                    Text(stage.name)
                        .font(.title3)
                        .bold()
                    Text(stage.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if stage.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            
            if !stage.isLocked {
                ProgressView(value: Double(stage.completedLessonsCount), total: Double(stage.requiredLessons))
                    .tint(stage.color)
                    .padding(.top, 5)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
        .opacity(stage.isLocked ? 0.7 : 1.0)
    }
}
