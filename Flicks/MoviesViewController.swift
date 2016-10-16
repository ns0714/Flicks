//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Neha Samant on 10/11/16.
//  Copyright © 2016 Neha Samant. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var networkErrorView: UIView!
    
    var movies: [NSDictionary]?
    var moviesArray: [NSDictionary]?
    var endpoint: String!
    var searchActive : Bool = false
    var filteredtitles: [String] = []
    var titles: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        self.navigationItem.title = "Flicks"
        
        //searchBar.
        MBProgressHUD.appearance().tintColor = UIColor.white
        MBProgressHUD.showAdded(to: self.view, animated: true)
        networkRequest()
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,
                                                         completionHandler: {(dataOrNil, response, error) in
                                                            
                                                            if let data = dataOrNil {
                                                                if let responseDictionary = try! JSONSerialization.jsonObject(
                                                                    with: data, options:[]) as? NSDictionary {
                                                                    NSLog("response: \(responseDictionary)")
                                                                    
                                                                    self.movies = responseDictionary["results"] as? [NSDictionary]
                                                                    self.moviesArray = self.movies;
                                                                    self.tableView.reloadData()
                                                                    DispatchQueue.main.async {
                                                                        MBProgressHUD.hide(for: self.view, animated: true)
                                                                    }
                                                                }
                                                            }
                                                            self.tableView.reloadData()
                                                            refreshControl.endRefreshing()
        });
        task.resume()
    }
    
    func networkRequest() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
       
        let task : URLSessionDataTask = session.dataTask(with: request,
                                                         completionHandler: {(dataOrNil, response, error) in
                                                            if error != nil {
                                                                    self.networkErrorView.isHidden = false
                                                                    DispatchQueue.main.async {
                                                                        MBProgressHUD.hide(for: self.view, animated: true)
                                                                }
                                                            }else
                                                            if let data = dataOrNil {
                                                                if let responseDictionary = try! JSONSerialization.jsonObject(
                                                                    with: data, options:[]) as? NSDictionary {
                                                                    NSLog("response: \(responseDictionary)")
                                                                    
                                                                    self.movies = responseDictionary["results"] as? [NSDictionary]
                                                                    self.tableView.reloadData()
                                                                    self.moviesArray = self.movies;
                                                                    if let titleArray = self.movies
                                                                    {
                                                                        for (item) in titleArray
                                                                        {
                                                                            let title: String! = item.object(forKey: "title") as! String
                                                                            self.titles.append(title)
                                                                        }
                                                                    }
                                                                    DispatchQueue.main.async {
                                                                        MBProgressHUD.hide(for: self.view, animated: true)
                                                                    }
                                                                }
                                                            }
                                                            
        });
        task.resume()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let movies = movies {
            return movies.count
        }else {
            return 0;
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        cell.selectionStyle = .none
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        cell.titleLabel!.text = title
        
        let overview = movie["overview"] as! String
        cell.overviewLabel!.text = overview
        cell.overviewLabel.sizeToFit()
        
        let baseSmallUrl = "https://image.tmdb.org/t/p/w45"
        let baseLargeUrl = "https://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String {
            let imageLargeUrl = baseLargeUrl + posterPath
            let imageSmallUrl = baseSmallUrl + posterPath
            let imageSmallRequest = NSURLRequest(url: NSURL(string: imageSmallUrl)! as URL)
            let imageLargeRequest = NSURLRequest(url: NSURL(string: imageLargeUrl)! as URL)
        
            cell.posterView.setImageWith(
            imageSmallRequest as URLRequest,
            placeholderImage: nil,
            success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                
                // smallImageResponse will be nil if the smallImage is already available
                // in cache (might want to do something smarter in that case).
                cell.posterView.alpha = 0.0
                cell.posterView.image = smallImage;
                
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    
                    cell.posterView.alpha = 1.0
                    
                    }, completion: { (sucess) -> Void in
            
                            cell.posterView.setImageWith(
                            imageLargeRequest as URLRequest,
                            placeholderImage: nil,
                            success: { (imageLargeRequest, imageLargeResponse, largeImage) -> Void in
                
                                // imageResponse will be nil if the image is cached
                                if imageLargeResponse != nil {
                                    print("Image was NOT cached, fade in image")
                                    cell.posterView.alpha = 0.0
                                    cell.posterView.image = largeImage
                                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                                        cell.posterView.alpha = 1.0
                                    })
                                }
                                else {
                                    print("Image was cached so just update the image")
                                    cell.posterView.image = largeImage
                                }
                                },
                            failure: { (imageRequest, imageResponse, error) -> Void in
                                
                            })
                    })
                },
            failure: { (request, response, error) -> Void in
               
            })
        }
            return cell
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        print("prepare for segue called")
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie;
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
        movies = moviesArray
        self.tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
        movies = moviesArray
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        movies = moviesArray
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        movies = moviesArray
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var filteredMovies: [NSDictionary] = []
        filteredtitles = titles.filter({ (text) -> Bool in
            let tmp: NSString = text as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        
        let titleArray = self.movies
        for (titleInFilteredData) in filteredtitles {
            for (item) in titleArray! {
                let title: String = item.object(forKey: "title") as! String
                if(title == titleInFilteredData) {
                    filteredMovies.append(item)
                }
            }
        }
        
        if(filteredMovies.count == 0) {
            searchActive = false;
            self.movies! = self.moviesArray!
        } else {
            searchActive = true;
            self.movies = filteredMovies
        }
        filteredMovies.removeAll()
        self.tableView.reloadData()
    }
}
