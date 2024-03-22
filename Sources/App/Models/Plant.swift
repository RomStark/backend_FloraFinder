//
//  Plant.swift
//  
//
//  Created by Al Stark on 14.03.2024.
//

import Vapor
import Fluent

final class Plant: Model, Content {
    static let schema: String = "plants"
    @ID var id: UUID?
    
    @Field(key: "name") var name: String
    @Field(key: "description") var description: String
    @Field(key: "imageURL") var imageURL: String?
    @Field(key: "minT") var minT: Int
    @Field(key: "maxT") var maxT: Int
    @Field(key: "humidity") var humidity: Int
    @Field(key: "water_interval") var water_interval: Int
    @Field(key: "lighting") var lighting: String
    
}
