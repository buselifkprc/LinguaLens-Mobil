//
//  RestaurantInfoView.swift
//  LinguaLens
//
//  Created by Elif Buse Köprücü on 20.04.2025.
//

import SwiftUI
func getAPIKey() -> String {
    guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
          let dict = NSDictionary(contentsOfFile: path),
          let key = dict["YELP_API_KEY"] as? String else {
        fatalError("Yelp API anahtarı alınamadı.")
    }
    return key
}

struct YelpSearchResponse: Decodable {
    let businesses: [YelpBusiness]
}

struct YelpBusiness: Decodable {
    let name: String
    let location: YelpLocation
    let rating: Double
}

struct YelpLocation: Decodable {
    let address1: String
    let city: String
}

struct RestaurantInfoView: View {
    @State private var restaurantName: String = ""
    @State private var address: String = ""
    @State private var rating: Double = 0.0
    @State private var comments: [String] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("🍽️ Restoran Bilgileri")
                    .font(.largeTitle)
                    .bold()

                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    Text("\(restaurantName)").bold()
                    Text("📍 Konum: \(address)").bold()
                    Text("⭐️ Puan: \(rating, specifier: "%.1f")").bold()
                }

                Divider()

                Text("💬 Yorumlar")
                    .font(.title2)
                    .padding(.bottom, 5)

                ForEach(comments, id: \.self) { comment in
                    Text("• \(comment)")
                }
            }
            .padding()
        }
        .onAppear {
            fetchRestaurantInfo()
            self.restaurantName = "The Mock Breakfast Club"
            self.address = "456 Mockingbird Lane"
            self.rating = 4.7
            self.comments = [
                    "Gerçekten harika bir kahvaltı!",
                    "Servis hızlıydı, tekrar geleceğim.",
                    "Kahve mükemmeldi, ortam çok hoştu."
                ]
        }
    }

    // Yelp API'den veri çekme
    func fetchRestaurantInfo() {
        let apiKey = getAPIKey()
        let term = "The Breakfast Club"
        let location = "New York"
        let baseURL = "https://api.yelp.com/v3/businesses/search"
        let query = "?term=\(term)&location=\(location)"
        let urlString = baseURL + query
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            print("URL encoding başarısız.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API hatası:", error.localizedDescription)
                return
            }

            guard let data = data else {
                print("Veri boş")
                return
            }

            print("Gelen Veri:\n", String(data: data, encoding: .utf8) ?? "Decode edilemedi")

            do {
                let decoded = try JSONDecoder().decode(YelpSearchResponse.self, from: data)
                if let first = decoded.businesses.first {
                    DispatchQueue.main.async {
                        self.restaurantName = first.name
                        self.address = "\(first.location.address1), \(first.location.city)"
                        self.rating = first.rating
                        self.comments = [
                            "Mükemmel servis!",
                            "Harika kahvaltı.",
                            "Biraz kalabalıktı ama değdi."
                        ]
                    }
                }
            } catch {
                print("JSON Parse Hatası:", error.localizedDescription)
            }
        }.resume()
    }
}

#Preview {
    RestaurantInfoView()
}
