//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, FilterViewControllerDelegate {
    
    @IBOutlet weak var businessesTableView: UITableView!
    
    var businesses: [Business]!
    
    var filteredBusinesses: [Business]!
    
    var searchController: UISearchController!
    
    var filters = Filters()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        businessesTableView.dataSource = self
        businessesTableView.delegate = self
        businessesTableView.estimatedRowHeight = 100
        businessesTableView.rowHeight = UITableViewAutomaticDimension
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Restaurants"
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        
        Business.searchWithTerm(term: "Restaurants", completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.businessesTableView.reloadData()
            
            }
        )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        searchController.searchResultsUpdater = nil
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        Business.searchWithTerm(term: "Restaurants \(searchText)", completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.businessesTableView.reloadData()
            
            }
        )
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = businessesTableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        cell.business = businesses[indexPath.row]
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let filterViewController = navigationController.topViewController as! FilterViewController
        filterViewController.delegate = self
        searchController.dismiss(animated: true, completion: nil)
    }
    
    func filterViewController(filterViewController: FilterViewController, didUpdateFilters filters: Filters) {
        self.filters = filters
        let searchText = searchController.searchBar.text ?? ""
        Business.searchWithTerm(term: "Restaurants \(searchText)", sort: YelpSortMode(rawValue: filters.sort), categories: Array(filters.categories.values), distance: filters.distance, deals: filters.deals) { (businesses: [Business]?, error: Error?) -> Void in
            self.businesses = businesses
            self.businessesTableView.reloadData()
        }
    }
}
