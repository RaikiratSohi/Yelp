//
//  BusinessCell.swift
//  Yelp
//
//  Created by Raikirat Sohi on 7/23/16.
//  Copyright © 2016 Raikirat Sohi. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var reviewsCountLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var ratingImageView: UIImageView!

    var row: Int!
    var business: Business! {
        didSet {
            nameLabel.text = "\(row + 1). " + business.name!
            distanceLabel.text = business.distance
            if let reviewCount = business.reviewCount {
                reviewsCountLabel.text = "\(reviewCount) Review" + (reviewCount == 1 ? "" : "s")
            }
            priceLabel.text = business.price
            if let address = business.displayAddress.address, let neighborhood = business.displayAddress.neighborhood {
                addressLabel.text = "\(address), \(neighborhood)"
            }
            categoriesLabel.text = business.categories
            if let imageURL = business.imageURL {
                thumbImageView.setImageWithURL(imageURL)
            }
            if let imageURL = business.ratingImageURL {
                ratingImageView.setImageWithURL(imageURL)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        thumbImageView.layer.cornerRadius = 4
        thumbImageView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
