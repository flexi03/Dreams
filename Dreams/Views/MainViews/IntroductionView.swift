//
//  IntroductionView.swift
//  Dreams
//
//  Created by Felix Kircher on 04.04.25.
//

import SwiftUI
import AVKit

struct IntroductionView: View {
    @Binding var isFirstStart: Bool
    
    @State var player = AVPlayer(url: Bundle.main.url(forResource: "AppIconAnimation", withExtension: "mp4")!)
    @State var isPlaying: Bool = false
    @State private var showText: Bool = false
    
    var body: some View {
        ZStack {
            // Video background
            AVPlayerControllerRepresented(player: player)
                .frame(width: 300, height: 300, alignment: .center)
                .zIndex(0)
                .onAppear {
                    isPlaying = true
                    player.play()
                    player.seek(to: .zero)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        showText = true
                    }
                }

            // Foreground UI
            VStack {
                Spacer().frame(height: 500)

//                Text("Willkommen zu Dreams!")
//                    .font(.title2)
//                    .bold()
//                    .opacity(showText ? 1 : 0)
//                    .animation(.easeIn(duration: 0.5), value: showText)

                Spacer().frame(height: 150)

                Button() {
                    withAnimation {
                        isFirstStart.toggle()
                    }
                    print(isFirstStart)
                } label: {
                    Text("Starte dein Traumabenteuer!")
                        .foregroundColor(.black)
                        .bold()
                        .frame(width: 300, height: 50)
                        .background() {
                            Capsule()
                            Capsule()
                                .blur(radius: 25)
                        }
                }
                .opacity(showText ? 1 : 0)
                .animation(.easeIn(duration: 0.5), value: showText)
            }
            .zIndex(1)
        }
    }
}

// Eigene SwiftUI-Ansicht für AVPlayerViewController ohne Steuerelemente
struct AVPlayerControllerRepresented: UIViewControllerRepresentable {
    var player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false // Steuerelemente ausblenden
        
        // Text-Erkennungssymbol deaktivieren
        if #available(iOS 16.0, *) {
            controller.allowsVideoFrameAnalysis = false
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

#Preview {
    IntroductionView(isFirstStart: .constant(true))
        .preferredColorScheme(.dark)
}
