//
//  TranslationRecord.swift
//  LinguaLens
//
//  Created by Elif Buse Köprücü on 4.05.2025.
//

import Foundation
import FirebaseFirestoreSwift

struct TranslationRecord: Identifiable, Codable {
    @DocumentID var id: String?
    var originalText: String
    var translatedText: String
    var timestamp: Date
}

