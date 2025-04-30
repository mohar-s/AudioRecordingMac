//
//  EqualizerVisualizerView.swift
//  AudioRecordingMac
//
//  Created by Mohar on 30/04/25.
//

import SwiftUI

struct EqualizerVisualizerView: View {
    @StateObject private var visualizer = AudioVisualizerManager()
    @StateObject private var transcriber = SpeechTranscriber()
    
    @Binding var path: NavigationPath
    var fileName: String
    
    var body: some View {
            VStack(spacing: 20) {
                HStack {
                    Button("< Back") {
                        visualizer.stopPlaying()
                        transcriber.cancelTranscription()
                        path.append(Page.recording)
                    }
                    Spacer()
                    if let selectedFile = SharedUtils.shared.selectedRecoding {
                        Text(selectedFile.name).font(.largeTitle).bold()
                    }
                    Spacer()
                }
                
                HStack(alignment: .bottom, spacing: 3) {
                    ForEach(visualizer.amplitudes.indices, id: \.self) { i in
                        EqualizerBarView(value: visualizer.amplitudes[i])
                    }
                }
                .frame(height: 120)

                Slider(value: Binding(
                    get: { visualizer.progress },
                    set: { newVal in
                        visualizer.seek(to: newVal)
                    }
                ), in: 0...1)
                .padding([.leading, .trailing])
                

                HStack {
                    if !visualizer.isplaying {
                        Button("Play") {
                            visualizer.startPlaying()
                            if let url = visualizer.fileUlr {
                                transcriber.transcribeAudio(from: url)
                            }
                        }.frame(width: 100)
                    }
                    else {
                        Button("Stop") {
                            visualizer.stopPlaying()
                            transcriber.cancelTranscription()
                        }.frame(width: 100)
                    }
                }
                TextEditor(text: $transcriber.transcribedText)
                                .frame(height: 100)
                                .border(Color.gray)
            }
            .frame(width: 300)
            .padding()
            .onAppear {
                if let selectedFile = SharedUtils.shared.selectedRecoding {
                    visualizer.setupWithFile(filename: selectedFile.filePath)
                }
            }
            .navigationBarBackButtonHidden(false)
        }
        
}

struct EqualizerBarView: View {
    var value: Float

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.blue)
            .frame(width: 5, height: CGFloat(100 * value))
    }
}
