//
//  Restaurant.swift
//  FoodPin
//
//  Created by PhuongDo on 21/05/2024.
//

import Foundation

struct Restaurant: Hashable {
    var name: String = ""
    var type: String = ""
    var location: String = ""
    var phone: String = ""
    var description: String = ""
    var image: String = ""
    var isFavorite: Bool = false
}
