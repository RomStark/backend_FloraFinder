//
//  CreateUserDrug.swift
//  
//
//  Created by Al Stark on 14.03.2024.
//

import Vapor
import Fluent

struct CreateUserDrug: AsyncMigration {
    func prepare(on database: FluentKit.Database) async throws {
        let schema = database.schema("user_drugs")
            .id()
            .field("name", .string, .required)
            .field("using_method", .string)
            .field("imageURL", .string)
            .field("price", .int, .required)
            .field("count", .int, .required)
            .field("user_id", .uuid, .required, .references("users", "id"))
            .field("drug_id", .uuid, .required, .references("drugs", "id"))
        
        try await schema.create()
    }

    func revert(on database: FluentKit.Database) async throws {
        try await database.schema("user_drugs").delete()
    }
}
