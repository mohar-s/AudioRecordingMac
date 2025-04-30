//
//  AudioVisualizerManager.swift
//  AudioRecordingMac
//
//  Created by Mohar on 30/04/25.
//

import AVFoundation
import Combine
import Foundation


class AudioVisualizerManager: ObservableObject {
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var audioFile: AVAudioFile?
    private var audioLength: TimeInterval = 0
    private var startTime: AVAudioTime?
    private var displayLink: CADisplayLink?

    @Published var amplitudes: [Float] = Array(repeating: 0.0, count: 20)
    @Published var progress: Double = 0.0 // value from 0.0 to 1.0
    
    @Published var isplaying: Bool = false
    
    var fileUlr: URL?

    func setupWithFile(filename: String) {
        guard let formattedUrl = filename.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        print("formattedUrl \(formattedUrl)")
        
         let url = FilePath.shared.getFullFilePath(fileName: formattedUrl)
        print("ready to play file name \(filename) path \(url)")
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: url.path()) else {
        print("Audio file not found.")
        return
    }
        
        self.fileUlr = url
    }
    
    func startPlaying() {
        if let url = fileUlr {
            do {
                audioFile = try AVAudioFile(forReading: url)
                if let file = audioFile {
                    let sampleRate = file.processingFormat.sampleRate
                    let totalFrames = file.length
                    audioLength = Double(totalFrames) / sampleRate
                }
                
                engine.attach(playerNode)
                engine.connect(playerNode, to: engine.mainMixerNode, format: audioFile?.processingFormat)
                
                engine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: audioFile?.processingFormat) { [weak self] buffer, _ in
                    self?.updateAmplitudes(buffer: buffer)
                }
                
                try engine.start()
                if let audioFile = audioFile {
                    playerNode.scheduleFile(audioFile, at: nil)
                    playerNode.play()
                    startTime = playerNode.lastRenderTime
                    
                    startProgressTimer()
                }
                
            } catch {
                print("Playback error: \(error)")
            }
        } else {
            print("File not found")
        }
    }

    func stopPlaying() {
        playerNode.stop()
        engine.stop()
        engine.mainMixerNode.removeTap(onBus: 0)
        stopProgressTimer()
    }

    private func updateAmplitudes(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }

        let frameLength = Int(buffer.frameLength)
        let stride = max(frameLength / amplitudes.count, 1)

        var newAmplitudes: [Float] = []

        for i in 0..<amplitudes.count {
            let start = i * stride
            let end = min(start + stride, frameLength)
            let count = end - start
            if count > 0 {
                let segment = UnsafeBufferPointer(start: channelData + start, count: count)
                let rms = sqrt(segment.map { $0 * $0 }.reduce(0, +) / Float(count))
                newAmplitudes.append(min(max(rms * 20, 0), 1))
            } else {
                newAmplitudes.append(0)
            }
        }

        DispatchQueue.main.async {
            self.amplitudes = newAmplitudes
        }
    }

//    private func startProgressTimer() {
//        stopProgressTimer()
//        displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
//        displayLink?.add(to: .main, forMode: .default)
//    }
    
    private var timer: Timer?

    private func startProgressTimer() {
        isplaying = true
        stopProgressTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }

    private func stopProgressTimer() {
        isplaying = false
        timer?.invalidate()
        timer = nil
    }

    @objc private func updateProgress() {
        guard let nodeTime = playerNode.lastRenderTime,
              let playerTime = playerNode.playerTime(forNodeTime: nodeTime),
              let audioFile = audioFile else {
            return
        }

        let currentTime = Double(playerTime.sampleTime) / playerTime.sampleRate
        DispatchQueue.main.async {
            self.progress = currentTime / self.audioLength
            print("self.progress \(self.progress)")
            if self.progress <= 1 {
                self.isplaying = true
            } else {
                self.isplaying = false
                self.stopPlaying()
            }
        }
    }

    func seek(to newValue: Double) {
        guard let audioFile = audioFile else { return }

        stopPlaying()
        do {
            let framePosition = AVAudioFramePosition(Double(audioFile.length) * newValue)
            engine.reset()
            try engine.start()

            playerNode.scheduleSegment(audioFile, startingFrame: framePosition, frameCount: AVAudioFrameCount(audioFile.length - framePosition), at: nil)
            playerNode.play()
            startProgressTimer()
        } catch {
            print("Seek error: \(error)")
        }
    }
}
