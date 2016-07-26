//
//  YelpClient.swift
//  Yelp
//
//  Created by Timothy Lee on 9/19/14.
//  Copyright (c) 2014 Timothy Lee. All rights reserved.
//

import UIKit

import AFNetworking
import BDBOAuth1Manager

//Yelp Api Key
let yelpConsumerKey = "r4jT7YFnj9pcKum8wh_HUw"
let yelpConsumerSecret = "7lLeL66dDLlNvKxmyCOEfYKZwqA"
let yelpToken = "h2PinRz9C5QQwFHTqix0qLnElfmhzgi8"
let yelpTokenSecret = "E93RD39xWN1Fg0mmFh_qxcKSlBE"

enum YelpSortMode: Int {
    case BestMatched = 0, Distance, HighestRated
}

class YelpClient: BDBOAuth1RequestOperationManager {
    var accessToken: String!
    var accessSecret: String!
    
    class var sharedInstance : YelpClient {
        struct Static {
            static var token : dispatch_once_t = 0
            static var instance : YelpClient? = nil
        }
        
        dispatch_once(&Static.token) {
            Static.instance = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        }
        return Static.instance!
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(consumerKey key: String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
        self.accessToken = accessToken
        self.accessSecret = accessSecret
        let baseUrl = NSURL(string: "https://api.yelp.com/v2/")
        super.init(baseURL: baseUrl, consumerKey: key, consumerSecret: secret);
        
        let token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil)
        self.requestSerializer.saveAccessToken(token)
    }
    
    func searchWithTerm(term: String, limit: Int?, offset: Int?, completion: ([Business]!, NSError!) -> Void) -> AFHTTPRequestOperation {
        return searchWithTerm(term, limit: limit, offset: offset, sort: nil, categories: nil, distance: nil, deals: nil, completion: completion)
    }
    
    func searchWithTerm(term: String, limit: Int?, offset: Int?, sort: YelpSortMode?, categories: [String]?, distance: Int?, deals: Bool?, completion: ([Business]!, NSError!) -> Void) -> AFHTTPRequestOperation {
        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api

        // Default the location to San Francisco
        var parameters: [String : AnyObject] = ["term": term, "ll": "\(Constants.DefaultLocation.latitude),\(Constants.DefaultLocation.longitude)"]

        if limit != nil && offset != nil {
            parameters["limit"] = limit
            parameters["offset"] = offset
        }

        if sort != nil {
            parameters["sort"] = sort!.rawValue
        }
        
        if categories != nil && categories!.count > 0 {
            parameters["category_filter"] = (categories!).joinWithSeparator(",")
        }

        if distance != nil && distance != 0 {
            parameters["radius_filter"] = distance!
        }

        if deals != nil {
            parameters["deals_filter"] = deals!
        }
        
        return self.GET(
            "search",
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                if let dictionaries = response["businesses"] as? [NSDictionary] {
                    completion(Business.businesses(array: dictionaries), nil)
                }
            },
            failure: { (operation: AFHTTPRequestOperation?, error: NSError!) -> Void in
                completion(nil, error)
            }
        )!
    }

    func getBusiness(yelpID: String, completion: (Business!, NSError!) -> Void) -> AFHTTPRequestOperation {
        let encodedYelpID = yelpID.stringByAddingPercentEncodingWithAllowedCharacters(.URLPathAllowedCharacterSet())!
        let endpointName = "business/" + encodedYelpID

        return self.GET(
            endpointName,
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                // print(response)
                if let dictionary = response as? NSDictionary {
                    completion(Business(dictionary: dictionary), nil)
                }
            },
            failure: { (operation: AFHTTPRequestOperation?, error: NSError!) -> Void in
                completion(nil, error)
            }
        )!
    }
}
