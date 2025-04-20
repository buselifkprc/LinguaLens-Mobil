//
//  Restaurant.swift
//  LinguaLens
//
//  Created by Elif Buse Köprücü on 20.04.2025.
//

import Foundation

struct YelpSearchResult: Decodable {
    let businesses: [Business]
}

struct Business: Decodable {
    let name: String
    let location: Location
    let rating: Double
}

struct Location: Decodable {
    let address1: String
    let city: String
}
