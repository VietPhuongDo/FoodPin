//
//  RestaurantDetailControllerViewController.swift
//  FoodPin
//
//  Created by PhuongDo on 22/05/2024.
//

import UIKit

class RestaurantDetailViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: RestaurantDetailHeaderView!
    
    var detailRestaurant:Restaurant = Restaurant()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        
        headerView.nameLabel.text = detailRestaurant.name
        headerView.typeLabel.text = detailRestaurant.type
        headerView.headerImageView.image = UIImage(named: detailRestaurant.image)
        headerView.heartButton.setTitle("", for: .normal)
        
        if(detailRestaurant.isFavorite == true){
            let heartImage = "heart.fill"
            headerView.heartButton.tintColor = .systemYellow
            headerView.heartButton.setImage(UIImage(systemName: heartImage), for: .normal)
        }
        else{
            let heartImage = "heart"
            headerView.heartButton.tintColor = .white
            headerView.heartButton.setImage(UIImage(systemName: heartImage), for: .normal)
        }
    }


}
