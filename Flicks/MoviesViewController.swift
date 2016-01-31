//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Quintin Frerichs on 1/23/16.
//  Copyright © 2016 Quintin Frerichs. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
class MoviesViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate,UISearchBarDelegate {
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    var movies : [NSDictionary]?
    let data = ["The Revenant", "The Big Short", "The Hateful Eight", "The 5 Wave", "Kung-Fu Panda 3", "Batman: Bad Blood", "Joy", "Dirty Grandpa", "Ride Along 2", "The Boy", "Que Vado?", "13 Hours", "Exposed", "Exposed: Some Secrets Are Better Left Buried", ]
    var filteredData: [String]!

    
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:"refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex:0)
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
       filteredData = data
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)

        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                    if error != nil{
                            error!.code == NSURLErrorNotConnectedToInternet
                            self.errorView.hidden = false
                        }
                        else{
                            self.errorView.hidden = true
                        }
                MBProgressHUD.hideHUDForView(self.view, animated:true)
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                           
                            self.collectionView.reloadData()
                    }
                }
             
                
        })
        task.resume()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func refreshControlAction(refreshControl: UIRefreshControl){
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.collectionView.reloadData()
                    }
                }
                refreshControl.endRefreshing()
        });
        task.resume()
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
        let movie = movies![indexPath.row]
        //let title = movie["title"] as! String
        //filteredData = ["title"]
        cell.titleLabel?.text = filteredData[indexPath.row]
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let posterPath = movie["poster_path"] as! String
        let imageUrl = NSURL(string: baseUrl + posterPath)
        cell.pictureView.setImageWithURL(imageUrl!)
        return cell
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        if let movies = movies {
            return movies.count
        }else{
            return 0
        }
       // return filteredData.count
        
        
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = searchText.isEmpty ? data : data.filter({(dataString: String) -> Bool in
            return dataString.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
    }
    
    func searchBar2(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredData = data
        } else {
            
            filteredData = data.filter({(dataItem: String) -> Bool in
                if dataItem.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        collectionView.reloadData()
    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
