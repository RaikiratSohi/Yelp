//
//  FilterViewController.swift
//  Yelp
//
//  Created by Raikirat Sohi on 7/23/16.
//  Copyright © 2016 Raikirat Sohi. All rights reserved.
//

import UIKit

@objc protocol FilterViewControllerDelegate {
    optional func filterViewController(filterViewController: FilterViewController, didUpdateFilters filters: [String: AnyObject])
}

class FilterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    weak var delegate: FilterViewControllerDelegate?

    enum SectionDisplayMode {
        case Expanded, Collapsed
    }

    var filters = [String: AnyObject]()

    var offeringDealChoice = false

    var distanceDisplayMode = SectionDisplayMode.Collapsed
    var distanceChoice = Filter.distance[0]
    var distanceRowData = [Filter.distance[0]]
    var distanceRowStates = [Bool](count: Filter.distance.count, repeatedValue: false)

    var sortByDisplayMode = SectionDisplayMode.Collapsed
    var sortByChoice = Filter.sortBy[0]
    var sortByRowData = [Filter.sortBy[0]]
    var sortByRowStates = [Bool](count: Filter.sortBy.count, repeatedValue: false)

    var categoriesDisplayMode = SectionDisplayMode.Collapsed
    var categoriesRowData = [Filter.categories[0], Filter.categories[1], Filter.categories[2], ["name": "Show All", "code": "show_all"]]
    var categoriesSwitchStates = [Int: Bool]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        distanceRowStates[0] = true
        sortByRowStates[0] = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onSearchButton(sender: UIBarButtonItem) {
        // Deals
        filters["deals"] = offeringDealChoice

        // Distance
        filters["distance"] = distanceChoice["code"] as? Int

        // Sort By
        filters["sortBy"] = sortByChoice["code"] as? Int

        // Categories
        var selectedCategories = [String]()
        for (row, isSelected) in categoriesSwitchStates {
            if isSelected {
                selectedCategories.append(Filter.categories[row]["code"]!)
            }
        }
        filters["categories"] = selectedCategories.count > 0 ? selectedCategories : nil

        delegate?.filterViewController?(self, didUpdateFilters: filters)
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onCancelButton(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - UITableViewDataSource/UITableViewDelegate

extension FilterViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Filter.sections.count
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Filter.sections[section]
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return distanceRowData.count
        case 2:
            return sortByRowData.count
        case 3:
            return categoriesRowData.count
        default:
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell") as! SwitchCell
            cell.delegate = self
            cell.switchLabel.text = "Offering a Deal"
            cell.switchToggle.on = offeringDealChoice
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("CheckmarkCell") as! CheckmarkCell
            cell.checkmarkLabel.text = distanceRowData[indexPath.row]["name"] as? String

            if distanceDisplayMode == .Collapsed {
                cell.state = .Collapsed
            } else {
                cell.state = distanceRowStates[indexPath.row] ? .Checked : .Unchecked
            }
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("CheckmarkCell") as! CheckmarkCell
            cell.checkmarkLabel.text = sortByRowData[indexPath.row]["name"] as? String
            if sortByDisplayMode == .Collapsed {
                cell.state = .Collapsed
            } else {
                cell.state = sortByRowStates[indexPath.row] ? .Checked : .Unchecked
            }
            return cell
        } else {
            if categoriesDisplayMode == .Collapsed && indexPath.row == categoriesRowData.count - 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("ShowAllCell") as! ShowAllCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell") as! SwitchCell
                cell.delegate = self
                cell.switchLabel.text = Filter.categories[indexPath.row]["name"]
                cell.switchToggle.on = categoriesSwitchStates[indexPath.row] ?? false
                return cell
            }
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            if distanceDisplayMode == .Collapsed {
                distanceDisplayMode = .Expanded

                distanceRowData = Filter.distance
                var indexPaths = [NSIndexPath]()
                for row in 0..<distanceRowData.count {
                    indexPaths.append(NSIndexPath(forRow: row, inSection: indexPath.section))
                }

                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: indexPath.section)], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
                tableView.endUpdates()
            } else {
                distanceDisplayMode = .Collapsed

                let cell = tableView.cellForRowAtIndexPath(indexPath) as! CheckmarkCell
                cell.state = .Checked

                var indexPaths = [NSIndexPath]()
                for row in 0..<distanceRowData.count {
                    distanceRowStates[row] = false
                    indexPaths.append(NSIndexPath(forRow: row, inSection: indexPath.section))
                }

                distanceRowStates[indexPath.row] = true
                distanceChoice = distanceRowData[indexPath.row]
                distanceRowData = [distanceChoice]

                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: indexPath.section)], withRowAnimation: .Fade)
                tableView.endUpdates()
            }
        }

        if indexPath.section == 2 {
            if sortByDisplayMode == .Collapsed {
                sortByDisplayMode = .Expanded

                sortByRowData = Filter.sortBy
                var indexPaths = [NSIndexPath]()
                for row in 0..<sortByRowData.count {
                    indexPaths.append(NSIndexPath(forRow: row, inSection: indexPath.section))
                }

                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: indexPath.section)], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
                tableView.endUpdates()
            } else {
                sortByDisplayMode = .Collapsed

                let cell = tableView.cellForRowAtIndexPath(indexPath) as! CheckmarkCell
                cell.state = .Checked

                var indexPaths = [NSIndexPath]()
                for row in 0..<sortByRowData.count {
                    sortByRowStates[row] = false
                    indexPaths.append(NSIndexPath(forRow: row, inSection: indexPath.section))
                }

                sortByRowStates[indexPath.row] = true
                sortByChoice = sortByRowData[indexPath.row]
                sortByRowData = [sortByChoice]

                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: indexPath.section)], withRowAnimation: .Fade)
                tableView.endUpdates()
            }
        }

        if indexPath.section == 3 && categoriesDisplayMode == .Collapsed && indexPath.row == categoriesRowData.count - 1 {
            categoriesDisplayMode = .Expanded

            let startRow = categoriesRowData.count - 1
            categoriesRowData = Filter.categories

            var indexPaths = [NSIndexPath]()
            for row in startRow..<categoriesRowData.count {
                indexPaths.append(NSIndexPath(forRow: row, inSection: indexPath.section))
            }

            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: startRow, inSection: indexPath.section)], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
            tableView.endUpdates()
        }

    }
}

// MARK: - SwitchCellDelegate

extension FilterViewController: SwitchCellDelegate {
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)!
        switch indexPath.section {
        case 0:
            offeringDealChoice = value
        default:
            categoriesSwitchStates[indexPath.row] = value
        }
    }
}
