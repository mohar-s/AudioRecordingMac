//
//  NewRecordingVM.swift
//  AudioRecordingMac
//
//  Created by Mohar on 23/04/25.
//

import AVFoundation
import Foundation

class NewRecordingVM: ObservableObject {

    private var selectedItem: Recording? = nil
    @Published var isRecording = false
    @Published var recordingTime: TimeInterval = 0

    private var timer: Timer?

    enum RecordingState {
        case recording, paused, stopped
    }

    private var engine: AVAudioEngine!
    private var mixerNode: AVAudioMixerNode!
    private var state: RecordingState = .stopped

    var isPaused: Bool {
        state == .paused
    }

    init() {
        
    }
    
    func initializeRecording()  {
        setupEngine()
    }
    
    func setupItem(title: String)  {
        self.selectedItem = SharedUtils.shared.getLatestRecoding()
    }

    fileprivate func setupEngine() {
        engine = AVAudioEngine()
        mixerNode = AVAudioMixerNode()

        // Set volume to 0 to avoid audio feedback while recording.
        mixerNode.volume = 0

        engine.attach(mixerNode)

        makeConnections()

        // Prepare the engine in advance, in order for the system to allocate the necessary resources.
        engine.prepare()
    }

    fileprivate func makeConnections() {
        let inputNode = engine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        engine.connect(inputNode, to: mixerNode, format: inputFormat)

        let mainMixerNode = engine.mainMixerNode
        let mixerFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32, sampleRate: inputFormat.sampleRate,
            channels: 1, interleaved: false)
        engine.connect(mixerNode, to: mainMixerNode, format: mixerFormat)
    }

    func startRecording() {
        
        self.selectedItem = SharedUtils.shared.getLatestRecoding()
        
        do {
            let tapNode: AVAudioNode = mixerNode
            let format = tapNode.outputFormat(forBus: 0)
            
            // AVAudioFile uses the Core Audio Format (CAF) to write to disk.
            // So we're using the caf file extension.
            //documentURL.appendingPathComponent("recording.caf")
            
            if var item = selectedItem {
                let filePath = FilePath.shared.getFullFilePath(fileName: item.filePath)
                
                
                print("Audio file 1 \(filePath)")
                let file = try AVAudioFile(
                    forWriting: filePath, settings: format.settings)
                print("Audio file \(filePath)")
                tapNode.installTap(
                    onBus: 0, bufferSize: 4096, format: format,
                    block: {
                        (buffer, time) in
                        try? file.write(from: buffer)
                        print("Writing file")
                    })
                
                try engine.start()
                state = .recording
                isRecording = true
                startTimer()
                print("Audio recording Started")
            }
            
        } catch {
            print("StartRecording Found Error : \(error)")
        }
    }

    func resumeRecording() {
        do {
            try engine.start()
            state = .recording
            isRecording = true
            resumeTimer()
        } catch {
            print("ResumeRecording Found Error : \(error)")
        }
    }

    func pauseRecording() {
        engine.pause()
        state = .paused
        isRecording = false
        stopPauseTimer()
    }

    func stopRecording() {
        // Remove existing taps on nodes
        mixerNode.removeTap(onBus: 0)

        engine.stop()
        state = .stopped
        isRecording = false
        stopPauseTimer()
        CoreDataManager.shared.saveContext()
    }

    private func startTimer() {
        recordingTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.recordingTime += 1
        }
    }

    private func resumeTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.recordingTime += 1
        }
    }

    private func stopPauseTimer() {
        timer?.invalidate()
        timer = nil
    }

}
