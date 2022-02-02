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
    
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> ()) {
        guard let url = URL(string: "http://localhost:1337/posts") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, result, err) in
            
            DispatchQueue.main.async {
                if let err = err {
                    print("Failed to fetch posts... Error: ", err)
                    return
                }
                
                guard let data = data else { return }
                print(String(data: data, encoding: .utf8) ?? "")
                
                do {
                    let posts = try JSONDecoder().decode([Post].self, from: data)
                    completion(.success(posts))
                } catch {
                    completion(.failure(error))
                }
            }
            
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
        Service.shared.fetchPosts { (res) in
            switch res {
            case .failure(let err):
                print("Failed to fetch posts: ", err)
            case .success(let posts):
                // print(posts)
                self.posts = posts
                self.tableView.reloadData()
            }
        }
    }
    
    @objc fileprivate func handleCreatePost() {
        print("Creating post...")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil) // tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let post = posts[indexPath.row]
        
        cell.textLabel?.text = post.title
        cell.detailTextLabel?.text = post.body
        
        return cell
    }
}

