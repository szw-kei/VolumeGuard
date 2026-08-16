import AVFAudio
import Foundation

@MainActor
final class BackgroundAudioKeeper {

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()

    private var isRunning = false

    init() {
        engine.attach(player)

        let format = AVAudioFormat(
            standardFormatWithSampleRate: 44_100,
            channels: 1
        )!

        engine.connect(
            player,
            to: engine.mainMixerNode,
            format: format
        )
    }

    func start() {
        guard !isRunning else {
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()

            try session.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )

            try session.setActive(true)

            let format = AVAudioFormat(
                standardFormatWithSampleRate: 44_100,
                channels: 1
            )!

            guard let buffer = AVAudioPCMBuffer(
                pcmFormat: format,
                frameCapacity: 44_100
            ) else {
                print("Failed to create silent audio buffer")
                return
            }

            buffer.frameLength = buffer.frameCapacity

            if let channelData = buffer.floatChannelData {
                channelData[0].initialize(
                    repeating: 0,
                    count: Int(buffer.frameLength)
                )
            }

            try engine.start()

            player.scheduleBuffer(
                buffer,
                at: nil,
                options: .loops
            )

            player.play()

            isRunning = true

            print("Background audio keeper started")

        } catch {
            print(
                "Background audio keeper failed:",
                error
            )
        }
    }

    func stop() {
        guard isRunning else {
            return
        }

        player.stop()
        engine.stop()

        do {
            try AVAudioSession
                .sharedInstance()
                .setActive(false)
        } catch {
            print(
                "AudioSession deactivation failed:",
                error
            )
        }

        isRunning = false

        print("Background audio keeper stopped")
    }
}//
//  BackgroundAudioKeeper.swift
//  VolumeGuard
//
//  Created by 保澤圭亮 on 2026/08/15.
//

