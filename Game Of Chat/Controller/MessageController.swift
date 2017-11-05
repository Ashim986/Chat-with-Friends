//
//  ViewController.swift
//  Game Of Chat
//
//  Created by ashim Dahal on 10/4/17.
//  Copyright © 2017 ashim Dahal. All rights reserved.
//

import UIKit
import Firebase

class MessageController: UITableViewController {
    
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rightBarButtonImage = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: rightBarButtonImage, style: .plain, target: self, action: #selector(handleNewMessage))
        
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector (handleLogout))
        // user in not logged in
        checkIfUserIsLoggedIn()
        observeMessage()
    }
    func observeMessage() {
        let refrence = Database.database().reference().child("messages")
        refrence.observe(.childAdded) { (snapshot) in
            
            let message = Message()
            if let dictionary = snapshot.value as? [String: AnyObject]{
                // to use setValueForKeys(dictionary) make sure your message is objc format data or else it will fail
                message.setValuesForKeys(dictionary)
               self.messages.append(message)
                
                // lets reload data in table view with async operation
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let messageDisplay = messages[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellID")
        cell.textLabel?.text = messageDisplay.toID
        cell.detailTextLabel?.text = messageDisplay.text
      
        return cell
    }
    
    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        else{
            setupNavBarWithUserTitle()
        }
    }
    func setupNavBarWithUser(user : User) {
        
        let titleView = UIButton(type: .system)
//        titleView.addTarget(self, action: #selector(showChatController), for: .touchUpInside)
        //anotherMethod of handeling button
//         titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)

        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        
        if let profileImageUrl = user.profileImageUrl{
            profileImageView.sd_setImage(with: URL(string: profileImageUrl), completed: nil)
        }
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = user.name
        
        containerView.addSubview(profileImageView)
        containerView.addSubview(nameLabel)
        // constraint for profile Image View
        
        NSLayoutConstraint.activate([profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor), profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor), profileImageView.widthAnchor.constraint(equalToConstant: 40),profileImageView.heightAnchor.constraint(equalToConstant: 40) ])
        
        // x,y,width,height
        NSLayoutConstraint.activate([nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8), nameLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor), nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor),nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor)])
        
        // constraint for container view
        
        NSLayoutConstraint.activate([containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor), containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor)])
        
        self.navigationItem.titleView = titleView
    }
    
    @objc func showChatControllerForUser(user : User) {
    
        let chatController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
        let chatLogController = NavigationController(rootViewController: chatController)
        present(chatLogController, animated: true, completion: nil)
    }
    
    func setupNavBarWithUserTitle() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
         // for some reason if uid is nil
            return
        }
        Database.database().reference().child ("users").child(uid).observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject ]{
               let user = User()
                user.setValuesForKeys(dictionary)
                self.setupNavBarWithUser(user: user)
            }
            
        }, withCancel: nil)
    
}
    
    @objc func handleLogout (){
        do{
            try Auth.auth().signOut()
            
        }catch let logoutError{
            
            print(logoutError)
        }
        let loginController = LoginViewController()
        loginController.messageController = self
        present(loginController, animated: true, completion: nil)
    }
    
    @objc func handleNewMessage(){
        
        let newMessageController = NewMessageController()
        // when navigating to newMessageController from the message controller we are sending value of message controller as not nil value. So when going to newMessageController it is carrying data form this vies controller to variable messageController in assigned in newMessageController.
        newMessageController.messageController = self
        let navController = UINavigationController(rootViewController : newMessageController)
        present(navController, animated: true, completion: nil)
    }
//    MARK: TableViewController Properties
    
    
}

