//
//  TranslateView.swift
//  LinguaLens
//
//  Created by Elif Buse Köprücü on 20.04.2025.
//

import SwiftUI

struct TranslateView: View {
    @State private var originalText: String = "BREAKFAST\nSIDES\n- Scrambled Eggs\n- Bacon\n- Toast"
    @State private var translatedText: String = "KAHVALTI\nYAN ÜRÜNLER\n- Çırpılmış Yumurta\n- Pastırma\n- Tost"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("🔤 Algılanan Metin:")
                .font(.headline)

            ScrollView {
                Text(originalText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }

            Text("🌍 Çeviri:")
                .font(.headline)

            ScrollView {
                Text(translatedText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Çeviri Sonuçları")
    }
}
