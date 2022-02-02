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
    
    func createPost(title: String, body: String, completion: @escaping (Error?) -> ()) {
        guard let url = URL(string: "http://localhost:1337/post") else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        let params = ["title": title, "postBody": body]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: params, options: .init())
            urlRequest.httpBody = data
            urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
            
            URLSession.shared.dataTask(with: urlRequest) { (data, res, err) in
                guard let data = data else { return }
                if let err = err {
                    print("There was an error when creating post: ", err)
                    completion(err)
                    return
                }
                
                // Because err could be nil but HTTP Response could have Status Code 404, for instance
                if let res = res as? HTTPURLResponse, res.statusCode != 200 {
                    let errorString = String(data: data, encoding: .utf8) ?? ""
                    completion(NSError(domain: "", code: res.statusCode, userInfo: [NSLocalizedDescriptionKey: errorString]))
                    return
                }
                
                completion(nil)
                print(String(data: data, encoding: .utf8) ?? "")
            }.resume()
        } catch {
            completion(error)
        }
    }
    
    func deletePost(id: Int, completion: @escaping (Error?) -> ()) {
        guard let url = URL(string: "http://localhost:1337/post/\(id)") else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: urlRequest) { (data, res, err) in
            
            DispatchQueue.main.async {
                if let err = err {
                    print("There was an error when deleting post: ", err)
                    completion(err)
                    return
                }
                
                // Because err could be nil but HTTP Response could have Status Code 404, for instance
                if let res = res as? HTTPURLResponse, res.statusCode != 200 {
                    let errorString = String(data: data ?? Data(), encoding: .utf8) ?? ""
                    completion(NSError(domain: "", code: res.statusCode, userInfo: [NSLocalizedDescriptionKey: errorString]))
                    return
                }
                
                completion(nil)
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
        print("Trying to create post...")
        
        Service.shared.createPost(title: "POST TITLE 001", body: "POST BODY 001") { (err) in
            if let err = err {
                print("Failed to create a Post object... Err: ", err)
                return
            }
            print("Finished creating post...")
            self.fetchPosts()
        }
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Trying to delete post...")
            let post = self.posts[indexPath.row]
            Service.shared.deletePost(id: post.id) { (err) in
                if let err = err {
                    print("Failed to delete: ", err)
                    return
                }
                print("Successfully deleted post from server")
                self.posts.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

