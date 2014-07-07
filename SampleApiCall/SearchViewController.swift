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
        let imageUrl = NSURL.URLWithString(searchData!["artworkUrl60"] as NSString)
        image = UIImage(data: NSData.dataWithContentsOfURL(imageUrl, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: nil))
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class SearchViewController: UITableViewController, UISearchBarDelegate {

    init(style: UITableViewStyle) {
        super.init(style: style)
        // Custom initialization
    }

    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // #pragma mark - Table view data source

    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 10
    }

    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar!) {
        
        // do the search
        searchItunesFor(searchBar.text)
        
        // dismiss the keyboard
        searchBar.resignFirstResponder()
    }
    
    func searchItunesFor(searchTerm: String) {
        
        // get the url for the search term
        var url = urlForSearchTerm(searchTerm)

        // get the shared url session
        // we use this session to do the api calls
        var session = NSURLSession.sharedSession()
        
        // create a task
        var task = session.dataTaskWithURL(url, completionHandler: { data, response, error in
            
            if error {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
                return
            }
            
            // parse the results into a dictionary
            var err : NSError?
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            
            if err? {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
                return
            }
            
            // save the results into our data source array
            self.searchedData = jsonResult["results"] as NSMutableArray
            
            // reload the search tableview in main thread
            dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            })
        
        // begin the task
        task.resume()
    }
    
    func urlForSearchTerm(searchTerm : String) -> NSURL {
        
        // The iTunes API wants multiple terms separated by + symbols, so replace spaces with + signs
        var itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        // Now escape anything else that isn't URL-friendly
        var escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        
        var urlPath = "https://itunes.apple.com/search?term=\(escapedSearchTerm)&media=music"
        return NSURL(string: urlPath)
    }
}
