//
//  UsersController.swift
//  
//
//  Created by Al Stark on 14.03.2024.
//

import Vapor


struct UsersController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let usersGroup = routes.grouped("users")
        
        // Регистраиция пользователя
        usersGroup.post("signIn", use: createHandler)
        usersGroup.post("auth", use: authHandler)
        
//        // Аутентификация пользователя
//        routes.post("login", use: loginHandler)
        
        let basicMW = User.authenticator()
        let guardMW = User.guardMiddleware()
        let protectedGroup = usersGroup.grouped(basicMW, guardMW)
        
        // MARK: Plant
        
        // Добавление растения пользователю
        protectedGroup.post("plants", use: addPlantHandler)
        
        // Обновление растения пользователя:
        protectedGroup.put("plants", ":plantId", use: updatePlantHandler)
        
        // Удаление растения пользователя:
        protectedGroup.delete("plants", ":plantId", use: deletePlantHandler)
        
        // получение всех растений пользователя:
        protectedGroup.get("plants", use: getAllPlantsHandler)
        
        // получение растение по id пользователя:
        protectedGroup.get("plants", ":plantId", use: getPlantHandler)
        
        // MARK: Drug
        
        // Добавление препарата пользователю
        protectedGroup.post("drugs", use: addDrugHandler)
        
        // Обновление препарата пользователя:
        protectedGroup.put("drugs", ":drugtId", use: updateDrugHandler)
        
        // Удаление препарата пользователя:
        protectedGroup.delete("drugs", ":drugtId", use: deleteDrugHandler)
        
        // получение всех препарата пользователя:
        protectedGroup.get("drugs", use: getAllDrugsHandler)
        
        // получение препарата по id пользователя:
        protectedGroup.get("drugs", ":drugId", use: getDrugHandler)
        
        usersGroup.get(use: getAllHandler)
        protectedGroup.get(use: getHandler)
    }

    
    func createHandler(_ req: Request) async throws -> User.Public {
        let userInfo = try req.content.decode(UserInfo.self)
        let password = try Bcrypt.hash(userInfo.password)

        let user = User(
            name: userInfo.name,
            login: userInfo.login,
            password: password
        )
        
        try await user.save(on: req.db)
        return user.convertToPublic()
    }
    
    func getAllHandler(_ req: Request) async throws -> [User.Public] {
        let users = try await User.query(on: req.db).all()
        return users.map { $0.convertToPublic() }
    }
    
    func putHandler(_ req: Request)  async throws -> User.Public {
        let user = try req.content.decode(User.self)
        
        try await user.save(on: req.db)
        return user.convertToPublic()
    }
    
    func getHandler(_ req: Request) async throws -> User.Public {
        guard let user = req.auth.get(User.self) else {
            throw Abort(.unauthorized)
        }
        return user.convertToPublic()
    }
    
    func authHandler(_ req: Request) async throws -> User.Public {
        let userDTO = try req.content.decode(AuthUserDTO.self)
        guard let user = try await User
            .query(on: req.db)
            .filter("login", .equal, userDTO.login)
            .first() else {
            throw Abort(.unauthorized)
        }
        
        let isPassEqual = try Bcrypt.verify(userDTO.password, created: user.password)
        
        guard isPassEqual else {
            throw Abort(.unauthorized)
        }
        
        return user.convertToPublic()
    }
}

struct AuthUserDTO: Content {
    let login: String
    var password: String
}

public struct UserInfo: Codable {
    var name: String
    var login: String
    var password: String
}

// MARK: plant
extension UsersController {
    func addPlantHandler(_ req: Request) async throws -> HTTPStatus {
        guard let user = req.auth.get(User.self) else {
            throw Abort(.unauthorized)
        }
        let plant = try req.content.decode(userPlantData.self)
        let userPlant = UserPlant(
            givenName: plant.givenName,
            name: plant.name,
            description: plant.description,
            imageURL: plant.imageURL,
            minT: plant.minT,
            maxT: plant.maxT,
            humidity: plant.humidity,
            water_interval: plant.water_interval,
            lighting: plant.lighting,
            userID: user.id! // Устанавливаем идентификатор пользователя для растения
        )
        try await userPlant.save(on: req.db)
        
        return .created
    }
    
