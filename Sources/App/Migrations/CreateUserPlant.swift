//
//  CreateUserPlant.swift
//  
//
//  Created by Al Stark on 14.03.2024.
//

import Vapor
import Fluent

struct CreateUserPlant: AsyncMigration {
    func prepare(on database: FluentKit.Database) async throws {
        let schema = database.schema("user_plants")
            .id()
            .field("givenName", .string, .required)
            .field("name", .string, .required)
            .field("description", .string, .required)
            .field("imageURL", .string)
            .field("minT", .int, .required)
            .field("maxT", .int, .required)
            .field("humidity", .int, .required)
            .field("water_interval", .int, .required)
            .field("lighting", .string, .required)
            .field("user_id", .uuid, .required, .references("users", "id"))
        
        try await schema.create()
    }

    func revert(on database: FluentKit.Database) async throws {
        try await database.schema("user_plants").delete()
    }
}
