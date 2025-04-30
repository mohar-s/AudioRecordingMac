//
//  NewRecordingView.swift
//  AudioRecordingMac
//
//  Created by Mohar on 23/04/25.
//



import SwiftUI

struct NewRecordingView: View {
    @ObservedObject var viewModel = NewRecordingVM()
    var title: String
    
    @Binding var path: NavigationPath
    
       var body: some View {
           VStack(spacing: 20) {
               Text(viewModel.isRecording ? "Recording..." : "Tap to Record")
                   .font(.title)
                   .foregroundColor(viewModel.isRecording ? .red : .primary)
               
               Text("Duration: \(Int(viewModel.recordingTime))s")
                   .monospacedDigit()
               HStack {
                   
                   if viewModel.isRecording || viewModel.isPaused {
                       Button(action: {
                           viewModel.isPaused ? viewModel.resumeRecording() : viewModel.pauseRecording()
                       }) {
                           Text(viewModel.isPaused ? "Resume" :"Pause")
                               .padding()
                               .background(viewModel.isPaused ? Color.red : Color.blue)
                               .foregroundColor(.white)
                               .cornerRadius(10)
                       }
                   }
                   
                   Button(action: {
                       if viewModel.isRecording {
                           viewModel.stopRecording()
                           self.path.removeLast()
                       }
                       else {
                           viewModel.startRecording()
                       }
                   }) {
                       Text(viewModel.isRecording ? "Stop Recording" : "Start Recording")
                           .padding()
                           .background(viewModel.isRecording ? Color.red : Color.blue)
                           .foregroundColor(.white)
                           .cornerRadius(10)
                   }
                   
               }
           }
           .frame(width: 400, height: 300)
           .padding()
           .onAppear {
               viewModel.initializeRecording()
               viewModel.setupItem(title: self.title)
           }
       }
        
}


//#Preview {
//    NewRecordingView(title: "FileName")
//}
