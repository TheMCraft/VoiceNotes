import SwiftUI
import AVFAudio

struct ContentView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    private let textToSpeechManager = TextToSpeechManager()
    var player: AVAudioPlayer?
    
    @AppStorage("savedNotes") private var savedArray: String = "[]"
    @State private var array: [String] = []
    @State private var newItem = ""
    @State private var isSpeaking = false
    @State private var speakIndex: Int = 0
    @State private var tapCount: Int = 0
    @State private var showInfo: Bool = false
    @State private var tutorialSpeaking: Bool = false
    @GestureState private var isDetectingLongPress: Bool = false
    
    private let bundleIdentifier: String = "com.apple.ttsbundle.siri_male_en-US_compact"
    
    
    var body: some View {
        VStack {
            Text("Swipe down for information").foregroundColor(.primary)
            Button("View Notes") {
                showInfo = !showInfo
            }
        }
        ZStack() {
            Rectangle()
                .fill(isSpeaking ? .green : .white)
                .onLongPressGesture(minimumDuration: 1.0, perform: {
                    playBingSound()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        speechRecognizer.requestAuthorization()
                        speechRecognizer.startRecording()
                        speechRecognizer.recognizedText = ""
                        isSpeaking = true
                    }
                }, onPressingChanged: {isPressing in
                    if (!isPressing && isSpeaking) {
                        speechRecognizer.stopRecording()
                        if !speechRecognizer.recognizedText.isEmpty {
                            array.append(speechRecognizer.recognizedText)
                            saveNotes()
                        }
                        isSpeaking = false
                    }
                })
                .gesture(
                    TapGesture(count: 1)
                        .onEnded {
                            if (array.count == 0) {
                                tutorial()
                                return
                            }
                            if tapCount >= array.count {
                                tapCount = 0
                            }
                            textToSpeechManager.speak(text: String(tapCount + 1), voiceIdentifier: bundleIdentifier)
                            tapCount += 1
                        }.simultaneously(with:
                                            DragGesture()
                            .onEnded { value in
                                if (array.count == 0) {
                                    tutorial()
                                    return
                                }
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
                                        tutorial()
                                    } else {
                                        if (tapCount > 0) {
                                            textToSpeechManager.speak(text: "Deleted note \(tapCount): \(array[tapCount - 1])", voiceIdentifier: bundleIdentifier)
                                            array.remove(at: tapCount - 1)
                                            tapCount = 0
                                            saveNotes()
                                        }
                                    }
                                }
                                tapCount = 0
                            }
                                        )
                )
                .onAppear {
                    loadNotes()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if (showInfo) {
                Rectangle()
                    .fill(.gray)
                    .cornerRadius(20)
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.8,
                           maxHeight: UIScreen.main.bounds.height * 0.8)
                    .padding(UIScreen.main.bounds.width * 0.1)
                    .overlay(
                        List(array, id: \.self) { item in
                            Text(item)
                        }
                        .padding()
                    )
            }
        }
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
    func tutorial() {
        if (tutorialSpeaking) {
            textToSpeechManager.stopSpeaking()
            tutorialSpeaking = false
        } else {
            tutorialSpeaking = true
            textToSpeechManager.speak(text: "Press and hold your finger in the middle of the screen to add a new note... swipe to the right to read out loud the next note... swipe left to repeat the last note... klick once or multiple times and swipe up to delete a specific note... swipe down to stop the narrator", voiceIdentifier: bundleIdentifier)
        }
    }
}

#Preview {
    ContentView()
}
