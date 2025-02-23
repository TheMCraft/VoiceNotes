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
    @State private var tutorial: Bool = false
    @GestureState private var isDetectingLongPress: Bool = false
    
    private let bundleIdentifier: String = "com.apple.ttsbundle.siri_male_en-US_compact"
    
    
    var body: some View {
        ZStack() {
            Text("Swipe down for information").foregroundColor(.black)
            Rectangle()
                .font(.title)
                .onLongPressGesture(minimumDuration: 1.0, perform: {
                    playBingSound()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
                                        if (tapCount == 0) {
                                            return
                                        }
                                        if speakIndex == 0 {
                                            speakIndex = array.count - 1
                                        }
                                        speakIndex -= 1
                                        textToSpeechManager.speak(text: getMessage(numberize: false), voiceIdentifier: bundleIdentifier)
                                        speakIndex += 1
                                    }
                                } else {
                                    if vertical > 0 {
                                        //TODO: tutorial
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
                )
                .onAppear {
                    loadNotes()
                }
                .frame(width: .infinity, height: .infinity)
            if (showInfo) {
                Rectangle().fill(.green).frame(width: 200, height: 200)
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
}

#Preview {
    ContentView()
}
