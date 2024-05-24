//
//  ReviewViewController.swift
//  FoodPin
//
//  Created by PhuongDo on 24/05/2024.
//

import UIKit

class ReviewViewController: UIViewController {
    @IBOutlet var backgroundImageView: UIImageView!
    var restaurant = Restaurant()

    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundImageView.image = UIImage(named: restaurant.image)
    }
    


    

}
