//
//  NewMessageController.swift
//  Game Of Chat
//
//  Created by ashim Dahal on 10/6/17.
//  Copyright © 2017 ashim Dahal. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class NewMessageController: UITableViewController {
    let cellID = "cellID"
    var messageController : MessageController?
    var users = [User]()
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
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject]{
                let user = User()
                user.id = snapshot.key
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String

                DispatchQueue.main.async{
                    //if tableView.reloadData is in background Thread it will crash the program
                    // so it has to be in main thread
                    self.tableView.reloadData()
                }
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
        guard let  cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? UserCell  else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        }
            let user = users[indexPath.row]
            cell.textLabel?.text = user.name
            cell.detailTextLabel?.text = user.email
            if let profileImageUrl = user.profileImageUrl {
                cell.profileImageView.sd_setImage(with: URL(string: profileImageUrl), completed: nil)
        }
       return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messageController?.showChatControllerForUser(user: user)
        }
    }
}


