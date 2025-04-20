//
//  RestaurantInfoView.swift
//  LinguaLens
//
//  Created by Elif Buse Köprücü on 20.04.2025.
//

import SwiftUI

struct RestaurantInfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("🍽️ Restoran Bilgileri")
                    .font(.largeTitle)
                    .bold()
                
                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    Text("📍 İsim:") + Text(" The Breakfast Club").bold()
                    Text("📌 Konum:") + Text(" 123 Main Street, NY").bold()
                    Text("⭐ Puan:") + Text(" 4.6 / 5").bold()
                }

                Divider()

                Text("💬 Yorumlar")
                    .font(.title2)
                    .padding(.bottom, 5)

                ForEach([
                    "Mükemmel bir kahvaltı deneyimiydi!",
                    "Personel çok nazik ve ortam harika.",
                    "Kruvasanlar efsane, kahve taze ☕️",
                    "Biraz kalabalık ama değiyor."
                ], id: \.self) { comment in
                    Text("• \(comment)")
                        .padding(.vertical, 2)
                }
            }
            .padding()
        }
        .navigationTitle("Restoran")
    }
}
