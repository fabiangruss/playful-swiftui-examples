//
//  AudioPlayerButton.swift
//  whatsgoingon
//
//  Created by Fabian Gruß on 06.10.23.
//

import SwiftUI

struct AudioPlayerButton: View {
    // Default state
    @State private var state: AudioPlayerState = .isIdle

    // Vars for the timer
    @State private var recordingStart: Date = .now
    // For the example, let's go with 5 seconds duration. Use your own values from the actual audio files here
    private var duration = 5.0
    @State private var elapsedPlaybackTime = TimeInterval()
    @State private var totalPausedTime = TimeInterval()
    @State private var progress: CGFloat = 0

    // Publish a timer to listen to for the counter
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Colors (adjust to your liking
    private var primaryColor = Color(hex: 0xff58a8) // Pink primary
    private var secondaryColor = Color(hex: 0xfcdbeb) // Pink secondary

    var body: some View {
        Button {
            // A little extra bounce for actions through the stateMachine
            withAnimation(.bouncy(extraBounce: 0.2)) {
                stateMachine()
            }
        } label: {
            HStack {
                Image(systemName: state == .isPlaying ? "pause.fill" : "play.fill").font(.system(size: 22))
                    .contentTransition(.symbolEffect(.replace))
                    .foregroundColor(primaryColor)
                    .padding(.leading, 12)
                Spacer()
                HStack {
                    Spacer()
                    Text(formatTimeInterval(interval: elapsedPlaybackTime))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundStyle(primaryColor)
                        .contentTransition(.opacity)
                        .padding(.trailing, 12)
                        .frame(width: 52, alignment: .leading)
                }

                .onReceive(timer) { firedDate in
                    // Only update UI if isPlaying
                    if state == .isPlaying {
                        let elapsedTime = firedDate.timeIntervalSince(recordingStart)
                        withAnimation {
                            progress = CGFloat(elapsedTime / 5.0)
                        }
                        elapsedPlaybackTime = TimeInterval(progress * 5)

                        // Stop the playing with a little less bounce
                        if elapsedTime > duration {
                            withAnimation(.bouncy(extraBounce: 0.1)) {
                                state = .isIdle
                                reset()
                                timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                            }
                        }
                    }
                }
            }
            .frame(width: state == .isIdle ? 96 : 196, height: 44)
            .background(secondaryColor)
            .clipShape(RoundedRectangle(cornerRadius: 12.0))
        }
        .buttonStyle(SquishyButton(color: secondaryColor, goalColor: primaryColor.opacity(0.3), minWidth: 96, minHeight: 44, cornerRadius: 12))
        .padding(.all, 48)
    }

    private func stateMachine() {
        switch state {
        case .isIdle:
            reset()
            state = .isPlaying
        case .isPlaying:
            totalPausedTime += Date().timeIntervalSince(recordingStart)
            timer.upstream.connect().cancel()
            state = .isPaused
        case .isPaused:
            recordingStart = Date().addingTimeInterval(-totalPausedTime)
            timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            state = .isPlaying
        }
    }

    /// Formats a time interval to mm:ss
    private func formatTimeInterval(interval: TimeInterval) -> String {
        let duration: Duration = .seconds(interval)
        return duration.formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2))) // "02:06"
    }

    /// Reset timer values
    private func reset() {
        recordingStart = Date()
        totalPausedTime = TimeInterval()
        elapsedPlaybackTime = TimeInterval()
    }
}

enum AudioPlayerState: String {
    case isIdle, isPlaying, isPaused
}

#Preview {
    AudioPlayerButton()
}

// Let's use hex colors
extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

// Button style
struct SquishyButton: ButtonStyle {
    var color: Color
    var goalColor: Color
    var minWidth: Double = 98
    var minHeight: Double = 70
    var cornerRadius: Double = 18

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: minWidth, minHeight: minHeight)
            .overlay {
                Squircle(cornerRadius: configuration.isPressed ? (cornerRadius+1) : cornerRadius).fill(configuration.isPressed ? goalColor.opacity(0.4) : .clear)
            }
            .background(Squircle(cornerRadius: configuration.isPressed ? (cornerRadius+1) : cornerRadius))
            .foregroundStyle(color)
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(duration: 0.5), value: configuration.isPressed)
            .sensoryFeedback(.impact(intensity: 0.8), trigger: configuration.isPressed)
    }
}

// Shape style
struct Squircle: Shape {
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: .allCorners,
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        return Path(path.cgPath)
    }
}
