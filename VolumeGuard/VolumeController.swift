import MediaPlayer
import UIKit

@MainActor
final class VolumeController {

    let volumeView: MPVolumeView

    init() {
        let view = MPVolumeView(frame: .zero)
        self.volumeView = view
    }

    private var volumeSlider: UISlider? {
        volumeView.subviews
            .compactMap { $0 as? UISlider }
            .first
    }

    func setSystemVolume(_ value: Float) {
        let target = min(max(value, 0.0), 1.0)

        guard let slider = volumeSlider else {
            print("MPVolumeView slider not found")
            return
        }

        slider.setValue(target, animated: false)
        slider.sendActions(for: .valueChanged)
    }
}
