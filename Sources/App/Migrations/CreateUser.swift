//
//  CreateUser.swift
//  
//
//  Created by Al Stark on 14.03.2024.
//

import Vapor
import Fluent


struct CreateUser: AsyncMigration {
    func prepare(on database: FluentKit.Database) async throws {
        let schema = database.schema("users")
            .id()
            .field("name", .string, .required)
            .field("login", .string, .required)
            .field("password", .string, .required)
            .unique(on: "login")
        
        try await schema.create()
    }
    
    func revert(on database: FluentKit.Database) async throws {
        try await database.schema("users").delete()
    }
}
