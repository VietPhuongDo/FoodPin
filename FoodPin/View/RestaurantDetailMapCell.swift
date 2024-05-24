//
//  RestaurantDetailMapCell.swift
//  FoodPin
//
//  Created by PhuongDo on 24/05/2024.
//

import UIKit
import MapKit

class RestaurantDetailMapCell: UITableViewCell {
    @IBOutlet var mapView: MKMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(location:String){
        let geoCoder = CLGeocoder()
        print(location)
        geoCoder.geocodeAddressString(location) { placemarks, error in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            if let placemarks = placemarks{
                //get first placemark
                let placemark = placemarks[0]
                let annotation = MKPointAnnotation()
                if let location = placemark.location{
                    //Show the location
                    annotation.coordinate = location.coordinate
                    self.mapView.addAnnotation(annotation)
                    
                    //Set zoom
                    let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
                    self.mapView.setRegion(region, animated: true)
                }
            }
        }
    }

}
