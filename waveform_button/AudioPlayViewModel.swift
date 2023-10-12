//
//  AudioVisualization.swift
//  whatsgoingon
//
//  Created by Fabian Gruß on 06.10.23.
//

import AVFoundation
import AVKit
import Combine
import Foundation
import SwiftUI

class AudioPlayViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    // MARK: - Published Properties

    @Published var isPlaying: Bool = false
    @Published public var soundSamples = [AudioPreviewModel]()
    @Published var displayedTime: TimeInterval = 0.0
    @Published var player: AVAudioPlayer!
    @Published var session: AVAudioSession!
    
    // MARK: - Private Properties

    private var timer: Timer?
    private var time_interval: TimeInterval = 0.0
    private let data: Data
    private let id: String
    private var index = 0
    private var dataManager: ServiceProtocol
    private let sample_count: Int

    // MARK: - Initialization

    init(data: Data, id: String, sample_count: Int, dataManager: ServiceProtocol = Service.shared) {
        self.data = data
        self.id = id
        self.sample_count = sample_count
        self.dataManager = dataManager
        super.init()
        
        setupAudioSession()
        initializePlayer()
        visualizeAudio()
    }
    
    // MARK: - Audio Setup

    private func setupAudioSession() {
        do {
            session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord)
            try session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func initializePlayer() {
        do {
            player = try AVAudioPlayer(data: data)
            player.delegate = self
            displayedTime = player.duration
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Timer Functions

    /// Starts a timer to update the displayed time and sound samples visualization.
    func startTimer() {
        count_duration { duration in
            // Set interval duration and adjust it slightly
            self.time_interval = (duration / Double(self.sample_count)) - 0.03
            
            // Schedule a repeating timer based on the time interval
            self.timer = Timer.scheduledTimer(withTimeInterval: self.time_interval, repeats: true, block: { _ in
                self.displayedTime = self.player.currentTime
                    
                if self.index < self.soundSamples.count {
                    self.soundSamples[self.index].color = Color.pinkPrimary
                    withAnimation(Animation.linear(duration: self.time_interval)) {
                        self.soundSamples[self.index].hasPlayed = true
                    }
                }
                    
                self.index += 1
            })
        }
    }
    
    // MARK: - Audio Controls

    /// Plays the audio, initializes a timer and updates the displayed time.
    func playAudio() {
        if isPlaying {
            pauseAudio()
        } else {
            displayedTime = 0.0
            // Reset player if it finished playing
            if player.currentTime >= player.duration {
                player.currentTime = 0.0
            }
            
            isPlaying.toggle()
            player.play()
            startTimer()
            count_duration { _ in }
        }
    }
    
    /// Pauses the audio and invalidates the timer.
    func pauseAudio() {
        player.pause()
        timer?.invalidate()
        isPlaying = false
    }
    
    /// Called when the audio finishes playing.
    /// Resets the sound samples and updates the displayed time.
    func playerDidFinishPlaying() {
        displayedTime = player.duration
        
        // Ensure the last sound sample is colored
        if soundSamples.last?.hasPlayed == false {
            soundSamples[index].color = Color.pinkPrimary
            withAnimation(Animation.linear(duration: time_interval)) {
                self.soundSamples[self.index].hasPlayed = true
            }
        }
        
        print("Has finished playing.")
        player.pause()
        timer?.invalidate()
        player.stop()
        
        // Reset properties after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.bouncy(extraBounce: 0.1)) {
                self.isPlaying = false
                self.time_interval = 0
                self.index = 0
                self.soundSamples = self.soundSamples.map { tmp -> AudioPreviewModel in
                    var cur = tmp
                    cur.color = .pinkSecondary
                    cur.hasPlayed = false
                    return cur
                }
            }
        }
    }
    
    // MARK: - Audio Visualization

    /// Uses the dataManager to process the audio data and generate sound samples for visualization.
    func visualizeAudio() {
        dataManager.buffer(data: data, id: id, samplesCount: sample_count) { results in
            self.soundSamples = results
        }
    }
    
    // MARK: - Cleanup

    /// Removes the audio file from temporary storage and posts a notification to hide the audio preview.
    func removeAudio() {
        do {
            let directory = FileManager.default.temporaryDirectory
            let path = directory.appendingPathComponent("\(id).wav")
            try FileManager.default.removeItem(at: path)
            NotificationCenter.default.post(name: Notification.Name("hide_audio_preview"), object: nil)
        } catch {
            print(error)
        }
    }
        
    // MARK: - Utility Functions

    /// Fetches the duration of the audio.
    private func count_duration(completion: @escaping (Float64) -> ()) {
        completion(Float64(player.duration))
    }
        
    // MARK: - AVAudioPlayerDelegate

    /// Delegate method that's called when the audio player finishes playing the audio.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playerDidFinishPlaying()
    }
}
