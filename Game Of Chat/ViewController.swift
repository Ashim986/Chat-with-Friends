//
//  ViewController.swift
//  Game Of Chat
//
//  Created by ashim Dahal on 10/4/17.
//  Copyright © 2017 ashim Dahal. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//
//        let ref = Database.database().reference(fromURL: "https://gameofchat-b295a.firebaseio.com/")
//        ref.updateChildValues(["someValue" : 123123])
//
      view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector (handleLogout))
        // user in not logged in
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
    }
    
    @objc func handleLogout (){
        do{
            try Auth.auth().signOut()
            
        }catch let logoutError{
            
            print(logoutError)
        }
        
        present(loginViewController(), animated: true, completion: nil)
    }

}

