//
//  CreateDrug.swift
//  
//
//  Created by Al Stark on 14.03.2024.
//

import Vapor
import Fluent


struct CreateDrug: AsyncMigration {
    func prepare(on database: FluentKit.Database) async throws {
        let schema = database.schema("drugs")
            .id()
            .field("name", .string, .required)
            .field("description", .string, .required)
            .field("using_method", .string)
            .field("imageURL", .string)
            .field("price", .int, .required)
        
        try await schema.create()
    }
    
    func revert(on database: FluentKit.Database) async throws {
        try await database.schema("drugs").delete()
    }
}
