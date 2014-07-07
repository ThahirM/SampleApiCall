//
//  SearchViewController.swift
//  SampleApiCall
//
//  Created by Thahir Maheen on 7/7/14.
//  Copyright (c) 2014 Thahir Maheen. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    var searchData : NSDictionary? {
    didSet {
        configureCell()
    }
    }
    
    init(style: UITableViewCellStyle, reuseIdentifier: String) {
        super.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: reuseIdentifier)
        // Initialization code
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell() {
        
        // set cell labels
        textLabel.text = searchData!["trackName"]? as? NSString
        detailTextLabel.text = searchData!["collectionName"]? as? NSString
        
        // set cell image
        self.imageView.setImageWithUrlString((searchData!["artworkUrl60"] as NSString), placeHolderImage: UIImage(named: "Blank"))
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class SearchViewController: UITableViewController, UISearchBarDelegate, SearchEngineDelegate {

    var searchedData : NSMutableArray = []
    @IBOutlet var searchBar: UISearchBar
    @lazy var searchEngine : SearchEngine = SearchEngine(searchEngineDelegate: self)

    init(style: UITableViewStyle) {
        super.init(style: style)
        // Custom initialization
    }

    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // show the search keyboard
        searchBar.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // #pragma mark - Table view data source

    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return searchedData.count
    }

    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
        let cell = tableView!.dequeueReusableCellWithIdentifier("kSearchCell", forIndexPath: indexPath) as SearchCell
        cell.searchData = searchedData[indexPath!.row] as? NSDictionary
        return cell
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar!) {
        
        // do the search
        searchEngine.searchEngineDelegate = self
        searchEngine.searchItunesFor(searchBar.text)
        
        // dismiss the keyboard
        searchBar.resignFirstResponder()
    }
    
    func searchCompleted(results : NSArray) {
        
        // save the results into our data source array
        searchedData =  results.mutableCopy() as NSMutableArray
        
        // reload the search tableview
        tableView.reloadData()
    }

}
