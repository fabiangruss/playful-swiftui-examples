//
//  AudioVisualization.swift
//  whatsgoingon
//
//  Created by Fabian Gruß on 08.10.23.
//

import SwiftUI

// MARK: - Audio Visualization Main View

struct AudioVisualization: View {
    @StateObject private var audioVM: AudioPlayViewModel
    @State var overlayOpacity: Double = 0.0

    // MARK: - Initializer

    init(data: Data, id: String) {
        _audioVM = StateObject(wrappedValue: AudioPlayViewModel(data: data, id: id, sample_count: 20))
    }

    // MARK: - Body

    var body: some View {
        if !(audioVM.isPlaying || (!audioVM.isPlaying && audioVM.player.currentTime != 0.0)) {
            Spacer()
        }

        // Play/Pause button
        Button(action: handlePlayPauseAction) {
            playerControlContent
        }
        .onChange(of: audioVM.isPlaying || (!audioVM.isPlaying && audioVM.player.currentTime != 0.0)) { _, new in
            handleOverlayOpacityChange(new)
        }
        .buttonStyle(SquishySizelessButton(color: .pinkSecondary, goalColor: .pinkPrimary.opacity(0.3), cornerRadius: 14))
    }

    // MARK: - Private Helpers

    /// Handles the play/pause action.
    private func handlePlayPauseAction() {
        if audioVM.isPlaying {
            // A little extra bounce for actions through the stateMachine
            withAnimation(.bouncy(extraBounce: 0.1)) {
                audioVM.pauseAudio()
            }
        } else {
            // A little extra bounce for actions through the stateMachine
            withAnimation(.bouncy(extraBounce: 0.1)) {
                audioVM.playAudio()
            }
        }
    }

    /// Modifies the overlay opacity based on the audio's play status.
    private func handleOverlayOpacityChange(_ isPlaying: Bool) {
        if isPlaying {
            // Introduce a delay before starting the fade-in animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 1.0)) {
                    overlayOpacity = 1.0
                }
            }
        } else {
            withAnimation(.easeOut(duration: 0.2)) {
                overlayOpacity = 0.0
            }
        }
    }

    /// Content of the player's control button.
    private var playerControlContent: some View {
        ZStack(alignment: .center) {
            HStack {
                CustomIcon(type: audioVM.isPlaying ? .pause : .play, originalSize: 24.0)
                    .contentTransition(.symbolEffect(.replace))
                    .foregroundColor(.pinkPrimary)
                    .padding(.leading, 14)

                if audioVM.isPlaying || (!audioVM.isPlaying && audioVM.player.currentTime != 0.0) {
                    Spacer()
                }

                ZStack(alignment: .leading) {
                    Text("00:00").opacity(0.0).tinyCardHeader(color: .pinkPrimary)
                    Text(formatTimeInterval(interval: audioVM.displayedTime)).tinyCardHeader(color: .pinkPrimary)
                }
                .frame(width: 48)
                .padding(.trailing, 16)
            }

            HStack(alignment: .center, spacing: 3) {
                ForEach(audioVM.soundSamples, id: \.self) { model in
                    BarView(value: normalizeSoundLevel(level: model.magnitude), color: model.hasPlayed ? .pinkPrimary : .pinkPrimary.opacity(0.3))
                }
            }
            .clipped()
            .offset(x: -16)
            .opacity(overlayOpacity)
        }
        .background(.pinkSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 14.0))
    }

    /// Normalizes the sound level for display.
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 70) / 2 // between 0.1 and 35
        return CGFloat(level * (40 / 35))
    }

    /// Formats a time interval to mm:ss
    private func formatTimeInterval(interval: TimeInterval) -> String {
        let duration: Duration = .seconds(interval)
        return duration.formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2))) // "02:06"
    }
}

// MARK: - BarView Component

struct BarView: View {
    let value: CGFloat
    var color: Color = .pinkSecondary

    var body: some View {
        Rectangle()
            .fill(color)
            .cornerRadius(10)
            .frame(width: 2, height: value)
            .animation(Animation.easeInOut(duration: 1.0), value: color)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 0) {
        @State var isPlaying = true
        @State var overlayOpacity: Double = 0.0

        Spacer()

        // Play/Pause button
        Button {} label: {
            HStack {
                CustomIcon(type: isPlaying ? .pause : .play, originalSize: 24.0)
                    .contentTransition(.symbolEffect(.replace))
                    .foregroundColor(.pinkPrimary)
                    .padding(.leading, 14)

                if isPlaying { Spacer() }

                ZStack(alignment: .trailing) {
                    Text("00:00").opacity(0.0).tinyCardHeader(color: .pinkPrimary)
                    Text("00:05").tinyCardHeader(color: .pinkPrimary)
                }.frame(width: 48)
                    .padding(.trailing, 16)
            }
            .background(.pinkSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 14.0))

            .onChange(of: isPlaying) {
                if isPlaying {
                    // Introduce a delay before starting the fade-in animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation {
                            overlayOpacity = 1.0
                        }
                    }
                } else {
                    withAnimation {
                        overlayOpacity = 0.0
                    }
                }
            }
            .overlay(alignment: .center) {
                HStack(alignment: .center, spacing: 3) {
                    ForEach(0 ... 25, id: \.self) { _ in
                        BarView(value: Double.random(in: 23 ... 35), color: .pinkPrimary)
                    }
                }
                .clipped()
                .offset(x: -16)
                .opacity(overlayOpacity)
            }
        }

        .buttonStyle(SquishySizelessButton(color: .pinkSecondary, goalColor: .pinkPrimary.opacity(0.3), cornerRadius: 14))
    }
    .frame(width: 280, height: 150.0)
    .padding(.all, 16)
    .background(.buttonGrey)
    .cornerRadius(20.0)
}
