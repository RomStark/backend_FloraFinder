//
//  Drug.swift
//  
//
//  Created by Al Stark on 14.03.2024.
//

import Vapor
import Fluent


final class Drug: Model, Content {
    static let schema: String = "drugs"
    
    @ID var id: UUID?
    
    @Field(key: "name") var name: String
    @Field(key: "price") var price: Int
    @Field(key: "description") var description: String
    @Field(key: "using_method") var using_method: String?
    @Field(key: "imageURL") var imageURL: String?
    
}
