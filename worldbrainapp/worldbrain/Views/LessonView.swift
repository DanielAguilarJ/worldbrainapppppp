//
//  LessonView.swift
//  worldbrain
//
//  Created by Daniel on 20/01/2025.
//
import SwiftUI
import AVFoundation

struct LessonView: View {
    let lesson: Lesson
    @ObservedObject var stageManager: StageManager
    let stageIndex: Int
    @State private var showingQuiz = false
    @State private var timeRemaining: Int
    @State private var isReading = false
    @State private var scrollOffset: CGFloat = 0
    @State private var totalScrollLength: CGFloat = 1000
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(lesson: Lesson, stageManager: StageManager, stageIndex: Int) {
        self.lesson = lesson
        self.stageManager = stageManager
        self.stageIndex = stageIndex
        _timeRemaining = State(initialValue: lesson.timeLimit)
    }
    
    var body: some View {
        VStack {
            TimerView(timeRemaining: timeRemaining)
            
            ScrollView {
                Text(lesson.content)
                    .padding()
                    .offset(y: -scrollOffset)
            }
            .frame(maxHeight: .infinity)
            
            ControlPanel(
                isReading: $isReading,
                onStart: startReading,
                onPause: pauseReading
            )
        }
        .navigationTitle(lesson.title)
        .onReceive(timer) { _ in
            if isReading {
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    showingQuiz = true
                    isReading = false
                }
            }
        }
        .sheet(isPresented: $showingQuiz) {
            QuizView(
                questions: lesson.questions,
                onQuizCompleted: {
                    stageManager.completeLesson(stageIndex: stageIndex, lessonId: lesson.id)
                }
            )
        }
    }
    
    private func startReading() {
        isReading = true
        animateScroll()
    }
    
    private func pauseReading() {
        isReading = false
        withAnimation(.linear(duration: 0)) {
        }
    }
    
    private func restartReading() {
        let progress = scrollOffset / totalScrollLength
        let remainingLength = totalScrollLength * (1 - progress)
        let adjustedDuration = Double(timeRemaining)
        withAnimation(.linear(duration: adjustedDuration)) {
            scrollOffset = totalScrollLength
        }
    }
    
    private func animateScroll() {
        withAnimation(.linear(duration: Double(timeRemaining))) {
            scrollOffset = totalScrollLength
        }
    }
}
