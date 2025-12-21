//
//  ScanView.swift
//  Purely
//
//  Created by Dmitrii Eselidze on 19.12.2025.
//

import SwiftUI
import AVFoundation
import Combine

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let v = PreviewView()
        v.videoPreviewLayer.session = session
        v.videoPreviewLayer.videoGravity = .resizeAspectFill
        return v
    }

    func updateUIView(_ uiView: PreviewView, context: Context) { }
}

final class PreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}

struct ScanView: View {
    @StateObject private var camera = CameraService()

    var body: some View {
        ZStack {
            CameraPreview(session: camera.session)
                .ignoresSafeArea()

            VStack {
                Spacer()

                HStack(spacing: 12) {
                    Button {
                        camera.captureAndRecognizeText()
                    } label: {
                        Text("Сделать снимок")
                            .font(.title3.weight(.medium))
                            .padding(.horizontal, 18)
                            .frame(height: 56)
                            .glassEffect()
                            .foregroundStyle(.black)
                    }
                    .buttonStyle(.plain)

                    Button {
                        camera.toggleTorch()
                    } label: {
                        Image(systemName: "flashlight.off.fill")
                            .frame(width: 70, height: 70)
                            .font(.system(size: 32, weight: .semibold))
                            .glassEffect()
                            .foregroundStyle(.black)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .onAppear { camera.configureAndStart() }
        .onDisappear { camera.stop() }
    }
}

#Preview {
    ScanView()
}
