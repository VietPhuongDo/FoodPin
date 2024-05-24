//
//  RestaurantDetailTextCellTableViewCell.swift
//  FoodPin
//
//  Created by PhuongDo on 23/05/2024.
//

import UIKit

class RestaurantDetailTextCell: UITableViewCell {
    @IBOutlet var descriptionLabel:UILabel!{
        didSet{
            descriptionLabel.numberOfLines = 0
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}