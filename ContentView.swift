import SwiftUI

struct ContentView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
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
        }
        .padding()
    }
}
#Preview {
    ContentView()
}
