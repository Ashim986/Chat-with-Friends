//
//  ViewController.swift
//  Game Of Chat
//
//  Created by ashim Dahal on 10/4/17.
//  Copyright © 2017 ashim Dahal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
      view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector (handleLogout))
    }
    
    @objc func handleLogout (){
        present(loginViewController(), animated: true, completion: nil)
    }

}

