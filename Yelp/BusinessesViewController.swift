//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import MBProgressHUD

class BusinessesViewController: UIViewController, UISearchBarDelegate {

    var businesses: [Business]!
    var lastSearchTerm = "Restaurants"
    var lastSearchFilters: [String: AnyObject]?

    let searchDefaultLimit = 20
    let searchDefaultOffset = 0
    var searchCurrentLimit = 20
    var searchCurrentOffset = 0
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?

    var searchBar: UISearchBar!

    enum ViewMode: String {
        case List = "List"
        case Map = "Map"
    }

    var currentViewMode = ViewMode.List

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Search", style: .Plain, target: nil, action: nil)

        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90

        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)

        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets

        // Set tableView footer to an empty view to prevent empty cells from being rendered
        tableView.tableFooterView = UIView(frame: CGRectZero)

        // Run initial search
        searchWithTerm(lastSearchTerm, limit: searchDefaultLimit, offset: searchDefaultOffset)
        searchBar.text = lastSearchTerm

        // set the region to display, this also sets a correct zoom level
        // set starting center location in San Francisco
        let centerLocation = CLLocation(latitude: Constants.DefaultLocation.latitude, longitude: Constants.DefaultLocation.longitude)
        goToLocation(centerLocation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "FiltersSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let filterViewController = navigationController.topViewController as! FilterViewController
            filterViewController.delegate = self
        } else if segue.identifier == "BusinessDetailSegue" {
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
            let businessDetailVC = segue.destinationViewController as! BusinessDetailViewController
            businessDetailVC.business = businesses[indexPath.row]
        }
    }

    @IBAction func didToggleViewMode(sender: UIBarButtonItem) {
        if currentViewMode == .List {
            currentViewMode = .Map
            UIView.transitionWithView(
                view,
                duration: 0.5,
                options: [.TransitionFlipFromRight],
                animations: {
                    self.tableView.hidden = true
                    self.mapView.hidden = false
                },
                completion: nil
            )
            sender.title = ViewMode.List.rawValue
        } else {
            currentViewMode = .List
            UIView.transitionWithView(
                view,
                duration: 0.5,
                options: [.TransitionFlipFromLeft],
                animations: {
                    self.tableView.hidden = false
                    self.mapView.hidden = true
                },
                completion: nil
            )
            sender.title = ViewMode.Map.rawValue
        }
    }

    // MARK: - Search

    private func searchWithTerm(term: String, limit: Int?, offset: Int?) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        Business.searchWithTerm(term, limit: limit, offset: offset, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.businesses = businesses
            self.tableView.reloadData()
            // Need to ensure we have at least one business otherwise we will crash when scrolling to a row that does not exist.
            if businesses.count > 0 {
                self.tableView.backgroundView = nil
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
            } else {
                 let emptyStateView = BusinessesEmptyState()
                emptyStateView.searchTerm = term
                self.tableView.backgroundView = emptyStateView
            }
            self.addAnnotationForBusinesses(self.businesses)
        })
    }

    private func searchWithTerm(term: String, limit: Int?, offset: Int?, filters: [String: AnyObject]) {
        let deals = filters["deals"] as? Bool
        let distance = filters["distance"] as? Int
        let sortBy = filters["sortBy"] as? Int
        let categories = filters["categories"] as? [String]
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        Business.searchWithTerm(lastSearchTerm, limit: limit, offset: offset, sort: YelpSortMode(rawValue: sortBy!), categories: categories, distance: distance, deals: deals) { (businesses: [Business]!, error: NSError!) -> Void in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.businesses = businesses
            self.tableView.reloadData()
            // Need to ensure we have at least one business otherwise we will crash when scrolling to a row that does not exist.
            if businesses.count > 0 {
                 self.tableView.backgroundView = nil
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
            } else {
                let emptyStateView = BusinessesEmptyState()
                emptyStateView.searchTerm = term
                self.tableView.backgroundView = emptyStateView
            }
            self.addAnnotationForBusinesses(self.businesses)
        }
    }

    private func loadMoreData() {
        searchCurrentOffset += searchDefaultLimit
        if lastSearchFilters == nil {
            Business.searchWithTerm(lastSearchTerm, limit: searchDefaultLimit, offset: searchCurrentOffset, completion: { (businesses: [Business]!, error: NSError!) -> Void in
                self.isMoreDataLoading = false

                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()

                for business in businesses {
                    self.businesses.append(business)
                }
                self.tableView.reloadData()

                self.addAnnotationForBusinesses(self.businesses)
            })
        } else {
            let deals = lastSearchFilters!["deals"] as? Bool
            let distance = lastSearchFilters!["distance"] as? Int
            let sortBy = lastSearchFilters!["sortBy"] as? Int
            let categories = lastSearchFilters!["categories"] as? [String]
            Business.searchWithTerm(lastSearchTerm, limit: searchDefaultLimit, offset: searchCurrentOffset, sort: YelpSortMode(rawValue: sortBy!), categories: categories, distance: distance, deals: deals) { (businesses: [Business]!, error: NSError!) -> Void in
                self.isMoreDataLoading = false

                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()

                for business in businesses {
                    self.businesses.append(business)
                }
                self.tableView.reloadData()

                self.addAnnotationForBusinesses(self.businesses)
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension BusinessesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let businesses = businesses {
            return businesses.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell

        // Reset content to defaults
        cell.nameLabel.text = nil
        cell.distanceLabel.text = nil
        cell.reviewsCountLabel.text = nil
        cell.addressLabel.text = nil
        cell.categoriesLabel.text = nil
        cell.thumbImageView.image = nil
        cell.ratingImageView.image = nil

        // Set new content
        cell.row = indexPath.row
        cell.business = businesses[indexPath.row]

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

// MARK: - UIScrollViewDelegate

extension BusinessesViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if !isMoreDataLoading {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height

            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true

                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()

                loadMoreData()
            }
        }
    }
}

// MARK: - UISearchBarDelegate

extension BusinessesViewController {

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let searchTerm = searchBar.text!
        lastSearchTerm = searchTerm
        lastSearchFilters = nil
        searchCurrentOffset = searchDefaultOffset
        searchWithTerm(searchTerm, limit: searchDefaultLimit, offset: searchDefaultOffset)
        searchBar.resignFirstResponder()
    }
}

