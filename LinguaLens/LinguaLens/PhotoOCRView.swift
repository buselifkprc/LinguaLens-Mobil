//
//  PhotoOCRView.swift
//  LinguaLens
//
//  Created by Elif Buse Köprücü on 20.04.2025.
//

import SwiftUI
import PhotosUI
import Vision

struct PhotoOCRView: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil

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
                Text("📷 Fotoğraf Seç")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .onChange(of: selectedItem) {
                guard let selectedItem else { return }

                Task {
                    if let data = try? await selectedItem.loadTransferable(type: Data.self) {
                        selectedImageData = data
                        performOCR(from: data)  // OCR fonksiyonu burada çalışıyor ✅
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Fotoğraf Seç")
    }

    // 🔍 OCR Fonksiyonu
    func performOCR(from imageData: Data) {
        guard let uiImage = UIImage(data: imageData),
              let cgImage = uiImage.cgImage else {
            print("Görsel verisi alınamadı.")
            return
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                print("OCR hatası: \(error)")
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("OCR sonucu alınamadı.")
                return
            }

            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }

            // 🧠 OCR sonucu çıktı
            print("📄 OCR SONUCU:")
            print(recognizedStrings.joined(separator: "\n"))
        }

        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en", "tr"]

        do {
            try requestHandler.perform([request])
        } catch {
            print("OCR çalıştırma hatası: \(error)")
        }
    }
}
