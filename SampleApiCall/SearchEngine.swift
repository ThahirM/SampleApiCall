//
//  SearchEngine.swift
//  SampleApiCall
//
//  Created by Thahir Maheen on 7/7/14.
//  Copyright (c) 2014 Thahir Maheen. All rights reserved.
//

import UIKit

let SharedEngine = SearchEngine()

protocol SearchEngineDelegate {
    func searchCompleted(results : NSArray)
}

class SearchEngine {
    
    var searchEngineDelegate : SearchEngineDelegate?
    
    class func sharedEngine(searchEngineDelegate : SearchEngineDelegate) -> SearchEngine {
        SharedEngine.searchEngineDelegate = searchEngineDelegate
        return SharedEngine
    }
    
    init() { }
    
    convenience init(searchEngineDelegate : SearchEngineDelegate) {
        self.init()
        self.searchEngineDelegate = searchEngineDelegate
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
            
            // notify the delegate
            // make all callbacks on the main thread
            if self.searchEngineDelegate {
                dispatch_async(dispatch_get_main_queue(), {
                    self.searchEngineDelegate!.searchCompleted(jsonResult["results"] as NSArray)
                    })
            }
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
