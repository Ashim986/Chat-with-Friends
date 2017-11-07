//
//  ChatLogController.swift
//  Game Of Chat
//
//  Created by ashim Dahal on 11/3/17.
//  Copyright © 2017 ashim Dahal. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController,UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    var user : User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    var messages = [Message]()
    
    func observeMessages(){
       guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let messageIDRefrence = Database.database().reference().child("userMessage").child(uid)
        messageIDRefrence.observe(.childAdded) { (snapshot) in
            
            let messageID = snapshot.key
            let messageRefrence = Database.database().reference().child("messages").child(messageID)
            messageRefrence.observeSingleEvent(of: .value, with: { (snapshot) in
                let message = Message()
                // make sure your key to messageObject matches with dictionary key
                guard let dictionary = snapshot.value as? [String : AnyObject] else {return}
                message.setValuesForKeys(dictionary)
                if message.chatPartnerID() == self.user?.id {
                    self.messages.append(message)
                }
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }, withCancel: nil)
        }
    }
    let containerView : UIView = {
       let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let  sendButton : UIButton = {
       let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var inputTextFiled : UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter Message", attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray])
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
       return textField
    }()
    let separatorLineView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
       return view
    }()
    
    let cellID = "cellID"
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handelBack))
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellID)
        setupInputComponents()
        
        
    }
    
//    MARK: Collectionview Properties
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
    
    
    func setupInputComponents(){
        
        view.addSubview(containerView)
        view.addSubview(sendButton)
        view.addSubview(inputTextFiled)
        view.addSubview(separatorLineView)
        constraintForAllComponents()
    }
//    MARK: View Constraint
    func constraintForAllComponents(){
        // container text view anchor x,y,w,h
        NSLayoutConstraint.activate([containerView.leftAnchor.constraint(equalTo: view.leftAnchor), containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor), containerView.widthAnchor.constraint(equalTo: view.widthAnchor), containerView.heightAnchor.constraint(equalToConstant: 50)])
        
        // Send button Anchor x,y,w,h
        NSLayoutConstraint.activate([sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor), sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor), sendButton.widthAnchor.constraint(equalToConstant: 50), sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor)])
        
        // InputTextField Anchor x,y,w,h
        NSLayoutConstraint.activate([inputTextFiled.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant : 8),inputTextFiled.centerYAnchor.constraint(equalTo: containerView.centerYAnchor), inputTextFiled.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 0),inputTextFiled.heightAnchor.constraint(equalTo: containerView.heightAnchor)])
        
        // saparatorLineView Anchor x,y,w,h
        NSLayoutConstraint.activate([separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor), separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor),separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor),separatorLineView.heightAnchor.constraint(equalToConstant: 1)])
        
    }
    @objc func handelBack(){
        dismiss(animated: true, completion: nil)
    }
    @objc func handleSend(){
    
        let refrences = Database.database().reference().child("messages")
        let childRefrence = refrences.childByAutoId()
        let toID = user!.id!
        let fromID = Auth.auth().currentUser!.uid
        let timeStamp : NSNumber = NSNumber(value: Int(Date().timeIntervalSince1970))
        let values :[String : Any] = ["text" : inputTextFiled.text!, "toID" : toID, "fromID" : fromID , "timeStamp": timeStamp]
//        childRefrence.updateChildValues(values)
        
        childRefrence.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error as Any)
            }
            let userMessageRefrence = Database.database().reference().child("userMessage").child(fromID)
            
            let messageID = childRefrence.key
            userMessageRefrence.updateChildValues([messageID : 1])
            
            let receipientMessageRefrence = Database.database().reference().child("userMessage").child(toID)
            
            receipientMessageRefrence.updateChildValues([messageID : 1])
        }
    }
    
//    MARK: TextField Properties
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
}
