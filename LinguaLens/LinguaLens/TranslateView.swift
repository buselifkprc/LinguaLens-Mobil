//
//  TranslateView.swift
//  LinguaLens
//
//  Created by Elif Buse Köprücü on 20.04.2025.
//

import SwiftUI

struct TranslateView: View {
    var ocrText: String
    
    @State private var translatedText: String = "Çeviri bekleniyor..."
    @State private var isLoading: Bool = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("🔤 Tanınan Metin:")
                    .font(.headline)

                Text(ocrText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                Divider()

                Text("🌐 Çevrilmiş Metin:")
                    .font(.headline)

                if isLoading {
                    ProgressView("Çeviri yapılıyor...")
                } else {
                    Text(translatedText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemYellow).opacity(0.2))
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("Çeviri Sonucu")
        .onAppear {
            translateText(ocrText)
        }
    }

    // 🌐 LibreTranslate API ile çeviri
    func translateText(_ input: String) {
        guard let url = URL(string: "https://libretranslate.com/translate") else { return }

        let parameters: [String: Any] = [
            "q": input,
            "source": "en",
            "target": "tr",
            "format": "text"
        ]

        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    translatedText = "❌ API hatası: \(error?.localizedDescription ?? "Bilinmiyor")"
                }
                return
            }

            if let result = try? JSONDecoder().decode(TranslationResult.self, from: data) {
                DispatchQueue.main.async {
                    translatedText = result.translatedText
                }
            } else {
                DispatchQueue.main.async {
                    translatedText = "❌ Çeviri alınamadı."
                }
            }
        }.resume()
    }
}

// JSON cevabını decode etmek için model
struct TranslationResult: Decodable {
    let translatedText: String
}

#Preview {
    NavigationStack {
        TranslateView(ocrText: "BREAKFAST\n- Eggs\n- Toast")
    }
}
