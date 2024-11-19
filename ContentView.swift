import SwiftUI
import Speech

struct ContentView: View {
    @State private var recognizedText = ""
    @State private var isRecording = false
    private let speechRecognizer = SFSpeechRecognizer()
    private let audioEngine = AVAudioEngine()

    var body: some View {
        VStack {
            Button(isRecording ? "Stop" : "Aufnahme") {
                isRecording ? stopRecording() : startRecording()
            }
            Text(recognizedText)
        }
    }

    func startRecording() {
        let request = SFSpeechAudioBufferRecognitionRequest()
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: audioEngine.inputNode.inputFormat(forBus: 0)) { buffer, _ in
            request.append(buffer)
        }
        try? audioEngine.start()
        speechRecognizer?.recognitionTask(with: request) { result, _ in
            self.recognizedText = result?.bestTranscription.formattedString ?? ""
        }
        isRecording = true
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        isRecording = false
    }
}
