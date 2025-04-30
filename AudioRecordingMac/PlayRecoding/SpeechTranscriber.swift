//
//  SpeechTranscriber.swift
//  AudioRecordingMac
//
//  Created by Mohar on 30/04/25.
//

import Foundation
import Speech

class SpeechTranscriber: ObservableObject {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionTask: SFSpeechRecognitionTask?
    private let request = SFSpeechURLRecognitionRequest(url: URL(fileURLWithPath: ""))

    @Published var transcribedText: String = ""

    func transcribeAudio(from url: URL) {
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            SFSpeechRecognizer.requestAuthorization { authStatus in
                if authStatus == .authorized {
                    self.transcribeAudio(from: url)
                }
            }
            return
        }

        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false

        recognitionTask = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            DispatchQueue.main.async {
                if let result = result {
                    self?.transcribedText = result.bestTranscription.formattedString
                } else if let error = error {
                    self?.transcribedText = "Transcription error: \(error.localizedDescription)"
                }
            }
        }
    }

    func cancelTranscription() {
        recognitionTask?.cancel()
        recognitionTask = nil
    }
}
