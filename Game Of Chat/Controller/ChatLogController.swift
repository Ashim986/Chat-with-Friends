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
        textField.keyboardType = .emailAddress
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
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handelBack))
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.keyboardDismissMode = .interactive

//        setupKeyboardObservers()
    }
    
    lazy var inputContainerView : UIView? = {
       
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = .white
        return setupInputComponents(containerView: containerView)
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // This Code is for animating keyboard display and dismiss keyboard.
//    func setupKeyboardObservers(){
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//
//    }
//    @objc func handleKeyboardWillShow(notification : Notification){
//        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
//            let keyboardRect = keyboardFrame.cgRectValue
//            let keyboardHeight = keyboardRect.height
//            // we will bring the containerview above somehow
//            buttomContainerAnchor?.constant = -keyboardHeight
//            buttomContainerAnchor?.isActive = true
//        }
//
//        if let keyBoardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
//            UIView.animate(withDuration: keyBoardAnimationDuration, animations: {
//                self.view.layoutIfNeeded()
//            })
//        }
//    }
    
    @objc func handleKeyboardWillHide(notification : Notification){
     
        buttomContainerAnchor?.constant = 0
        buttomContainerAnchor?.isActive = true
        if let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            UIView.animate(withDuration: keyboardAnimationDuration, animations: {
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
//    MARK: Collectionview Properties
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        setupCell(cell: cell, message: message)
    
        return cell
    }
    
    func setupCell (cell : ChatMessageCell , message : Message) {
        
        if let profileImageURL = user?.profileImageUrl {
            cell.profileImageView.sd_setImage(with: URL(string : profileImageURL), completed: nil)
        }
        if message.fromID == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        }else {
            // grey area for bubble
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        // lets modify the bubbleView width anchor
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 20
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height : CGFloat = 80
        if let text = messages[indexPath.item].text {
            height = estimateFrameForText(text: text).height + 18
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text : String) -> CGRect {
        
        let size = CGSize(width: 200, height: 500)
        let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string : text).boundingRect(with: size, options: option, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    var buttomContainerAnchor : NSLayoutConstraint?
    
    func setupInputComponents(containerView : UIView) -> UIView{
        
        containerView.addSubview(sendButton)
        containerView.addSubview(inputTextFiled)
        containerView.addSubview(separatorLineView)
        constraintForViewComponents(containerView : containerView)
        return containerView
    }
//    MARK: View Constraint
    func constraintForViewComponents(containerView : UIView){
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
            self.inputTextFiled.text = nil
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
