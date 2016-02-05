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
    
    @IBOutlet weak var searchBar: UISearchBar!
    var endpoint: String!
    
    
    var movies : [NSDictionary]?
    var filteredData: [NSDictionary]!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.backgroundColor = UIColor(red:1.0, green: 0.1, blue: 0.1, alpha: 0.9)
        //collectionView.backgroundColor = UIColor.orangeColor().colorWithAlphaComponent(0.8)
        
                if let navigationBar = navigationController?.navigationBar{
            navigationBar.backgroundColor = UIColor(red:1.0, green: 0.1, blue: 0.1, alpha: 0.9)
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.orangeColor().colorWithAlphaComponent(0.5)
            shadow.shadowOffset = CGSizeMake(2,2);
            shadow.shadowBlurRadius = 4;
            navigationBar.titleTextAttributes = [
                NSFontAttributeName : UIFont.boldSystemFontOfSize(22),
                NSForegroundColorAttributeName: UIColor(red:1.0, green:0.2,blue:0.2,alpha:1.0),
                NSShadowAttributeName : shadow
                ]
            
            
        
        }
     
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:"refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex:0)
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
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
             self.filteredData = self.movies
                
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
                            self.filteredData = self.movies
                    }
                }
                refreshControl.endRefreshing()
        });
        task.resume()
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
        let movie = filteredData![indexPath.row]
        
        //let title = movie["title"] as! String
        //filteredData = ["title"]
       // cell.titleLabel?.text = filteredData[indexPath.row]
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String{
        let imageUrl = NSURL(string: baseUrl + posterPath)
        cell.pictureView.setImageWithURL(imageUrl!)
            //cell.foregroundView.backgroundColor = UIColor.redColor()
            cell.selectedBackgroundView = cell.foregroundView!
        }
        return cell
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        if let filteredData = filteredData {
            return filteredData.count
        }else{
            return 0
        }
      
        
        
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText:String){
        filteredData = searchText.isEmpty ? movies:
            movies?.filter({(movie: NSDictionary)->Bool in
                return (movie["title"] as! String).rangeOfString(searchText) != nil})
        collectionView.reloadData()
    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredData = movies 
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        let movie = filteredData![indexPath!.row]
        let detailViewController = segue.destinationViewController
        as!DetailViewController
        detailViewController.movie = movie
    }
    
}

