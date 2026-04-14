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
                        .opacity(0.32)
                        .allowsHitTesting(false)
                }

            VStack {
                if isHintVisible {
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            isHintVisible = false
                        }
                    } label: {
                        Text("Наведите камеру на состав, чтобы проанализировать продукт.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }

                Spacer()

                HStack(spacing: 12) {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                           Image(systemName: "photo.on.rectangle.angled")
                               .frame(width: 70, height: 70)
                               .font(.system(size: 28, weight: .semibold))
                               .glassEffect()
                               .foregroundStyle(.black)
                       }
                       .buttonStyle(.plain)
                    
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
        .overlay(alignment: .center) {
            if camera.isLoading {
                AppScreenBackground()
                    .opacity(0.55)
                ProgressView("Идёт анализ...")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .glassEffect()
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
    }
}

#Preview {
    ScanView()
        .environmentObject(ProductStore())
}
