//
//  ViewController.swift
//  my_journal_idevtv-iOS
//
//  Created by Pavel Palancica on 2/2/22.
//

import UIKit

struct Post: Decodable {
    let id: Int
    let title: String
    let body: String
}

class Service: NSObject {
    static let shared = Service()
    
    func fetchPosts(completion: () -> ()) {
        guard let url = URL(string: "http://localhost:1337/posts") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, res, err) in
            if let err = err {
                print("Failed to fetch posts... Error: ", err)
                return
            }
            
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8) ?? "")
            
        }.resume()
    }
}

class ViewController: UITableViewController {

    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        fetchPosts()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Posts"
        navigationItem.rightBarButtonItem = .init(title: "Create Post", style: .plain, target: self, action: #selector(handleCreatePost))
    }

    fileprivate func fetchPosts() {
        Service.shared.fetchPosts {
            
        }
    }
    
    @objc fileprivate func handleCreatePost() {
        print("Creating post...")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        return cell
    }
}

