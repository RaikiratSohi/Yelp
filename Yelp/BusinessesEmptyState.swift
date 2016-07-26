//
//  BusinessesEmptyState.swift
//  Yelp
//
//  Created by Raikirat Sohi on 7/23/16.
//  Copyright © 2016 Raikirat Sohi. All rights reserved.
//

import UIKit

class BusinessesEmptyState: UIView {

    @IBOutlet weak var noResultsLabel: UILabel!

    @IBOutlet var contentView: UIView!

    var searchTerm: String! {
        didSet {
            noResultsLabel.text = "No results for \(searchTerm)."
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    func initSubviews() {
        // standard initialization logic
        let nib = UINib(nibName: "BusinessesEmptyState", bundle: nil)
        nib.instantiateWithOwner(self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
    }

}
