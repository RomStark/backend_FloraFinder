//
//  DrugsController.swift
//  
//
//  Created by Al Stark on 14.03.2024.
//

import Vapor


struct DrugsController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let usersGroup = routes.grouped("drugs")
        usersGroup.post(use: createHandler)
        usersGroup.get(use: getAllHandler)
        usersGroup.get(":id", use: getHandler)
    }
    
    func createHandler(_ req: Request) async throws -> Drug {
        let drug = try req.content.decode(Drug.self)
        try await drug.save(on: req.db)
        return drug
    }
    
    func getAllHandler(_ req: Request) async throws -> [Drug] {
        let drugs = try await Drug.query(on: req.db).all()
        return drugs
    }
    
    func getHandler(_ req: Request) async throws -> Drug {
        guard let drug = try await Drug.find(
            req.parameters.get("id"),
            on: req.db
        ) else {
            throw Abort(.notFound)
        }
        
        return drug
    }
}
