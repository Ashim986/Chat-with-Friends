//
//  ChatLogController.swift
//  Game Of Chat
//
//  Created by ashim Dahal on 11/3/17.
//  Copyright © 2017 ashim Dahal. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

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
    
    
    let cellID = "cellID"
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handelBack))
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.collectionViewLayout.invalidateLayout()

        setupKeyboardObservers()
    }
    
    lazy var inputContainerView : ChatInputContainerView = {
       
        let chatInputControllerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputControllerView.chatLogController = self
        return chatInputControllerView
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
        cell.chatLogController = self
        
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
            cell.textView.isHidden = false
           
        }else if message.imageURL != nil {
            //fall in here if its an image message
            cell.bubbleWidthAnchor?.constant = 200
            cell.bubbleView.backgroundColor = .clear
            cell.textView.isHidden = true
           
        }
            cell.playButton.isHidden = message.videoURL == nil
            cell.message = message
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
    
  
    @objc func handelBack(){
        dismiss(animated: true, completion: nil)
    }
    @objc func handleSend(){

        let properties = ["text" : inputContainerView.inputTextFiled.text!] as [String : Any]
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
            // append properties dictionary onto value shomehow?
            values[key] = value
        }
        childRefrence.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error as Any)
            }
            self.inputContainerView.inputTextFiled.text = nil
            let userMessageRefrence = Database.database().reference().child("userMessage").child(fromID).child(toID)
            
            let messageID = childRefrence.key
            userMessageRefrence.updateChildValues([messageID : 1])
            
            let receipientMessageRefrence = Database.database().reference().child("userMessage").child(toID).child(fromID)
            
            receipientMessageRefrence.updateChildValues([messageID : 1])
        }
        
    }
//    MARK: TextField Properties
    
    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // we selected Video
       
        if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
            handleVideoSelectedForURL (url : videoURL)
            
        }else {
           handleImageSelectedFroInfo(info: info)
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func handleVideoSelectedForURL (url : URL) {
       
        let fileName = NSUUID().uuidString + ".mov"
        let uploadTask = Storage.storage().reference().child("messageVideo").child(fileName).putFile(from: url , metadata: nil, completion: { (metadata, error) in
            if error != nil {

                print("Failed to upload Video", error as Any)
            }
            if let videoURL = metadata?.downloadURL()?.absoluteString {
                
                if let thumbnailImage = self.thumbnailImageForVideoURL(fileURL: url) {
                
                    self.uploadToFireBaseStorageUsingImage(image: thumbnailImage, completion: { (imageURL ) in
                        let properties :[String : Any] = ["imageURL" : imageURL , "imageWidth" : thumbnailImage.size.width , "imageHeight" : thumbnailImage.size.height,"videoURL" : videoURL ]
                        self.sendMessageWithProperties(properties: properties)
                    })
                }
            }
        })
        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completedUnitCount)
            }
        }
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
        
    }
    
    private func thumbnailImageForVideoURL(fileURL : URL) -> UIImage? {
        
        let asset = AVAsset(url: fileURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        }catch let err {
            print(err)
        }
        
        return nil
    }
    
    private func handleImageSelectedFroInfo(info : [String : Any]){
        // we selected image
        var selectedImageFromPicker : UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            // print ((editedImage as AnyObject).size())
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker{
            uploadToFireBaseStorageUsingImage(image: selectedImage, completion: { (imageURL) in
                self.sendMessageWithImageURL(imageURL: imageURL , image : selectedImage)
            })
        }
    }
    
    private func uploadToFireBaseStorageUsingImage(image : UIImage , completion: @escaping (_ imageURL : String) -> ()) {
        
        let imageName = NSUUID().uuidString
        let storageRefrence = Storage.storage().reference().child("messageImages").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2){
            storageRefrence.putData(uploadData, metadata: nil, completion: { (metaData, error) in
                if error != nil{
                    print("faile to upload Image ", error as Any)
                    return
                }
                if let imageURL = metaData?.downloadURL()?.absoluteString {
                    completion(imageURL)
                }
            })
        }
    }
    var startingFrame : CGRect?
    var blackBackgroundView : UIView?
    var startingImageView : UIImageView?
    // custom zooming logic
    func performZoomInForStratingImageView(stargingImageView : UIImageView)  {
        
        self.startingImageView = stargingImageView
        self.startingImageView?.isHidden = true
        startingFrame = stargingImageView.superview?.convert(stargingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.image = stargingImageView.image
       
        zoomingImageView.isUserInteractionEnabled = true
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(performZoomOut))
        imageTap.numberOfTapsRequired = 1
        zoomingImageView.addGestureRecognizer(imageTap)
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = .black
            blackBackgroundView?.alpha = 0
        
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                // using proportion we have h1/w1 = h2/w2
                let height = (self.startingFrame?.height)! * keyWindow.frame.width / (self.startingFrame?.width)!
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
            }, completion: nil)
            
        }
 }
    
    @objc func performZoomOut(tapGesture : UITapGestureRecognizer) {
        
        if let zoomOutView = tapGesture.view {
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutView.frame = self.startingFrame!
                zoomOutView.layer.cornerRadius = 16
                zoomOutView.clipsToBounds = true
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
            }, completion: { (completed : Bool) in
                zoomOutView.removeFromSuperview()
                self.blackBackgroundView?.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
}
