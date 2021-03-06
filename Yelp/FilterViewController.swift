//
//  FilterViewController.swift
//  ChowHunt
//
//  Created by Jon O'Keefe on 10/23/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FilterViewControllerDelegate {
    @objc optional func filterViewController(filterViewController: FilterViewController, didUpdateFilters filters: Filters)
}

class FilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate, SelectionCellDelegate {

    @IBOutlet weak var filtersTableView: UITableView!
    weak var delegate: FilterViewControllerDelegate?
    let tableStructure = ["", "Distance", "Sort", "Categories"] // Deals has no header--only 1 cell
    let CATEGORIES_SECTION_NUM = 3
    let SORT_SECTION_NUM = 2
    let DISTANCE_SECTION_NUM = 1
    let DEALS_SECTION_NUM = 0
    
    var filters = Filters()
    var filterCategories: [[String: String]]!
    var filterDistances: [[String: String]]!
    var filterSortOptions: [[String: String]]!
    var switchStates = [Int: Bool]()
    var selectedDistanceRow = 0
    var selectedSortOptionRow = 0
    var isOfferingDeal = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filtersTableView.dataSource = self
        filtersTableView.delegate = self
        filtersTableView.estimatedRowHeight = 50
        filtersTableView.rowHeight = UITableViewAutomaticDimension
        filterCategories = yelpShortCategories()
        filterDistances = yelpDistances()
        filterSortOptions = yelpSortOptions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelClicked(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSearchClicked(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
        
        // Update filters with Categories
        var selectedCategories = [String: String]()
        for (row, isSelected) in switchStates {
            if isSelected {
                selectedCategories[filterCategories[row]["name"]!] = filterCategories[row]["code"]!
            }
        }
        if !selectedCategories.isEmpty {
            filters.categories = selectedCategories
        }
        
        // Update filters with Distance
        let derp = filterDistances[selectedDistanceRow]["value"]!
        print("[derp] Distance value: \(derp)")
        filters.distance = Int(filterDistances[selectedDistanceRow]["value"]!)
        
        // Update filters with Sort mode
        let derp2 = filterSortOptions[selectedSortOptionRow]["code"]!
        print("[derp] Sort value: \(derp2)")
        filters.sort = Int(filterSortOptions[selectedSortOptionRow]["code"]!)!
        
        // Update filters with Deal offered
        print("[derp] Deal value: \(isOfferingDeal)")
        filters.deals = isOfferingDeal
        
        delegate?.filterViewController?(filterViewController: self, didUpdateFilters: filters)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableStructure.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableStructure[section]
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if section == CATEGORIES_SECTION_NUM {
            count = filterCategories.count
        } else if section == SORT_SECTION_NUM {
            count = filterSortOptions.count
        } else if section == DISTANCE_SECTION_NUM {
            count = filterDistances.count
        } else if section == DEALS_SECTION_NUM {
            count = 1
        }
        return count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == CATEGORIES_SECTION_NUM {
            let cell = filtersTableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            cell.content = filterCategories[indexPath.row]
            cell.delegate = self
            cell.switchView.isOn = switchStates[indexPath.row] ?? false
            return cell
        } else if indexPath.section == SORT_SECTION_NUM {
            let cell = filtersTableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath) as! SelectionCell
            cell.content = filterSortOptions[indexPath.row]
            cell.delegate = self
            let isSelected = indexPath.row == selectedSortOptionRow
            cell.accessoryType = isSelected ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
            return cell
        } else if indexPath.section == DISTANCE_SECTION_NUM {
            let cell = filtersTableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath) as! SelectionCell
            cell.content = filterDistances[indexPath.row]
            cell.delegate = self
            let isSelected = indexPath.row == selectedDistanceRow
            cell.accessoryType = isSelected ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
            return cell
        } else if indexPath.section == DEALS_SECTION_NUM {
            let cell = filtersTableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            cell.content = ["name" : "Offering a deal", "code": "deals"]
            cell.delegate = self
            cell.switchView.isOn = isOfferingDeal
            return cell
        }
        return filtersTableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath)
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = filtersTableView.indexPath(for: switchCell)!
        if indexPath.section == CATEGORIES_SECTION_NUM {
            switchStates[indexPath.row] = value
        } else if indexPath.section == DEALS_SECTION_NUM {
            isOfferingDeal = value
        }
    }
    
    func selectionCell(selected selectionCell: SelectionCell) {
        selectionCell.accessoryType = UITableViewCellAccessoryType.checkmark
        let indexPath = filtersTableView.indexPath(for: selectionCell)!
        filtersTableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == DISTANCE_SECTION_NUM {
            selectedDistanceRow = indexPath.row
        } else if indexPath.section == SORT_SECTION_NUM {
            selectedSortOptionRow = indexPath.row
        }
        deselectOtherRows(selectedIndexPath: indexPath)
    }
    
    func deselectOtherRows(selectedIndexPath: IndexPath) {
        let rowCount = filtersTableView.numberOfRows(inSection: selectedIndexPath.section)
        for row in 0 ..< rowCount {
            if row != selectedIndexPath.row {
                let cell = filtersTableView.cellForRow(at: IndexPath(row: row, section: selectedIndexPath.section))
                cell?.accessoryType = UITableViewCellAccessoryType.none
            }
        }
    }
    
    func yelpDistances() -> [[String: String]] { // [[displayName: meterValue]]
        return [["name": "Best Match", "value": ""],
                ["name": "0.3 miles", "value": "483"],
                ["name": "1 mile", "value": "1609"],
                ["name": "2 miles", "value": "3219"],
                ["name": "5 miles", "value": "8047"]]
    }
    
    func yelpSortOptions() -> [[String: String]] {
        return [["name": "Best Match", "code": "0"],
                ["name": "Distance", "code": "1"],
                ["name": "Rating", "code": "2"]]
    }
    
    func yelpShortCategories() -> [[String : String]] {
        return [["name" : "American, Traditional", "code": "tradamerican"],
                ["name" : "Japanese", "code": "japanese"],
                ["name" : "Korean", "code": "korean"],
                ["name" : "Mediterranean", "code": "mediterranean"],
                ["name" : "Mexican", "code": "mexican"]]
    }
    
    func yelpCategories() -> [[String : String]] {
        return [["name" : "Afghan", "code": "afghani"],
         ["name" : "African", "code": "african"],
         ["name" : "American, New", "code": "newamerican"],
         ["name" : "American, Traditional", "code": "tradamerican"],
         ["name" : "Arabian", "code": "arabian"],
         ["name" : "Argentine", "code": "argentine"],
         ["name" : "Armenian", "code": "armenian"],
         ["name" : "Asian Fusion", "code": "asianfusion"],
         ["name" : "Asturian", "code": "asturian"],
         ["name" : "Australian", "code": "australian"],
         ["name" : "Austrian", "code": "austrian"],
         ["name" : "Baguettes", "code": "baguettes"],
         ["name" : "Bangladeshi", "code": "bangladeshi"],
         ["name" : "Barbeque", "code": "bbq"],
         ["name" : "Basque", "code": "basque"],
         ["name" : "Bavarian", "code": "bavarian"],
         ["name" : "Beer Garden", "code": "beergarden"],
         ["name" : "Beer Hall", "code": "beerhall"],
         ["name" : "Beisl", "code": "beisl"],
         ["name" : "Belgian", "code": "belgian"],
         ["name" : "Bistros", "code": "bistros"],
         ["name" : "Black Sea", "code": "blacksea"],
         ["name" : "Brasseries", "code": "brasseries"],
         ["name" : "Brazilian", "code": "brazilian"],
         ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
         ["name" : "British", "code": "british"],
         ["name" : "Buffets", "code": "buffets"],
         ["name" : "Bulgarian", "code": "bulgarian"],
         ["name" : "Burgers", "code": "burgers"],
         ["name" : "Burmese", "code": "burmese"],
         ["name" : "Cafes", "code": "cafes"],
         ["name" : "Cafeteria", "code": "cafeteria"],
         ["name" : "Cajun/Creole", "code": "cajun"],
         ["name" : "Cambodian", "code": "cambodian"],
         ["name" : "Canadian", "code": "New)"],
         ["name" : "Canteen", "code": "canteen"],
         ["name" : "Caribbean", "code": "caribbean"],
         ["name" : "Catalan", "code": "catalan"],
         ["name" : "Chech", "code": "chech"],
         ["name" : "Cheesesteaks", "code": "cheesesteaks"],
         ["name" : "Chicken Shop", "code": "chickenshop"],
         ["name" : "Chicken Wings", "code": "chicken_wings"],
         ["name" : "Chilean", "code": "chilean"],
         ["name" : "Chinese", "code": "chinese"],
         ["name" : "Comfort Food", "code": "comfortfood"],
         ["name" : "Corsican", "code": "corsican"],
         ["name" : "Creperies", "code": "creperies"],
         ["name" : "Cuban", "code": "cuban"],
         ["name" : "Curry Sausage", "code": "currysausage"],
         ["name" : "Cypriot", "code": "cypriot"],
         ["name" : "Czech", "code": "czech"],
         ["name" : "Czech/Slovakian", "code": "czechslovakian"],
         ["name" : "Danish", "code": "danish"],
         ["name" : "Delis", "code": "delis"],
         ["name" : "Diners", "code": "diners"],
         ["name" : "Dumplings", "code": "dumplings"],
         ["name" : "Eastern European", "code": "eastern_european"],
         ["name" : "Ethiopian", "code": "ethiopian"],
         ["name" : "Fast Food", "code": "hotdogs"],
         ["name" : "Filipino", "code": "filipino"],
         ["name" : "Fish & Chips", "code": "fishnchips"],
         ["name" : "Fondue", "code": "fondue"],
         ["name" : "Food Court", "code": "food_court"],
         ["name" : "Food Stands", "code": "foodstands"],
         ["name" : "French", "code": "french"],
         ["name" : "French Southwest", "code": "sud_ouest"],
         ["name" : "Galician", "code": "galician"],
         ["name" : "Gastropubs", "code": "gastropubs"],
         ["name" : "Georgian", "code": "georgian"],
         ["name" : "German", "code": "german"],
         ["name" : "Giblets", "code": "giblets"],
         ["name" : "Gluten-Free", "code": "gluten_free"],
         ["name" : "Greek", "code": "greek"],
         ["name" : "Halal", "code": "halal"],
         ["name" : "Hawaiian", "code": "hawaiian"],
         ["name" : "Heuriger", "code": "heuriger"],
         ["name" : "Himalayan/Nepalese", "code": "himalayan"],
         ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
         ["name" : "Hot Dogs", "code": "hotdog"],
         ["name" : "Hot Pot", "code": "hotpot"],
         ["name" : "Hungarian", "code": "hungarian"],
         ["name" : "Iberian", "code": "iberian"],
         ["name" : "Indian", "code": "indpak"],
         ["name" : "Indonesian", "code": "indonesian"],
         ["name" : "International", "code": "international"],
         ["name" : "Irish", "code": "irish"],
         ["name" : "Island Pub", "code": "island_pub"],
         ["name" : "Israeli", "code": "israeli"],
         ["name" : "Italian", "code": "italian"],
         ["name" : "Japanese", "code": "japanese"],
         ["name" : "Jewish", "code": "jewish"],
         ["name" : "Kebab", "code": "kebab"],
         ["name" : "Korean", "code": "korean"],
         ["name" : "Kosher", "code": "kosher"],
         ["name" : "Kurdish", "code": "kurdish"],
         ["name" : "Laos", "code": "laos"],
         ["name" : "Laotian", "code": "laotian"],
         ["name" : "Latin American", "code": "latin"],
         ["name" : "Live/Raw Food", "code": "raw_food"],
         ["name" : "Lyonnais", "code": "lyonnais"],
         ["name" : "Malaysian", "code": "malaysian"],
         ["name" : "Meatballs", "code": "meatballs"],
         ["name" : "Mediterranean", "code": "mediterranean"],
         ["name" : "Mexican", "code": "mexican"],
         ["name" : "Middle Eastern", "code": "mideastern"],
         ["name" : "Milk Bars", "code": "milkbars"],
         ["name" : "Modern Australian", "code": "modern_australian"],
         ["name" : "Modern European", "code": "modern_european"],
         ["name" : "Mongolian", "code": "mongolian"],
         ["name" : "Moroccan", "code": "moroccan"],
         ["name" : "New Zealand", "code": "newzealand"],
         ["name" : "Night Food", "code": "nightfood"],
         ["name" : "Norcinerie", "code": "norcinerie"],
         ["name" : "Open Sandwiches", "code": "opensandwiches"],
         ["name" : "Oriental", "code": "oriental"],
         ["name" : "Pakistani", "code": "pakistani"],
         ["name" : "Parent Cafes", "code": "eltern_cafes"],
         ["name" : "Parma", "code": "parma"],
         ["name" : "Persian/Iranian", "code": "persian"],
         ["name" : "Peruvian", "code": "peruvian"],
         ["name" : "Pita", "code": "pita"],
         ["name" : "Pizza", "code": "pizza"],
         ["name" : "Polish", "code": "polish"],
         ["name" : "Portuguese", "code": "portuguese"],
         ["name" : "Potatoes", "code": "potatoes"],
         ["name" : "Poutineries", "code": "poutineries"],
         ["name" : "Pub Food", "code": "pubfood"],
         ["name" : "Rice", "code": "riceshop"],
         ["name" : "Romanian", "code": "romanian"],
         ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
         ["name" : "Rumanian", "code": "rumanian"],
         ["name" : "Russian", "code": "russian"],
         ["name" : "Salad", "code": "salad"],
         ["name" : "Sandwiches", "code": "sandwiches"],
         ["name" : "Scandinavian", "code": "scandinavian"],
         ["name" : "Scottish", "code": "scottish"],
         ["name" : "Seafood", "code": "seafood"],
         ["name" : "Serbo Croatian", "code": "serbocroatian"],
         ["name" : "Signature Cuisine", "code": "signature_cuisine"],
         ["name" : "Singaporean", "code": "singaporean"],
         ["name" : "Slovakian", "code": "slovakian"],
         ["name" : "Soul Food", "code": "soulfood"],
         ["name" : "Soup", "code": "soup"],
         ["name" : "Southern", "code": "southern"],
         ["name" : "Spanish", "code": "spanish"],
         ["name" : "Steakhouses", "code": "steak"],
         ["name" : "Sushi Bars", "code": "sushi"],
         ["name" : "Swabian", "code": "swabian"],
         ["name" : "Swedish", "code": "swedish"],
         ["name" : "Swiss Food", "code": "swissfood"],
         ["name" : "Tabernas", "code": "tabernas"],
         ["name" : "Taiwanese", "code": "taiwanese"],
         ["name" : "Tapas Bars", "code": "tapas"],
         ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
         ["name" : "Tex-Mex", "code": "tex-mex"],
         ["name" : "Thai", "code": "thai"],
         ["name" : "Traditional Norwegian", "code": "norwegian"],
         ["name" : "Traditional Swedish", "code": "traditional_swedish"],
         ["name" : "Trattorie", "code": "trattorie"],
         ["name" : "Turkish", "code": "turkish"],
         ["name" : "Ukrainian", "code": "ukrainian"],
         ["name" : "Uzbek", "code": "uzbek"],
         ["name" : "Vegan", "code": "vegan"],
         ["name" : "Vegetarian", "code": "vegetarian"],
         ["name" : "Venison", "code": "venison"],
         ["name" : "Vietnamese", "code": "vietnamese"],
         ["name" : "Wok", "code": "wok"],
         ["name" : "Wraps", "code": "wraps"],
         ["name" : "Yugoslav", "code": "yugoslav"]]

    }
}
