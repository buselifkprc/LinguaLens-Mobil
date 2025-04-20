//
//  Item.swift
//  LinguaLens
//
//  Created by Elif Buse Köprücü on 20.04.2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
