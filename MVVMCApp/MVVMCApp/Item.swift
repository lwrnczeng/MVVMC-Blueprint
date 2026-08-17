//
//  Item.swift
//  MVVMCApp
//
//  Created by Lawrence Zeng on 2026-08-13.
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
