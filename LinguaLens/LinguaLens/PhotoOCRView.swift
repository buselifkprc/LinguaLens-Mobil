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
    @State private var isProcessing: Bool = false
    @State private var errorMessage: String? = nil
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
                Text("Fotoğraf Seç")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .onChange(of: selectedItem) { oldValue, newValue in
                print("onChange tetiklendi")

                guard let newItem = newValue else {
                    print("Yeni item gelmedi")
                    return
                }

                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        print("Fotoğraf data yüklendi")
                        selectedImageData = data
                        recognizeText(from: uiImage)
                        print("Fotoğraf seçildi")
                    } else {
                        print("Veri alınamadı veya UIImage oluşmadı")
                    }
                }
            }
            if isProcessing {
                ProgressView("Metin işleniyor...")
                    .padding()
            }

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }


        }
        .padding()
        .navigationTitle("Fotoğraf Seç")
        .navigationDestination(isPresented: $navigateToTranslate) {
            TranslateView(ocrText: ocrResult)
        }
    }

    func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else {
            errorMessage = "Görsel okunamadı."
            return
        }

        isProcessing = true
        errorMessage = nil

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            DispatchQueue.main.async {
                isProcessing = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "OCR hatası: \(error.localizedDescription)"
                }
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                DispatchQueue.main.async {
                    errorMessage = "Metin bulunamadı."
                }
                return
            }

            let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }

            DispatchQueue.main.async {
                self.ocrResult = recognizedStrings.joined(separator: "\n")
                if self.ocrResult.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self.errorMessage = "Fotoğrafta okunabilir metin bulunamadı."
                }

                self.navigateToTranslate = true
            }
        }

        request.recognitionLevel = .accurate

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "OCR çalıştırılamadı."
                    isProcessing = false
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PhotoOCRView()
    }
}
