//
//  Business.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class Business: NSObject {
    let yelpID: String?
    let name: String?
    var displayAddress = DisplayAddress()
    let imageURL: NSURL?
    let imageLargeURL: NSURL?
    let phoneNumber: String?
    let price: String?
    let categories: String?
    let distance: String?
    let ratingImageURL: NSURL?
    let reviewCount: NSNumber?
    var coordinate = Coordinate()

    struct Coordinate {
        var latitude: Double?
        var longitude: Double?
    }

    struct DisplayAddress {
        var address: String?
        var neighborhood: String?
        var cityStatePostal: String?
        var crossStreets: String?
    }

    init(dictionary: NSDictionary) {
        yelpID = dictionary["id"] as? String
        name = dictionary["name"] as? String
        
        if let imageURLString = dictionary["image_url"] as? String {
            imageURL = NSURL(string: imageURLString)!
            imageLargeURL = NSURL(fileURLWithPath: "l.jpg", relativeToURL: imageURL!.URLByDeletingLastPathComponent)
        } else {
            imageURL = nil
            imageLargeURL = nil
        }

        if let displayPhone = dictionary["display_phone"] as? String {
            phoneNumber = displayPhone
        } else {
            phoneNumber = nil
        }

        // Price is not available from API, so just fake it.
        price = "$$$"

        if let location = dictionary["location"] as? NSDictionary {

            if let displayAddress = location["display_address"] as? NSArray where displayAddress.count >= 3 {
                if let address = displayAddress[0] as? String {
                    self.displayAddress.address = address
                }
                if let neighborhood = displayAddress[1] as? String {
                    self.displayAddress.neighborhood = neighborhood
                }
                if let cityStatePostal = displayAddress[2] as? String {
                    self.displayAddress.cityStatePostal = cityStatePostal
                }
            }

            if let crossStreets = location["cross_streets"] as? String {
                self.displayAddress.crossStreets = crossStreets
            }

            if let coordinatesDictionary = location["coordinate"] as? NSDictionary {
                if let latitude = coordinatesDictionary["latitude"] as? Double {
                    coordinate.latitude = latitude
                }
                if let longitude = coordinatesDictionary["longitude"] as? Double {
                    coordinate.longitude = longitude
                }
            }
        }

        let categoriesArray = dictionary["categories"] as? [[String]]
        if categoriesArray != nil {
            var categoryNames = [String]()
            for category in categoriesArray! {
                let categoryName = category[0]
                categoryNames.append(categoryName)
            }
            categories = categoryNames.joinWithSeparator(", ")
        } else {
            categories = nil
        }
        
        if let distanceMeters = dictionary["distance"] as? NSNumber {
            let milesPerMeter = 0.000621371
            distance = String(format: "%.2f mi", milesPerMeter * distanceMeters.doubleValue)
        } else {
            distance = nil
        }
        
        let ratingImageURLString = dictionary["rating_img_url_large"] as? String
        if ratingImageURLString != nil {
            ratingImageURL = NSURL(string: ratingImageURLString!)
        } else {
            ratingImageURL = nil
        }
        
        reviewCount = dictionary["review_count"] as? NSNumber
    }
    
    class func businesses(array array: [NSDictionary]) -> [Business] {
        var businesses = [Business]()
        for dictionary in array {
            let business = Business(dictionary: dictionary)
            businesses.append(business)
        }
        return businesses
    }
    
    class func searchWithTerm(term: String, limit: Int?, offset: Int?, completion: ([Business]!, NSError!) -> Void) {
        YelpClient.sharedInstance.searchWithTerm(term, limit: limit, offset: offset, completion: completion)
    }
    
    class func searchWithTerm(term: String, limit: Int?, offset: Int?, sort: YelpSortMode?, categories: [String]?, distance: Int?, deals: Bool?, completion: ([Business]!, NSError!) -> Void) -> Void {
        YelpClient.sharedInstance.searchWithTerm(term, limit: limit, offset: offset, sort: sort, categories: categories, distance: distance, deals: deals, completion: completion)
    }
}
