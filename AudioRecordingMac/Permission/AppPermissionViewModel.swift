
//
//  Untitled.swift
//  AudioRecordingMac
//
//  Created by Mohar on 29/04/25.
//

import AVFoundation
import Foundation

class AppPermissionViewModel {
    
    private var engine: AVAudioEngine!
    private var mixerNode: AVAudioMixerNode!
    
    var isPermissionAllowed: Bool {
        return true
    }
    
    func requestTheVoiceRecordingPermission()  {
        setupEngine()
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
    
}
