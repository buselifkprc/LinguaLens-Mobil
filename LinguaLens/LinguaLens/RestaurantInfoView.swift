//
//  RestaurantInfoView.swift
//  LinguaLens
//
//  Created by Elif Buse Köprücü on 20.04.2025.
//

import SwiftUI

struct RestaurantInfoView: View {
    let restaurantName = "Cafe Delight"
    let rating = 4.6
    let address = "123 Main Street, Istanbul"
    let description = "Taze kahveler, tatlılar ve samimi ortamıyla bilinir."

    let reviews = [
        "☕ Harika bir kahve deneyimi yaşadım!",
        "🍰 Tatlılar gerçekten çok lezzetliydi.",
        "👩‍🍳 Personel çok ilgili ve güleryüzlüydü.",
        "🪑 Ortamı çok sevdim, sakin ve huzurlu."
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(restaurantName)
                    .font(.largeTitle)
                    .bold()

                HStack {
                    Text("⭐️ \(rating, specifier: "%.1f")")
                    Text(address)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Text(description)
                    .padding(.vertical)

                Divider()

                Text("💬 Kullanıcı Yorumları")
                    .font(.headline)

                ForEach(reviews, id: \.self) { review in
                    Text("• \(review)")
                        .padding(.vertical, 4)
                }
            }
            .padding()
        }
        .navigationTitle("Restoran Bilgisi")
    }
}

#Preview {
    NavigationStack {
        RestaurantInfoView()
    }
}

