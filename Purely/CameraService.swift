import AVFoundation
import Vision
import UIKit
import SwiftUI
import Combine

final class CameraService: NSObject, ObservableObject {
    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let photoOutput = AVCapturePhotoOutput()

    private var videoInput: AVCaptureDeviceInput?
    private var isConfigured = false

    func configureAndStart() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if !self.isConfigured {
                self.configureSession()
                self.isConfigured = true
            }
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo
        defer { session.commitConfiguration() }

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            print("❌ Не удалось создать input камеры")
            return
        }
        session.addInput(input)
        videoInput = input

        guard session.canAddOutput(photoOutput) else {
            print("❌ Не удалось добавить photoOutput")
            return
        }
        session.addOutput(photoOutput)
        photoOutput.isHighResolutionCaptureEnabled = true
    }

    func captureAndRecognizeText() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            let settings = AVCapturePhotoSettings()
            if let device = self.videoInput?.device, device.hasFlash {
                settings.flashMode = .off
            }
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    func toggleTorch() {
        sessionQueue.async { [weak self] in
            guard
                let self,
                let device = self.videoInput?.device,
                device.hasTorch
            else { return }

            do {
                try device.lockForConfiguration()
                device.torchMode = (device.torchMode == .on) ? .off : .on
                device.unlockForConfiguration()
            } catch {
                print("❌ Torch error:", error)
            }
        }
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let error {
            print("❌ Photo capture error:", error)
            return
        }

        guard
            let data = photo.fileDataRepresentation(),
            let uiImage = UIImage(data: data),
            let cgImage = uiImage.cgImage
        else {
            print("❌ Не удалось получить изображение из фото")
            return
        }

        recognizeText(in: cgImage)
    }

    private func recognizeText(in cgImage: CGImage) {
        let request = VNRecognizeTextRequest { req, err in
            if let err {
                print("❌ Vision error:", err)
                return
            }

            let observations = (req.results as? [VNRecognizedTextObservation]) ?? []
            let lines = observations.compactMap { $0.topCandidates(1).first?.string }

            print("✅ Recognized text:")
            print(lines.joined(separator: "\n"))
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["ru-RU", "en-US"]

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("❌ Handler perform error:", error)
        }
    }
}
