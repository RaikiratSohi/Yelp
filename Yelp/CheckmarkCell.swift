//
//  CheckmarkCell.swift
//  Yelp
//
//  Created by Raikirat Sohi on 7/23/16.
//  Copyright © 2016 Raikirat Sohi. All rights reserved.
//

import UIKit

class CheckmarkCell: UITableViewCell {

    @IBOutlet weak var checkmarkLabel: UILabel!
    @IBOutlet weak var checkmarkImage: UIImageView!

    let cellStateCheckedImage = UIImage(named: "CircleChecked")
    let cellStateUncheckedImage = UIImage(named: "CircleEmpty")
    let cellStateCollapsedImage = UIImage(named: "ExpandArrow")

    enum CellState {
        case Checked, Unchecked, Collapsed
    }

    var state: CellState = CellState.Collapsed {
        didSet {
            switch state {
            case .Checked:
                checkmarkImage.image = cellStateCheckedImage
            case .Unchecked:
                checkmarkImage.image = cellStateUncheckedImage
            case .Collapsed:
                checkmarkImage.image = cellStateCollapsedImage
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
        checkmarkImage.image = cellStateUncheckedImage
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
