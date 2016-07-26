//
//  MapTableViewCell.swift
//  Yelp
//
//  Created by Raikirat Sohi on 7/23/16.
//  Copyright © 2016 Raikirat Sohi. All rights reserved.
//

import UIKit
import MapKit

class MapTableViewCell: UITableViewCell {

    @IBOutlet weak var mapView: MKMapView!

    var business: Business!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        mapView.userInteractionEnabled = false

        addAnnotationForBusiness(business)
    }

}

// MARK: - Map related methods

extension MapTableViewCell {

    private func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
    }

    private func addAnnotationForBusiness(businesses: Business) {
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations(annotationsToRemove)

        let coordinate = CLLocationCoordinate2D(latitude: business.coordinate.latitude!, longitude: business.coordinate.longitude!)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = business.name
        mapView.addAnnotation(annotation)

        centerAndZoomMapAroundBusiness(business)
    }

    private func centerAndZoomMapAroundBusiness(business: Business) {
        if let latitude = business.coordinate.latitude, longitude = business.coordinate.longitude {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let span = MKCoordinateSpanMake(0.005, 0.005)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            mapView.setRegion(region, animated: false)
        }
    }

}
