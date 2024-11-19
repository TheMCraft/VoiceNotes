import SwiftUI
import Speech

struct ContentView: View {
    @State var recognizedText = ""
    private let speechRecognizer = SFSpeechRecognizer()
    private let audioEngine = AVAudioEngine()

    var body: some View {
        VStack {
            Button("Aufnahme") {
                startRecording()
            }
            Text(recognizedText)
        }
    }

    func startRecording() {
        let request = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        audioEngine.prepare()
        try? audioEngine.start()
        speechRecognizer?.recognitionTask(with: request) { result, _ in
            if let result = result {
                recognizedText = result.bestTranscription.formattedString
            }
        }
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputNode.inputFormat(forBus: 0)) { buffer, _ in
            request.append(buffer)
        }
    }
}

#Preview {
    ContentView()
}
