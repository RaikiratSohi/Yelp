//
//  BusinessPhotosViewController.swift
//  Yelp
//
//  Created by Raikirat Sohi on 7/23/16.
//  Copyright © 2016 Raikirat Sohi. All rights reserved.
//

import UIKit

class BusinessPhotosViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    var imageLargeURL: NSURL!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let imageLargeURL = imageLargeURL {
            imageView.setImageWithURL(imageLargeURL)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapCloseButton(sender: UIBarButtonItem) {
        parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

}
