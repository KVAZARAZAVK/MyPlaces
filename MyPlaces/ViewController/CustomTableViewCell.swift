//
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by Anatoly Valkov on 6/8/20.
//  Copyright © 2020 Anatoly Valkov. All rights reserved.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet {
            imageOfPlace?.layer.cornerRadius = imageOfPlace.frame.size.height / 2
            imageOfPlace?.clipsToBounds      = true
        }
    }
    @IBOutlet weak var nameLabel    : UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel    : UILabel!
    @IBOutlet weak var cosmosView   : CosmosView! {
        didSet {
            cosmosView.settings.updateOnTouch = false
            cosmosView.backgroundColor        = super.contentView.backgroundColor
        }
    }
    
    func configureCell(place: Place) {
        nameLabel?.text     = place.name
        locationLabel.text  = place.location
        typeLabel.text      = place.type
        guard let image     = place.imageData else { return }
        imageOfPlace.image  = UIImage(data: image)
        cosmosView.rating   = place.rating
    }
}
