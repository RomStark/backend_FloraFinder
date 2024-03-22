//
//  UserDrug.swift
//  
//
//  Created by Al Stark on 14.03.2024.
//

import Vapor
import Fluent


final class UserDrug: Model, Content {
    @ID var id: UUID?
    
    static let schema: String = "user_drugs"
    
    @Field(key: "name") var name: String
    @Field(key: "price") var price: Int
    @Field(key: "using_method") var using_method: String?
    @Field(key: "imageURL") var imageURL: String?
    @Field(key: "count") var count: Int
    @Parent(key: "user_id") var user: User
    @Parent(key: "drug_id") var drug: Drug
    
    init() { }
    
    init(
        id: UUID? = nil,
        name: String,
        price: Int,
        using_method: String? = nil,
        imageURL: String? = nil,
        count: Int,
        userID: UUID, // Идентификатор пользователя
        drugID: UUID // Идентификатор Drug
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.using_method = using_method
        self.imageURL = imageURL
        self.count = count
        self.$user.id = userID // Устанавливаем идентификатор пользователя
        self.$drug.id = drugID
    }
    
}

public struct userDrugData: Codable {
    var parentDrugId: String
}
