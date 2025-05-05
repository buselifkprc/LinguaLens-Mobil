//
//  TranslationHistoryView.swift
//  LinguaLens
//
//  Created by Elif Buse Köprücü on 4.05.2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct TranslationHistoryView: View {
    @State private var translations: [TranslationRecord] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            List {
                if isLoading {
                    ProgressView("Yükleniyor...")
                } else if let error = errorMessage {
                    Text("\(error)")
                        .foregroundColor(.red)
                } else if translations.isEmpty {
                    Text("Henüz çeviri geçmişiniz yok.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(translations.sorted(by: { $0.timestamp > $1.timestamp })) { record in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("🔤 Orijinal: \(record.originalText)")
                                .font(.headline)
                            Text("🌍 Çeviri: \(record.translatedText)")
                                .font(.subheadline)
                            Text("🕒 \(record.timestamp.formatted(.dateTime))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(8)
                    }
                }
            }
            .navigationTitle("Çeviri Geçmişi")
            .onAppear(perform: fetchHistory)
        }
    }

    func fetchHistory() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Kullanıcı oturumu açık değil."
            self.isLoading = false
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(uid).collection("translations")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                }

                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Veri çekilemedi: \(error.localizedDescription)"
                    }
                    return
                }

                if let documents = snapshot?.documents {
                    do {
                        let decoded = try documents.map { try $0.data(as: TranslationRecord.self) }
                        DispatchQueue.main.async {
                            self.translations = decoded
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.errorMessage = "Veriler çözümlenemedi."
                        }
                    }
                }
            }
    }
}

