//
//  StageLessonsView.swift
//  worldbrain
//
//  Created by Daniel on 20/01/2025.
//
import SwiftUI
import AVFoundation

struct StageLessonsView: View {
    let stage: Stage
    let stageIndex: Int
    @ObservedObject var stageManager: StageManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(stage.name)
                .font(.title2)
                .padding(.horizontal)
            
            Text(stage.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(Array(stage.lessons.enumerated()), id: \.element.id) { index, lesson in
                        NavigationLink {
                            if !lesson.isLocked {
                                LessonView(
                                    lesson: lesson,
                                    stageManager: stageManager,
                                    stageIndex: stageIndex
                                )
                            }
                        } label: {
                            LessonCard(lesson: lesson, number: index + 1)
                        }
                        .disabled(lesson.isLocked)
                    }
                }
                .padding()
            }
        }
    }
}
