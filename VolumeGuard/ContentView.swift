import SwiftUI

struct ContentView: View {

    @StateObject private var volumeObserver = VolumeObserver()

    var body: some View {

        VStack(spacing: 28) {

            Image(
                systemName: volumeObserver.isLimitEnabled
                    ? "lock.shield.fill"
                    : "speaker.wave.2.fill"
            )
            .font(.system(size: 64))

            Text("VolumeGuard")
                .font(.largeTitle)
                .bold()

            VStack(spacing: 8) {

                Text("現在の音量")

                Text("\(Int(volumeObserver.volume * 100))%")
                    .font(
                        .system(
                            size: 48,
                            weight: .bold,
                            design: .rounded
                        )
                    )
            }

            VStack(spacing: 12) {

                Text(
                    "音量上限：\(Int(volumeObserver.maximumVolume * 100))%"
                )
                .font(.title3)
                .bold()

                Slider(
                    value: Binding(
                        get: {
                            Double(
                                volumeObserver.maximumVolume
                            )
                        },
                        set: {
                            volumeObserver.setMaximumVolume(
                                Float($0)
                            )
                        }
                    ),
                    in: 0.01...0.50,
                    step: 0.01
                )
                .disabled(volumeObserver.isLimitEnabled)

                if volumeObserver.isLimitEnabled {

                    Label(
                        "制限中は変更できません",
                        systemImage: "lock.fill"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }

            if volumeObserver.isLimitEnabled {

                VStack(spacing: 12) {

                    Label(
                        "音量制限中",
                        systemImage: "checkmark.shield.fill"
                    )
                    .font(.headline)
                    .foregroundStyle(.green)

                    Text("3秒長押しで制限を解除")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .font(.headline)
                        .foregroundStyle(.red)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 12
                            )
                            .stroke(
                                Color.red,
                                lineWidth: 2
                            )
                        )
                        .contentShape(Rectangle())
                        .onLongPressGesture(
                            minimumDuration: 3.0
                        ) {
                            volumeObserver.disableLimit()
                        }

                    Text(
                        "お子様が使用中は、この画面を操作しても簡単には解除されません。"
                    )
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                }

            } else {

                Button {
                    volumeObserver.enableLimit()
                } label: {

                    Text("音量制限を開始")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
            }

            SystemVolumeView(
                controller: volumeObserver.volumeController
            )
            .frame(width: 1, height: 1)
            .opacity(0.01)
            .allowsHitTesting(false)
        }
        .padding(30)
    }
}

#Preview {
    ContentView()
}
