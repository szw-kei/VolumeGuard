import AVFAudio
import Combine
import Foundation

@MainActor
final class VolumeObserver: NSObject, ObservableObject {

    @Published var volume: Float = 0
    @Published var maximumVolume: Float
    @Published var isLimitEnabled = false

    let volumeController = VolumeController()

    private let audioSession = AVAudioSession.sharedInstance()
    private let backgroundAudioKeeper = BackgroundAudioKeeper()

    private var observation: NSKeyValueObservation?
    private var correctionTask: Task<Void, Never>?

    private let maximumVolumeKey = "maximumVolume"

    override init() {

        // 保存済みの上限音量を読み込む
        if UserDefaults.standard.object(
            forKey: maximumVolumeKey
        ) != nil {

            maximumVolume = UserDefaults.standard.float(
                forKey: maximumVolumeKey
            )

        } else {

            // 初回起動時は10%
            maximumVolume = 0.10
        }

        super.init()

        configureAudioSession()

        volume = audioSession.outputVolume

        observation = audioSession.observe(
            \.outputVolume,
            options: [.initial, .new]
        ) { [weak self] _, change in

            guard let newVolume = change.newValue else {
                return
            }

            guard let observer = self else {
                return
            }

            Task { @MainActor in
                observer.handleVolumeChange(newVolume)
            }
        }
    }

    private func configureAudioSession() {
        do {
            try audioSession.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )

            try audioSession.setActive(true)

        } catch {
            print(
                "AudioSession setup failed:",
                error
            )
        }
    }

    private func handleVolumeChange(
        _ newVolume: Float
    ) {
        volume = newVolume

        guard isLimitEnabled else {
            return
        }

        guard newVolume > maximumVolume else {
            return
        }

        startCorrection()
    }

    private func startCorrection() {
        correctionTask?.cancel()

        correctionTask = Task {
            [weak self] in

            guard let self else {
                return
            }

            enforceMaximumVolume()

            try? await Task.sleep(
                for: .milliseconds(50)
            )

            guard !Task.isCancelled else {
                return
            }

            enforceMaximumVolume()

            try? await Task.sleep(
                for: .milliseconds(100)
            )

            guard !Task.isCancelled else {
                return
            }

            enforceMaximumVolume()
        }
    }

    private func enforceMaximumVolume() {
        guard isLimitEnabled else {
            return
        }

        let actualVolume =
            audioSession.outputVolume

        volume = actualVolume

        if actualVolume > maximumVolume {
            volumeController.setSystemVolume(
                maximumVolume
            )
        }
    }

    func setMaximumVolume(_ newValue: Float) {

        let clampedValue = min(
            max(newValue, 0.01),
            0.50
        )

        maximumVolume = clampedValue

        UserDefaults.standard.set(
            clampedValue,
            forKey: maximumVolumeKey
        )

        // 制限中に上限を下げた場合は即座に反映
        if isLimitEnabled &&
            audioSession.outputVolume > maximumVolume {

            startCorrection()
        }
    }

    func enableLimit() {
        isLimitEnabled = true

        backgroundAudioKeeper.start()

        if audioSession.outputVolume
            > maximumVolume {

            startCorrection()
        }
    }

    func disableLimit() {
        isLimitEnabled = false

        correctionTask?.cancel()
        correctionTask = nil

        backgroundAudioKeeper.stop()
    }

    deinit {
        observation?.invalidate()
        correctionTask?.cancel()
    }
}
