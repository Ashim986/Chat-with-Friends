//
//  ChatLogController.swift
//  Game Of Chat
//
//  Created by ashim Dahal on 11/3/17.
//  Copyright © 2017 ashim Dahal. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController,UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user : User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    var messages = [Message]()
    
    func observeMessages(){
        guard let uid = Auth.auth().currentUser?.uid , let toID = user?.id else { return }
        
        let messageIDRefrence = Database.database().reference().child("userMessage").child(uid).child(toID)
        messageIDRefrence.observe(.childAdded) { (snapshot) in
            
            let messageID = snapshot.key
            let messageRefrence = Database.database().reference().child("messages").child(messageID)
            messageRefrence.observeSingleEvent(of: .value, with: { (snapshot) in
                
                // make sure your key to messageObject matches with dictionary key
                guard let dictionary = snapshot.value as? [String : AnyObject] else {return}
                let message = Message(dictionary: dictionary)
                
                // use this method if you are not initilizing in object model class
                //message.setValuesForKeys(dictionary)
                self.messages.append(message)
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    // scroll to the last index
                    
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
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
    
    lazy var uploadedImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "upload_image_icon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(handleUploadTap))
        imageTap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(imageTap)
        
       return imageView
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

        setupKeyboardObservers()
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
  
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidShow), name: NSNotification.Name.UIKeyboardDidShow , object: nil)
    }
    @objc func keyBoardDidShow(){
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
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
        
        if let messageImageURL = message.imageURL {
            cell.bubbleView.backgroundColor = .clear
            cell.messageImageView.sd_setImage(with: URL(string : messageImageURL), completed: nil)
            cell.messageImageView.isHidden = false
        }else {
            cell.bubbleView.isHidden = false
            cell.messageImageView.isHidden = true
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
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text : text).width + 20
        }else if message.imageURL != nil {
            //fall in here if its an image message
            cell.bubbleWidthAnchor?.constant = 200
        }
       
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height : CGFloat = 80
        
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 18
        }else if let imageWidth = message.imageWidth?.floatValue , let imageHeight = message.imageHeight?.floatValue {
            
            height = CGFloat(Float(imageHeight / imageWidth) * 200)
            
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text : String) -> CGRect {
        
        let size = CGSize(width: 200, height: 500)
        let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string : text).boundingRect(with: size, options: option, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func setupInputComponents(containerView : UIView) -> UIView{
        
        containerView.addSubview(sendButton)
        containerView.addSubview(inputTextFiled)
        containerView.addSubview(separatorLineView)
        containerView.addSubview(uploadedImageView)
        constraintForViewComponents(containerView : containerView)
        return containerView
    }
//    MARK: View Constraint
    func constraintForViewComponents(containerView : UIView){
        // Send button Anchor x,y,w,h
        NSLayoutConstraint.activate([sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor), sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor), sendButton.widthAnchor.constraint(equalToConstant: 50), sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor)])
        
        // InputTextField Anchor x,y,w,h
        NSLayoutConstraint.activate([inputTextFiled.leftAnchor.constraint(equalTo: uploadedImageView.rightAnchor, constant: 4),inputTextFiled.centerYAnchor.constraint(equalTo: containerView.centerYAnchor), inputTextFiled.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 0),inputTextFiled.heightAnchor.constraint(equalTo: containerView.heightAnchor)])
        
        // saparatorLineView Anchor x,y,w,h
        NSLayoutConstraint.activate([separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor), separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor),separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor),separatorLineView.heightAnchor.constraint(equalToConstant: 1)])
        // Constraint for uploadedImageView
        NSLayoutConstraint.activate([uploadedImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 4), uploadedImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor), uploadedImageView.widthAnchor.constraint(equalToConstant: 44), uploadedImageView.heightAnchor.constraint(equalToConstant : 44)])
        
        
    }
    @objc func handelBack(){
        dismiss(animated: true, completion: nil)
    }
    @objc func handleSend(){
    
        let properties = ["text" : inputTextFiled.text!] as [String : Any]
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithImageURL(imageURL : String , image : UIImage){
        
       
        let properties :[String : Any] = ["imageWidth" : image.size.width , "imageHeight" : image.size.height, "imageURL" : imageURL, ]
        sendMessageWithProperties(properties: properties)
        
    }
    
    private func sendMessageWithProperties(properties : [String : Any]){
        
        let refrences = Database.database().reference().child("messages")
        let childRefrence = refrences.childByAutoId()
        let toID = user!.id!
        let fromID = Auth.auth().currentUser!.uid
        let timeStamp : NSNumber = NSNumber(value: Int(Date().timeIntervalSince1970))
        
        
        var values = ["toID" : toID, "fromID" : fromID , "timeStamp": timeStamp] as [String : Any]
        
        for (key, value ) in properties {
            values[key] = value
        }
        
    
        // append properties dictionlay onto value shomehow?
        
        
        childRefrence.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error as Any)
            }
            self.inputTextFiled.text = nil
            let userMessageRefrence = Database.database().reference().child("userMessage").child(fromID).child(toID)
            
            let messageID = childRefrence.key
            userMessageRefrence.updateChildValues([messageID : 1])
            
            let receipientMessageRefrence = Database.database().reference().child("userMessage").child(toID).child(fromID)
            
            receipientMessageRefrence.updateChildValues([messageID : 1])
        }
        
    }
//    MARK: TextField Properties
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    
    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker : UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            //        print ((editedImage as AnyObject).size())
            selectedImageFromPicker = editedImage
        }
            
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        {
            selectedImageFromPicker = originalImage
            
        }
        if let selectedImage = selectedImageFromPicker{
            uploadToFireBaseStorageUsingImage(image: selectedImage)
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    private func uploadToFireBaseStorageUsingImage(image : UIImage) {
        
        let imageName = NSUUID().uuidString
        let storageRefrence = Storage.storage().reference().child("messageImages").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2){
            storageRefrence.putData(uploadData, metadata: nil, completion: { (metaData, error) in
                if error != nil{
                    print("faile to upload Image ", error as Any)
                    return
                }
                if let imageURL = metaData?.downloadURL()?.absoluteString {
                    self.sendMessageWithImageURL(imageURL: imageURL , image : image)
                }
             
            })
        }
        
    }
}
