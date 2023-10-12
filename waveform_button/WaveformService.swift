//
//  WaveformService.swift
//  whatsgoingon
//
//  Created by Fabian Gruß on 06.10.23.
//

import AVFoundation
import Combine
import Foundation

// MARK: - Service Protocol

protocol ServiceProtocol {
    func buffer(data: Data, id: String, samplesCount: Int, completion: @escaping ([AudioPreviewModel]) -> ())
}

// MARK: - Service Implementation

class Service {
    // Singleton instance for the service class
    static let shared: ServiceProtocol = Service()

    // Private initializer to ensure only one instance is created
    private init() {}
}

extension Service: ServiceProtocol {
    /// Creates a waveform buffer from the provided audio data
    /// - Parameters:
    ///   - data: The audio data
    ///   - id: The identifier for the audio
    ///   - samplesCount: The number of samples to create for the waveform
    ///   - completion: Closure to return the generated waveform samples
    func buffer(data: Data, id: String, samplesCount: Int, completion: @escaping ([AudioPreviewModel]) -> ()) {
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                // Convert audio data to a temporary file
                let directory = FileManager.default.temporaryDirectory
                let path = directory.appendingPathComponent("\(id).wav")
                try data.write(to: path)

                // Read the audio file
                let file = try AVAudioFile(forReading: path)

                // Create buffer from the audio file
                if let format = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                              sampleRate: file.fileFormat.sampleRate,
                                              channels: file.fileFormat.channelCount, interleaved: false),
                    let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length))
                {
                    try file.read(into: buf)

                    guard let floatChannelData = buf.floatChannelData else { return }
                    let frameLength = Int(buf.frameLength)
                    let samples = Array(UnsafeBufferPointer(start: floatChannelData[0], count: frameLength))

                    // Convert raw samples to AudioPreviewModel format
                    var result = [AudioPreviewModel]()
                    let chunked = samples.chunked(into: samples.count / samplesCount)
                    for row in chunked {
                        var accumulator: Float = 0
                        let newRow = row.map { $0 * $0 }
                        accumulator = newRow.reduce(0, +)
                        let power: Float = accumulator / Float(row.count)
                        let decibles = 10 * log10f(power)

                        result.append(AudioPreviewModel(magnitude: decibles, color: .pinkSecondary, hasPlayed: false))
                    }

                    // Return the processed samples on the main thread
                    DispatchQueue.main.async {
                        completion(result)
                    }
                }
            } catch {
                print("Audio Error: \(error)")
            }
        }
    }
}

// MARK: - Array Extension

extension Array {
    /// Chunks the array into smaller arrays of a specified size
    /// - Parameter size: The size of each chunk
    /// - Returns: A 2D array where each inner array is of the given size or smaller
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
