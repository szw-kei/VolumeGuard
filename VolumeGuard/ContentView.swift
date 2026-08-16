import SwiftUI

struct ContentView: View {

    @StateObject private var volumeObserver = VolumeObserver()

    var body: some View {
        ZStack {
            backgroundView

            ScrollView {
                VStack(spacing: 16) {
                    headerView

                    if volumeObserver.isLimitEnabled {
                        activeLimitCard
                    } else {
                        inactiveLimitCard
                    }

                    currentVolumeCard

                    SystemVolumeView(
                        controller: volumeObserver.volumeController
                    )
                    .frame(width: 1, height: 1)
                    .opacity(0.01)
                    .allowsHitTesting(false)
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
    }

    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(.secondarySystemBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var headerView: some View {
        HStack(spacing: 12) {
            Image(
                systemName: volumeObserver.isLimitEnabled
                    ? "lock.shield.fill"
                    : "speaker.wave.2.fill"
            )
            .font(.system(size: 34, weight: .semibold))
            .foregroundStyle(
                volumeObserver.isLimitEnabled
                    ? .green
                    : .blue
            )

            VStack(alignment: .leading, spacing: 2) {
                Text("VolumeGuard")
                    .font(
                        .system(
                            size: 27,
                            weight: .bold,
                            design: .rounded
                        )
                    )

                Text(
                    volumeObserver.isLimitEnabled
                        ? "音量制限が有効です"
                        : "最大音量を設定してください"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private var inactiveLimitCard: some View {
        VStack(spacing: 14) {

            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("音量上限")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    Text(
                        "\(Int(volumeObserver.maximumVolume * 100))%"
                    )
                    .font(
                        .system(
                            size: 38,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                }

                Spacer()

                Image(systemName: "speaker.wave.2")
                    .font(.system(size: 30))
                    .foregroundStyle(.secondary)
            }

            Slider(
                value: Binding(
                    get: {
                        Double(volumeObserver.maximumVolume)
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

            HStack {
                Text("1%")
                Spacer()
                Text("50%")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)

            Button {
                volumeObserver.enableLimit()
            } label: {
                Label(
                    "音量制限を開始",
                    systemImage: "shield.checkered"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var activeLimitCard: some View {
        VStack(spacing: 14) {

            HStack {
                Label(
                    "音量制限中",
                    systemImage: "checkmark.shield.fill"
                )
                .font(.headline)
                .foregroundStyle(.green)

                Spacer()

                Text(
                    "\(Int(volumeObserver.maximumVolume * 100))%"
                )
                .font(
                    .system(
                        size: 34,
                        weight: .bold,
                        design: .rounded
                    )
                )
            }

            Label(
                "設定はロックされています",
                systemImage: "lock.fill"
            )
            .font(.caption)
            .foregroundStyle(.secondary)

            Text("3秒長押しで音量制限を解除")
                .font(.headline)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: 14)
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
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var currentVolumeCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("現在の音量")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Text(
                    "\(Int(volumeObserver.volume * 100))%"
                )
                .font(
                    .system(
                        size: 34,
                        weight: .bold,
                        design: .rounded
                    )
                )
            }

            Spacer()

            ProgressView(
                value: Double(volumeObserver.volume),
                total: 1.0
            )
            .progressViewStyle(.linear)
            .frame(width: 110)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    ContentView()
}