    func updatePlantHandler(_ req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        let plantId = try req.parameters.require("plantId", as: UUID.self)
        let updatedPlant = try req.content.decode(userPlantData.self)
        
        
        guard let plant = try await UserPlant.find(plantId, on: req.db) else {
            throw Abort(.notFound)
        }
        
       
        plant.givenName = updatedPlant.givenName
        plant.imageURL = updatedPlant.imageURL
        
        // Сохранение пользователя
        try await plant.update(on: req.db)
        
        return .ok
    }
    
    func deletePlantHandler(_ req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        let plantId = try req.parameters.require("plantId", as: UUID.self)
        guard let plant = try await UserPlant.find(plantId, on: req.db) else {
            throw Abort(.notFound)
        }
       
        try await plant.delete(on: req.db)
        
        return .ok
    }
    
    func getAllPlantsHandler(_ req: Request) async throws -> [UserPlant] {
        let user = try req.auth.require(User.self)
        
        let plants = try await UserPlant.query(on: req.db)
            .filter(\UserPlant.$user.$id, .equal, user.requireID())
            .all()
        
        return plants
    }
    
    func getPlantHandler(_ req: Request) async throws -> UserPlant {
        let user = try req.auth.require(User.self)
        let plantId = try req.parameters.require("plantId", as: UUID.self)
        
        guard let plant = try await UserPlant.find(plantId, on: req.db) else {
            throw Abort(.notFound)
        }
        
        return plant
    }
}


// MARK: - Drugs
extension UsersController {
    func addDrugHandler(_ req: Request) async throws -> HTTPStatus {
        guard let user = req.auth.get(User.self) else {
            throw Abort(.unauthorized)
        }
        
        let drugData = try req.content.decode(userDrugData.self)
        
        guard let drugId = UUID(uuidString: drugData.parentDrugId) else {
            return .notFound
        }
        
        
        guard let drug = try await Drug.find(drugId, on: req.db) else {
            print(1)
            return .notFound
        }
            
        
        let userDrug = UserDrug(
            name: drug.name,
            price: drug.price,
            count: 1,
            userID: user.id!,
            drugID: drug.id!
        )
        
        try await userDrug.save(on: req.db)
        
        return .created
    }
    
    func updateDrugHandler(_ req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        let drugId = try req.parameters.require("drugId", as: UUID.self)
        
        
        
        guard let drug = try await UserDrug.find(drugId, on: req.db) else {
            throw Abort(.notFound)
        }
        
        drug.count += 1
        
        // Сохранение пользователя
        try await drug.update(on: req.db)
        
        return .ok
    }
    
    func getAllDrugsHandler(_ req: Request) async throws -> [UserDrug] {
        let user = try req.auth.require(User.self)
        let drugs = try await UserDrug.query(on: req.db)
            .filter(\UserDrug.$user.$id, .equal, user.requireID())
            .all()
        
        return drugs
    }
    
    func getDrugHandler(_ req: Request) async throws -> UserDrug {
        let user = try req.auth.require(User.self)
        let drugId = try req.parameters.require("drugId", as: UUID.self)
        
        guard let drug = try await UserDrug.find(drugId, on: req.db) else {
            throw Abort(.notFound)
        }
        
        return drug
    }
    
    func deleteDrugHandler(_ req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        let drugId = try req.parameters.require("drugId", as: UUID.self)
        guard let drug = try await UserDrug.find(drugId, on: req.db) else {
            throw Abort(.notFound)
        }
       
        try await drug.delete(on: req.db)
        
        return .ok
    }
}
