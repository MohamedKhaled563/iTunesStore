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
    var isLoading = false
    
    // MARK:- Methods
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        // Adding margin above the table view
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        // We have been connected the delegate of search bar and the table view using story board by "ctrl" and drag from the view to the controller
        
        // Loading and registering cell
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: "NothingFoundCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: "LoadingTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
        
        
        // To open keyboard when app starts
        searchBar.becomeFirstResponder()
    }
    // MARK:- Helper methods
    //
    
    // Creating URL with valid parameters
    func iTunesURL(searchText: String) -> URL{
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let URLString = String(format: "https://itunes.apple.com/search?term=%@&limit=200", encodedText!)
        // URL returns nil if it is invalid string, like having one or more spaces
        let url = URL(string: URLString)
        return url!
    }
    // Getting JSON
    /*
    func performStoreRequest(with url: URL) -> String?{
        do{
            return try String(contentsOf: url)
        }
        catch{
            print("Download error: '\(error.localizedDescription)'")
            return nil
        }
    }*/
    func performStoreRequest(with url: URL) -> Data?{
        do{
            return try Data(contentsOf: url)
        }
        catch{
            showNetworkError()
            print("Download error: '\(error.localizedDescription)'")
            return nil
        }
    }

    func parse(data: Data) -> [SearchResult]{
        do{
            let jsonDecoder = JSONDecoder()
            let result = try jsonDecoder.decode(ResultArray.self, from: data)
            return result.results
        } catch{
            print("JOSN error: '\(error.localizedDescription)'.")
            return[]
        }
    }
    
    func showNetworkError(){
        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing the iTunes Store. Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

// MARK:- Table view cells identifiers
//
struct TableView{
    struct CellIdentifiers{
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
}

// MARK:- Search bar delegate
//
extension SearchViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // To handle case of no results --> there are no elements appended to the searchResults array
        /*if searchBar.text! != "justin bieber"
        {
            for i in 0...2{
                let searchResult = SearchResult()
                searchResult.name = String(format: "Fake result %d for ", i)
                searchResult.artistName = searchBar.text!
                searchResults.append(searchResult)
            }
        }*/
        // Creating URL
        if !searchBar.text!.isEmpty{
            searchBar.resignFirstResponder()
            isLoading = true
            searchResults = []
            hasSearched = true
            let url = iTunesURL(searchText: searchBar.text!)
            if let JSONData = performStoreRequest(with: url){
                var results = parse(data: JSONData)
                print("Recieved JSON Data: '\(results)'")
                results.sort { $0 < $1 }
                searchResults = results
            }
            isLoading = false
            tableView.reloadData()
        }
    }
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        .topAttached
    }
}

// MARK:- Table view delegates
//
extension SearchViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading{
            return 1
        }
        else if !hasSearched{
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

        // Loading state
        if isLoading{
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }
        
        // To handle case of no results
        if searchResults.count == 0{
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel?.text = searchResult.name
            if searchResult.artist.isEmpty{
                cell.artistNameLabel?.text = "Unknown"
            } else{
                cell.artistNameLabel?.text = String(format: "%@ (%@)", searchResult.artist, searchResult.type)
            }

            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading{
            return nil
        }
        else{
            return indexPath
        }
    }
}
