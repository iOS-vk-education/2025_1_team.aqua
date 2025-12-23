import AVFoundation
import Vision
import UIKit
import SwiftUI
import Combine

final class CameraService: NSObject, ObservableObject {
    @Published var isLoading: Bool = false
    @Published var product: Product?
    let session = AVCaptureSession()

    func parseAPIResponse(responseString: String) {
        guard let range = responseString.range(of: "```json\n") else { return }
        let jsonText = responseString[range.upperBound...]
        
        guard let endRange = jsonText.range(of: "```") else { return }
        let cleanJson = jsonText[..<endRange.lowerBound]
        
        guard let data = cleanJson.data(using: .utf8) else { return }
        
        let decoder = JSONDecoder()

        do {
            let decodedProduct = try decoder.decode(Product.self, from: data)
            DispatchQueue.main.async {
                self.product = decodedProduct
                self.isLoading = false
            }
        } catch {
            print("Error parsing response: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }

    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let photoOutput = AVCapturePhotoOutput()

    private var videoInput: AVCaptureDeviceInput?
    private var isConfigured = false

    func configureAndStart() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
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
            guard let self = self else { return }
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
            guard let self = self else { return }
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
                let self = self,
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
        if let error = error {
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

    func sendRecognizedTextToAPI(text: String) {
        guard let url = URL(string: "http://192.168.1.9:8080/analyze") else { return }

        // Создаем тело запроса в формате JSON
        let parameters: [String: Any] = ["text": text]
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        self.isLoading = true  // Начало загрузки

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Обработка ошибок при запросе
            if let error = error {
                print("Ошибка при отправке запроса: \(error)")
                self.isLoading = false
                return
            }

            // Проверка наличия данных в ответе
            guard let data = data else {
                print("Нет данных в ответе")
                self.isLoading = false
                return
            }

            // Попытка обработки ответа как JSON
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // Проверяем наличие ключа "output_text" в ответе
                    if let outputText = jsonResponse["output_text"] as? String {
                        // Парсим данные и создаем модель
                        self.parseAPIResponse(responseString: outputText)
                    } else {
                        print("Поле 'output_text' отсутствует в ответе")
                    }
                } else {
                    print("Ответ не является корректным JSON")
                }
            } catch {
                print("Ошибка при обработке данных: \(error)")
            }
        }
        task.resume()
    }

    private func recognizeText(in cgImage: CGImage) {
        let request = VNRecognizeTextRequest { req, err in
            if let err = err {
                print("❌ Vision error:", err)
                return
            }

            let observations = (req.results as? [VNRecognizedTextObservation]) ?? []
            let lines = observations.compactMap { $0.topCandidates(1).first?.string }

            let recognizedText = lines.joined(separator: "\n")
            print("✅ Распознанный текст: \(recognizedText)")

            self.sendRecognizedTextToAPI(text: recognizedText)
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
