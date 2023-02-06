//
//  ViewController.swift
//  BrowsrApp
//
//  Created by Adeel Nasir on 06/02/2023.
//

import UIKit
import BrowsrLib
import Connectivity

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate {
    var localResults = [Organizations]()
    var searchResults = [Organizations]()
    @IBOutlet weak var mySearchBar: UISearchBar!
    @IBOutlet weak var myTableView: UITableView!
    let connectivity = Connectivity()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        myTableView.dataSource = self
        myTableView.delegate = self
        mySearchBar.delegate = self
        checkConnectivity()
           
       
        
    }
    func checkConnectivity() {
           connectivity.checkConnectivity { (isConnected) in
               if isConnected.isConnected {
                   // do something when internet connection is available
                   BrowsrLib { (successArray) in
                       for result in successArray {
                           let localResult = Organizations(id: result.id, login: result.login, avatar_url: result.avatar_url)
                           self.localResults.append(localResult)
                       }
                       for result in self.localResults {
                           print(result.login.uppercased())
                       }
                       DispatchQueue.main.async {
                           self.myTableView.reloadData()
                       }
                       
                   }
               } else {
                   // show an error message or an alert
                   let alert = UIAlertController(title: "No Internet Connection", message: "Please check your internet connection and try again.", preferredStyle: .alert)
                   let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                   alert.addAction(action)
                   self.present(alert, animated: true, completion: nil)
               }
           }
       }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.searchResults.count > 0){
                    return self.searchResults.count
                }
        else if(self.localResults.count > 0){
            return self.localResults.count
        }
        else {
            return 0
        }
    }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
           let organization = self.localResults[indexPath.row]
           let label = self.view.viewWithTag(1) as? UILabel

           if let label = label {
               label.text = organization.login
           } else {
           }
           if let imageView = cell.viewWithTag(2) as? UIImageView {
               let imageURL = URL(string: organization.avatar_url)!
                       imageView.downloadImage(from: imageURL)
           }
           return cell
       }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
           searchResults = localResults.filter({ (organization) -> Bool in
               return organization.login.lowercased().contains(searchText.lowercased())
           })
           self.myTableView.reloadData()
       }
    
}
extension ViewController {
    struct Organizations {
        public var id: Int
        public var login: String
        public  var avatar_url: String
    }
}
extension UIImageView {
    func downloadImage(from url:URL){
        contentMode = .scaleToFill
        let dataTask = URLSession.shared.dataTask(with: url, completionHandler: {
            (data, response, error) in
            guard let httpUrlResponse = response as? HTTPURLResponse, httpUrlResponse.statusCode == 200,
                  let mimeType = response?.mimeType,
                  mimeType.hasPrefix("image"),
                  let data = data, error == nil,
                  let image = UIImage(data: data)
            else {
                print("Error")
                return
            }
            DispatchQueue.main.async {
                self.image = image
            }
        }
        )
        dataTask.resume()
    }
}

