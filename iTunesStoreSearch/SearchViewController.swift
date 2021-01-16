//
//  ViewController.swift
//  iTunesStoreSearch
//
//  Created by Mohamed Khalid on 1/16/21.
//

import UIKit

class SearchViewController: UIViewController {

    // MARK:- Outlets
    //
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK:- Properties
    //
    var searchResults = [SearchResult]()
    var hasSearched = false
    
    // MARK:- Methods
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        // Adding margin above the table view
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        // We have been connected the delegate of search bar and the table view using story board by "ctrl" and drag from the view to the controller
        
    }
}


// MARK:- Search bar delegate
//
extension SearchViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchResults = []
        hasSearched = true
        // To handle case of no results --> there are no elements appended to the searchResults array
        if searchBar.text! != "justin bieber"
        {
            for i in 0...2{
                let searchResult = SearchResult()
                searchResult.name = String(format: "Fake result %d for ", i)
                searchResult.artistName = searchBar.text!
                searchResults.append(searchResult)
            }
        }
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        .topAttached
    }
}

// MARK:- Table view delegates
//
extension SearchViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched{
            return 0
        }
        else if searchResults.count == 0{
            return 1
        }
        else{
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SearchResultCell"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil{
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        // To handle case of no results
        if searchResults.count == 0{
            cell.textLabel?.text = "(Nothing found)"
            cell.detailTextLabel?.text = ""
        }
        else{
            cell.textLabel?.text = searchResults[indexPath.row].name
            cell.detailTextLabel?.text = searchResults[indexPath.row].artistName
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0{
            return nil
        }
        else{
            return indexPath
        }
    }
   
}
