import MediaPlayer
import SwiftUI

struct SystemVolumeView: UIViewRepresentable {

    let controller: VolumeController

    func makeUIView(context: Context) -> MPVolumeView {
        controller.volumeView
    }

    func updateUIView(
        _ uiView: MPVolumeView,
        context: Context
    ) {
    }
}//
//  SystemVolumeView.swift
//  VolumeGuard
//
//  Created by 保澤圭亮 on 2026/08/15.
//

