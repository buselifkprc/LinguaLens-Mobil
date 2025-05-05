//
//  TranslateView.swift
//  LinguaLens
//
//  Created by Elif Buse Köprücü on 20.04.2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct TranslateView: View {
    var ocrText: String

    @State private var translatedText: String = ""
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Tanınan Metin:")
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
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
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

    func translateText(_ input: String) {
        guard let url = URL(string: "https://libretranslate.com/translate") else {
            errorMessage = "API adresi geçersiz."
            isLoading = false
            return
        }

        let parameters: [String: Any] = [
            "q": input,
            "source": "en",
            "target": "tr",
            "format": "text"
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            errorMessage = "JSON verisi oluşturulamadı."
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Ağ hatası: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "Veri alınamadı."
                }
                return
            }

            if let result = try? JSONDecoder().decode(TranslationResult.self, from: data) {
                DispatchQueue.main.async {
                    translatedText = result.translatedText
                    saveToFirestore(original: input, translated: result.translatedText)
                }
            } else {
                DispatchQueue.main.async {
                    errorMessage = "Çeviri alınamadı. Yanıt formatı beklenmedik olabilir."
                }
            }
        }.resume()
    }

    // Firestore'a geçmiş kaydı
    func saveToFirestore(original: String, translated: String) {
        guard let user = Auth.auth().currentUser else {
            print("Kullanıcı oturumu yok.")
            return
        }

        let db = Firestore.firestore()
        db.collection("users")
            .document(user.uid)
            .collection("translations")
            .addDocument(data: [
                "originalText": original,
                "translatedText": translated,
                "timestamp": Timestamp(date: Date())
            ]) { error in
                if let error = error {
                    print("Firestore'a kaydetme hatası: \(error.localizedDescription)")
                } else {
                    print("Çeviri geçmişi Firestore'a kaydedildi.")
                }
            }
    }
}

struct TranslationResult: Decodable {
    let translatedText: String
}

#Preview {
    NavigationStack {
        TranslateView(ocrText: "BREAKFAST\n- Eggs\n- Toast")
    }
}
