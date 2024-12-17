import AVFoundation
import Speech

class SpeechRecognizer: ObservableObject {
    @Published var recognizedText = ""
    @Published var isRecording = false
    
    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "de-DE"))
    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                if status != .authorized {
                    print("Speech recognition not authorized.")
                }
            }
        }
    }
    
    func startRecording() {
        resetAudioSession()
        
        // Initialize objects
        audioEngine = AVAudioEngine()
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let audioEngine = audioEngine,
              let recognitionRequest = recognitionRequest,
              let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            print("Speech recognizer not available or audioEngine/recognitionRequest not initialized.")
            return
        }
        
        isRecording = true
        recognizedText = "" // Clear any previous text
        
        // Setup the recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let result = result {
                self?.recognizedText = result.bestTranscription.formattedString
            }
            
            if let error = error {
                print("Speech recognition error: \(error.localizedDescription)")
                self?.stopRecording()
            }
        }
        
        // Configure the input node
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        // Start the audio engine
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error.localizedDescription)")
            stopRecording()
        }
    }
    
    func stopRecording(cleanUp: Bool = true) {
        guard isRecording else { return }
        
        // Stop recording and clean up audio objects
        isRecording = false
        
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        
        if cleanUp {
            deactivateAudioSession()
        }
        do {
        let audioSession = AVAudioSession.sharedInstance()

        try audioSession.setCategory(.ambient, mode: .spokenAudio, options: .duckOthers)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    private func resetAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    private func deactivateAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
}
