//
//  PlantsController.swift
//  
//
//  Created by Al Stark on 14.03.2024.
//

import Vapor


struct PlantsController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let usersGroup = routes.grouped("plants")
        usersGroup.post(use: createHandler)
        usersGroup.get(use: getAllHandler)
        usersGroup.get(":id", use: getHandler)
    }
    
    func createHandler(_ req: Request) async throws -> Plant {
        let plant = try req.content.decode(Plant.self)
        try await plant.save(on: req.db)
        return plant
    }
    
    func getAllHandler(_ req: Request) async throws -> [Plant] {
        let plants = try await Plant.query(on: req.db).all()
        return plants
    }
    
    func getHandler(_ req: Request) async throws -> Plant {
        guard let plant = try await Plant.find(
            req.parameters.get("id"),
            on: req.db
        ) else {
            throw Abort(.notFound)
        }
        
        return plant
    }
}
