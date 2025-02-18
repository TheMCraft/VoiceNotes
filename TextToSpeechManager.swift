import AVFoundation

@MainActor
final class TextToSpeechManager: NSObject, AVSpeechSynthesizerDelegate {
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    func printAvailableVoices() {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        for voice in voices {
            print("Voice Identifier: \(voice.identifier), Language: \(voice.language), Name: \(voice.name)")
        }
    }
    
    func speak(text: String, language: String = "de-DE", voiceIdentifier: String? = nil, force: Bool = true) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("Nothing to speak.")
            return
        }
        
        if (force) {
            stopSpeaking()
        }
        
        let utterance = AVSpeechUtterance(string: text)
        if let voiceIdentifier = voiceIdentifier,
           let voice = AVSpeechSynthesisVoice(identifier: voiceIdentifier) {
            utterance.voice = voice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: language)
        }
        
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        
        print("Trying to speak: \(text) with voice: \(utterance.voice?.name ?? "Default Voice")")
        
        speechSynthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
}
