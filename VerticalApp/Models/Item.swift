//
//  Item.swift
//  VerticalApp
//
//  Model for app items
//

import Foundation

struct Item: Identifiable, Codable {
    let id: UUID
    let title: String
    let subtitle: String?
    var isCompleted: Bool
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String? = nil,
        isCompleted: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}
