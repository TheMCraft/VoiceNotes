import SwiftUI
import AVFAudio

struct ContentView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    private let textToSpeechManager = TextToSpeechManager()
    @State var player: AVAudioPlayer?
    
    @AppStorage("savedNotes") private var savedArray: String = "[]"
    @State private var array: [String] = []
    @State private var newItem = ""
    @State private var isSpeaking = false
    @State private var speakIndex: Int = 0
    @State private var message = "wische"
    @State private var tapCount: Int = 0
    
    private let bundleIdentifier: String = "com.apple.ttsbundle.siri_male_de-DE_compact"

    
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
            
            List(array, id: \.self) { item in
                Text(item)
            }
        }
        .onAppear {
            loadNotes()
        }
        Text(message + String(isSpeaking))
            .font(.title)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        let horizontal = value.translation.width
                        let vertical = value.translation.height
                                            
                        if abs(horizontal) > abs(vertical) {
                            if horizontal > 0 {
                                if speakIndex >= array.count {
                                    speakIndex = 0
                                }
                                textToSpeechManager.speak(text: getMessage(numberize: true), voiceIdentifier: bundleIdentifier)
                                speakIndex += 1
                            } else {
                                if speakIndex == 0 {
                                    speakIndex = array.count - 1
                                }
                                speakIndex -= 1
                                textToSpeechManager.speak(text: getMessage(numberize: false), voiceIdentifier: bundleIdentifier)
                                speakIndex += 1
                            }
                        } else {
                            if vertical > 0 {
                                message = "Wisch nach unten"
                            } else {
                                if (tapCount > 0) {
                                    array.remove(at: tapCount - 1)
                                    tapCount = 0
                                    saveNotes()
                                }
                            }
                        }
                        tapCount = 0
                    }
            )
            .simultaneousGesture(
                TapGesture(count: 1)
                    .onEnded {
                        if tapCount >= array.count {
                            tapCount = 0
                        }
                        textToSpeechManager.speak(text: String(tapCount + 1), voiceIdentifier: bundleIdentifier)
                        tapCount += 1
                    }
            )
            
            Spacer()
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
    private func getMessage(numberize: Bool) -> String {
        return (numberize ? String(speakIndex + 1) + ". " : "") + array[speakIndex]
    }
    
    func playBingSound() {
        AudioServicesPlaySystemSound(1052)
    }
}

#Preview {
    ContentView()
}