// MARK: - FilterViewControllerDelegate

extension BusinessesViewController: FilterViewControllerDelegate {
    func filterViewController(filterViewController: FilterViewController, didUpdateFilters filters: [String: AnyObject]) {
        lastSearchFilters = filters
        searchCurrentOffset = searchDefaultOffset
        searchWithTerm(lastSearchTerm, limit: searchDefaultLimit, offset: searchDefaultOffset, filters: filters)
    }
}

// MARK: - Map related methods

extension BusinessesViewController {

    private func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
    }

    private func addAnnotationForBusinesses(businesses: [Business]) {
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations(annotationsToRemove)

        for business in businesses {
            let coordinate = CLLocationCoordinate2D(latitude: business.coordinate.latitude!, longitude: business.coordinate.longitude!)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = business.name
            mapView.addAnnotation(annotation)
        }

        zoomMapToFitAnnotationsForBusiness(businesses)
    }

    private func zoomMapToFitAnnotationsForBusiness(businesses: [Business]) {
        let rectToDisplay = self.businesses.reduce(MKMapRectNull) { (mapRect: MKMapRect, business: Business) -> MKMapRect in
            let coordinate = CLLocationCoordinate2D(latitude: business.coordinate.latitude!, longitude: business.coordinate.longitude!)
            let businessPointRect = MKMapRect(origin: MKMapPointForCoordinate(coordinate), size: MKMapSize(width: 0, height: 0))
            return MKMapRectUnion(mapRect, businessPointRect)
        }
        self.mapView.setVisibleMapRect(rectToDisplay, edgePadding: UIEdgeInsetsMake(74, 20, 20, 20), animated: false)
    }
}
