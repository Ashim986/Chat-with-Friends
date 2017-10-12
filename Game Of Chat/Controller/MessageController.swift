//
//  ViewController.swift
//  Game Of Chat
//
//  Created by ashim Dahal on 10/4/17.
//  Copyright © 2017 ashim Dahal. All rights reserved.
//

import UIKit
import Firebase

class MessageController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rightBarButtonImage = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: rightBarButtonImage, style: .plain, target: self, action: #selector(handleNewMessage))
        
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector (handleLogout))
        
        // user in not logged in
        checkIfUserIsLoggedIn()
    }
    
    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        else{
           fetchUserAndSetNavBarTitle()
        }
    }
    
    func fetchUserAndSetNavBarTitle() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
         // for some reason if uid is nil
            return
        }
        Database.database().reference().child ("user").child(uid).observe(.value, with: { (snapshot) in
            print(snapshot)
            if let dictionary = snapshot.value as? [String : AnyObject ]{
                self.navigationItem.title = dictionary["name"] as? String
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
        present(loginController, animated: true, completion: nil)
    }
    
    @objc func handleNewMessage(){
        let newMessageController = NewMessageController()
        let navController = UINavigationController(rootViewController : newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
}

