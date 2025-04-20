//
//  PhotoOCRView.swift
//  LinguaLens
//
//  Created by Elif Buse Köprücü on 20.04.2025.
//

import SwiftUI
import PhotosUI
import Vision
import VisionKit

struct PhotoOCRView: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var ocrResult: String = ""
    @State private var navigateToTranslate: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            if let imageData = selectedImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            } else {
                Text("Henüz fotoğraf seçilmedi.")
                    .foregroundColor(.gray)
            }

            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Text("📸 Fotoğraf Seç")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .onChange(of: selectedItem) { newItem in
                guard let newItem else { return }

                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImageData = data
                        recognizeText(from: uiImage)
                    }
                }
            }


            // ✅ Sayfa yönlendirmesi için NavigationLink
            .navigationDestination(isPresented: $navigateToTranslate) {
                TranslateView(ocrText: ocrResult)
            }

            .hidden()
        }
        .padding()
        .navigationTitle("Fotoğraf Seç")
    }

    // ✅ OCR Fonksiyonu
    func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else {
            print("CGImage oluşturulamadı.")
            return
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

            let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }

            DispatchQueue.main.async {
                self.ocrResult = recognizedStrings.joined(separator: "\n")
                self.navigateToTranslate = true
            }
        }

        request.recognitionLevel = .accurate

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("OCR hatası: \(error)")
            }
        }
    }
}

#Preview {
    NavigationStack {
        PhotoOCRView()
    }
}
