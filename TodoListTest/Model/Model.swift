//
//  Model.swift
//  TodoListTest
//
//  Created by Антон Баскаков on 25.08.2024.
//

import Foundation

// MARK: - Welcome
struct DataModel: Codable {
    let todos: [Todo]
    let total, skip, limit: Int
    
    enum CodingKeys: CodingKey {
        case todos, total, skip, limit
    }
}

// MARK: - Todo
struct Todo: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
//    let dateAdded = Date.now
//    var todoDescription: String?

    enum CodingKeys: CodingKey {
        case id, todo, completed, userId/*, dateAdded, todoDescription*/
    }
}
