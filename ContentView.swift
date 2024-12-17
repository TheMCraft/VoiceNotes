import SwiftUI

struct ContentView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    private let textToSpeechManager = TextToSpeechManager()
    
    @AppStorage("savedNotes") private var savedArray: String = "[]"
    @State private var array: [String] = []
    @State private var newItem = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Speech to Text")
                .font(.largeTitle)
                .bold()
            
            Text(speechRecognizer.recognizedText)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 200)
                .border(Color.gray, width: 1)
                .cornerRadius(10)
            
            Button(action: {
                if speechRecognizer.isRecording {
                    speechRecognizer.stopRecording()
                } else {
                    speechRecognizer.requestAuthorization()
                    speechRecognizer.startRecording()
                    speechRecognizer.recognizedText = ""
                }
            }) {
                Text(speechRecognizer.isRecording ? "Stop Recording" : "Start Recording")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(speechRecognizer.isRecording ? Color.red : Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            
            Button(action: {
                textToSpeechManager.printAvailableVoices()
                textToSpeechManager.speak(text: speechRecognizer.recognizedText, voiceIdentifier: "com.apple.ttsbundle.siri_male_de-DE_compact")
            }) {
                Text("Read Aloud")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
    
    private func saveNotes() {
            if let data = try? JSONEncoder().encode(array),
               let jsonString = String(data: data, encoding: .utf8) {
                savedArray = jsonString
            }
        }

        private func loadNotes() {
            if let data = savedArray.data(using: .utf8),
               let loadedArray = try? JSONDecoder().decode([String].self, from: data) {
                array = loadedArray
            }
        }
}

#Preview {
    ContentView()
}
