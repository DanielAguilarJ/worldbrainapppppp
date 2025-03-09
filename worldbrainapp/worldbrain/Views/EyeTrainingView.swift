//
//  EyeTrainingView.swift
//  worldbrainapp
//
//  Created by Daniel on 20/01/2025.
//


import SwiftUI

struct EyeTrainingView: View {
    let exercise: EyeExercise
    @State private var isExercising = false
    @State private var timeRemaining: Int
    @State private var dotPosition = CGPoint(x: 0, y: 0)
    
    init(exercise: EyeExercise) {
        self.exercise = exercise
        _timeRemaining = State(initialValue: exercise.duration)
    }
    
    var body: some View {
        VStack {
            Text("\(timeRemaining) segundos")
                .font(.title)
                .padding()
            
            ZStack {
                switch exercise.type {
                case .dotTracking:
                    DotTrackingExercise(dotPosition: $dotPosition)
                case .horizontalMovement:
                    HorizontalMovementExercise()
                case .verticalMovement:
                    VerticalMovementExercise()
                case .circularMovement:
                    CircularMovementExercise()
                case .peripheralVision:
                    PeripheralVisionExercise()
                case .focusChange:
                    FocusChangeExercise()
                case .palmingExercise:
                    PalmingExerciseView()
                case .diagonalMovement:
                    DiagonalMovementExercise()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 300)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            
            Text(exercise.instructions)
                .padding()
                .multilineTextAlignment(.center)
            
            Button(action: {
                if isExercising {
                    pauseExercise()
                } else {
                    startExercise()
                }
            }) {
                Text(isExercising ? "Pausar" : "Comenzar")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    private func startExercise() {
        isExercising = true
    }
    
    private func pauseExercise() {
        isExercising = false
    }
}