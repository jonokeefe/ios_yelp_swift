
//
//  BusinessCell.swift
//  ChowHunt
//
//  Created by Jon O'Keefe on 10/18/16.
//  Copyright © 2016 Jon O'Keefe. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {

    @IBOutlet weak var businessImageView: UIImageView!
    @IBOutlet weak var businessLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var reviewCountLabel: UILabel!
    
    var business: Business! {
        didSet {
            businessLabel.text = business.name!
            if let imageUrl = business.imageURL {
                businessImageView.setImageWith(imageUrl)
            }
            businessImageView.layer.cornerRadius = 5.0
            businessImageView.clipsToBounds = true
            ratingImageView.setImageWith(business.ratingImageURL!)
            addressLabel.text = business.address!
            distanceLabel.text = business.distance!
            categoriesLabel.text = business.categories!
            reviewCountLabel.text = "\(business.reviewCount!) Reviews"
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)

        // Configure the view for the selected state
    }

}
