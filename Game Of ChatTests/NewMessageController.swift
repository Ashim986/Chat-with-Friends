//
//  NewMessageController.swift
//  Game Of Chat
//
//  Created by ashim Dahal on 10/6/17.
//  Copyright © 2017 ashim Dahal. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    let cellID = "cellID"
    
    var users = [Users]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handelCancel))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        fetchUser()
    }
    
    @objc func handelCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    func fetchUser(){
        Database.database().reference().child("user").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject]{
                let user = Users()
                
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                // this will crash due to backgournd thread
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                
                self.users.append(user)
            }
            
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? UserCell
        let user = users[indexPath.row]
        cell?.textLabel?.text = user.name
        cell?.detailTextLabel?.text = user.email
        
        if let profileImageUrl = user.profileImageUrl {
            cell?.profileImageView.loadImageUingCasheWithUrlString(urlString: profileImageUrl)
            
        }
        
        return cell!
    }
    
}


