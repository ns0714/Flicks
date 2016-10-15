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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var networkErrorView: UIView!
    
    var movies: [NSDictionary]?
    var endpoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        //searchBar.delegate = self
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        networkRequest()
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        print("@@@@@@" + endpoint)
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        print(url)
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task : URLSessionDataTask = session.dataTask(with: request,
                                                         completionHandler: {(dataOrNil, response, error) in
                                                            
                                                            //MBProgressHUD.hide(for: self.view, animated: true)
                                                            
                                                            if let data = dataOrNil {
                                                                if let responseDictionary = try! JSONSerialization.jsonObject(
                                                                    with: data, options:[]) as? NSDictionary {
                                                                    NSLog("response: \(responseDictionary)")
                                                                    print("response: \(responseDictionary)")
                                                                    
                                                                    self.movies = responseDictionary["results"] as? [NSDictionary]
                                                                    self.tableView.reloadData()
                                                                    DispatchQueue.main.async {
                                                                        MBProgressHUD.hide(for: self.view, animated: true)
                                                                    }
                                                                }
                                                            }
                                                            self.tableView.reloadData()
                                                            
                                                            // Tell the refreshControl to stop spinning
                                                            refreshControl.endRefreshing()
        });
        task.resume()
        

    }
    
    func networkRequest() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        print("@@@@@@" + endpoint)
        print("URL: " + "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")
        print(url)
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
                                                                    print("response: \(responseDictionary)")
                                                                    
                                                                    self.movies = responseDictionary["results"] as? [NSDictionary]
                                                                    self.tableView.reloadData()
                                                                    DispatchQueue.main.async {
                                                                        MBProgressHUD.hide(for: self.view, animated: true)
                                                                    }
                                                                    
                                                                }
                                                            }
                                                            
        });
        task.resume()
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let movies = movies{
            return movies.count
        }else {
            return 0;
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        cell.selectionStyle = .none
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        cell.titleLabel!.text = title
        
        let overview = movie["overview"] as! String
        cell.overviewLabel!.text = overview
        //cell.overviewLabel.font.pointSize(10)
        cell.overviewLabel.sizeToFit()
        
        let baseUrl = "https://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = URL(string: baseUrl + posterPath)
            cell.posterView.setImageWith(imageUrl!)
        }
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
    
    
}
