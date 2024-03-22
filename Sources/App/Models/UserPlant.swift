//
//  UserPlant.swift
//  
//
//  Created by Al Stark on 14.03.2024.
//

import Vapor
import Fluent


final class UserPlant: Model, Content {
    @ID var id: UUID?
    
    static let schema: String = "user_plants"
    
    @Field(key: "givenName") var givenName: String
    @Field(key: "name") var name: String
    @Field(key: "description") var description: String
    @Field(key: "imageURL") var imageURL: String?
    @Field(key: "minT") var minT: Int
    @Field(key: "maxT") var maxT: Int
    @Field(key: "humidity") var humidity: Int
    @Field(key: "water_interval") var water_interval: Int
    @Field(key: "lighting") var lighting: String
    @Parent(key: "user_id") var user: User
    
    init() { }
    
    init(
        id: UUID? = nil,
        givenName: String,
        name: String,
        description: String,
        imageURL: String? = nil,
        minT: Int,
        maxT: Int,
        humidity: Int,
        water_interval: Int,
        lighting: String,
        userID: UUID // Идентификатор пользователя
    ) {
        self.id = id
        self.givenName = givenName
        self.name = name
        self.description = description
        self.imageURL = imageURL
        self.minT = minT
        self.maxT = maxT
        self.humidity = humidity
        self.water_interval = water_interval
        self.lighting = lighting
        self.$user.id = userID // Устанавливаем идентификатор пользователя
    }
}


public struct userPlantData: Codable {
    var givenName: String
    var name: String
    var description: String
    var imageURL: String?
    var minT: Int
    var maxT: Int
    var humidity: Int
    var water_interval: Int
    var lighting: String
}
