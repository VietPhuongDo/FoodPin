//
//  RestaurantDiffableDataSource.swift
//  FoodPin
//
//  Created by PhuongDo on 22/05/2024.
//

import UIKit

enum Section{
    case all
}

class RestaurantDiffableDataSource: UITableViewDiffableDataSource<Section,Restaurant> {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    

}
