//
//  ScanView.swift
//  Purely
//
//  Created by Dmitrii Eselidze on 19.12.2025.
//

import SwiftUI
import AVFoundation
import Combine
import PhotosUI

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
    @EnvironmentObject var store: ProductStore
    @StateObject private var camera = CameraService()
    @State private var selectedProduct: Product?
    @State private var isHintVisible = true
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        ZStack {
            CameraPreview(session: camera.session)
                .ignoresSafeArea()
                .overlay {
                    AppScreenBackground()
                        .opacity(0.42)
                        .allowsHitTesting(false)
                }
                .overlay {
                    Color.black
                        .opacity(0.08)
                        .allowsHitTesting(false)
                }

            VStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.title3.weight(.semibold))
                        Text("Purely")
                            .font(.title3.weight(.bold))
                    }
                    .foregroundStyle(.white)

                    Text("Сканировать состав")
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    if isHintVisible {
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) {
                                isHintVisible = false
                            }
                        } label: {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "text.viewfinder")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.86))

                                Text("Наведите камеру на INCI-состав или выберите фото из галереи.")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.78))
                                    .multilineTextAlignment(.leading)

                                Spacer(minLength: 8)

                                Image(systemName: "xmark")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white.opacity(0.58))
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)

                Spacer()

                VStack(spacing: 14) {
                    HStack(spacing: 12) {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            scanIconButton(systemName: "photo.on.rectangle.angled")
                        }
                        .buttonStyle(.plain)

                        Button {
                            camera.captureAndRecognizeText()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "camera.viewfinder")
                                    .font(.title3.weight(.semibold))
                                Text("Снимок")
                                    .font(.title3.weight(.semibold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .background(Color.white.opacity(0.18))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.26), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)

                        Button {
                            camera.toggleTorch()
                        } label: {
                            scanIconButton(systemName: "flashlight.off.fill")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 24)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .overlay(alignment: .center) {
            if camera.isLoading {
                AppScreenBackground()
                    .opacity(0.72)
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    ProgressView()
                        .tint(.white)
                        .controlSize(.large)

                    Text("Идёт анализ")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)

                    Text("Распознаём состав и оцениваем риск компонентов")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 18)
                .frame(maxWidth: 280)
                .background(Color.white.opacity(0.16))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                )
            }
        }
        .onAppear { camera.configureAndStart() }
        .onDisappear { camera.stop() }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }

            Task {
                do {
                    guard let data = try await newItem.loadTransferable(type: Data.self),
                          let uiImage = UIImage(data: data),
                          let cgImage = uiImage.cgImage else {
                        return
                    }

                    camera.recognizeTextFromGallery(cgImage)
                } catch {
                    print("❌ Ошибка загрузки фото из галереи:", error)
                }
            }
        }
        .onChange(of: camera.product) { _, newValue in
            guard let product = newValue else { return }
            store.addProduct(product)
            selectedProduct = product
        }
        .navigationDestination(item: $selectedProduct) { product in
            ProductDetailView(product: product)
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(.white)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func scanIconButton(systemName: String) -> some View {
        Image(systemName: systemName)
            .frame(width: 64, height: 64)
            .font(.system(size: 26, weight: .semibold))
            .foregroundStyle(.white)
            .background(Color.white.opacity(0.16))
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.24), lineWidth: 1)
            )
    }
}

#Preview {
    ScanView()
        .environmentObject(ProductStore())
}
