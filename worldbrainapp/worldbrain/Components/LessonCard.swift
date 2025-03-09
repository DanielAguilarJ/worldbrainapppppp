//
//  LessonCard.swift
//  worldbrain
//
//  Created by Daniel on 20/01/2025.
//
import SwiftUI
import AVFoundation

struct LessonCard: View {
    let lesson: Lesson
    let number: Int
    
    var body: some View {
        HStack {
            Circle()
                .fill(lesson.isLocked ? Color.gray : (lesson.isCompleted ? Color.green : Color.blue))
                .frame(width: 40, height: 40)
                .overlay(
                    Group {
                        if lesson.isLocked {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.white)
                        } else if lesson.isCompleted {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                        } else {
                            Text("\(number)")
                                .foregroundColor(.white)
                                .bold()
                        }
                    }
                )
            
            VStack(alignment: .leading) {
                Text(lesson.title)
                    .font(.headline)
                Text(lesson.description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
        .opacity(lesson.isLocked ? 0.7 : 1.0)
    }
}
