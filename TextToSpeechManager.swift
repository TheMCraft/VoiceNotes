import AVFoundation

final class TextToSpeechManager: NSObject, AVSpeechSynthesizerDelegate, @unchecked Sendable {
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    func speak(text: String, language: String = "de-DE") {
        guard !text.isEmpty else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        
        DispatchQueue.main.async {
            self.speechSynthesizer.speak(utterance)
        }
    }
}
