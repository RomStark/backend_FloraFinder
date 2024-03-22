//
//  User.swift
//  
//
//  Created by Al Stark on 14.03.2024.
//

import Vapor
import Fluent

final class User: Model, Content {
    init() { }
    
    static let schema: String = "users"
    
    @ID var id: UUID?
    
    @Field(key: "name") var name: String
    @Field(key: "login") var login: String
    @Field(key: "password") var password: String
    
    init(
        id: UUID? = nil,
        name: String,
        login: String,
        password: String
    ) {
        self.id = id
        self.name = name
        self.login = login
        self.password = password
    }
    
    final class Public: Content {
        var id: UUID?
        var name: String
        var login: String
        
        init(
            id: UUID? = nil,
            name: String,
            login: String
        ) {
            self.id = id
            self.name = name
            self.login = login
        }
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$login
    
    static var passwordHashKey = \User.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}

extension User {
    func convertToPublic() -> User.Public {
    User.Public(
            id: self.id,
            name: self.name,
            login: self.login
        )
    }
}
