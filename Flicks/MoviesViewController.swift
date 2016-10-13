//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Neha Samant on 10/11/16.
//  Copyright © 2016 Neha Samant. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var endpoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        networkRequest()
           }
    
    func networkRequest(){
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        print("@@@@@@" + endpoint)
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        print(url)
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
                                                                    print("response: \(responseDictionary)")
                                                                    
                                                                    self.movies = responseDictionary["results"] as? [NSDictionary]
                                                                    self.tableView.reloadData()
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
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        cell.textLabel!.text = title
        
        let overview = movie["overview"] as! String
        cell.overviewLabel!.text = overview
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
