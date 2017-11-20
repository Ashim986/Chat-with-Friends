//
//  ChatInputContainerView.swift
//  Game Of Chat
//
//  Created by ashim Dahal on 11/19/17.
//  Copyright © 2017 ashim Dahal. All rights reserved.
//

import UIKit

class ChatInputContainerView: UIView,UITextFieldDelegate {
    
    var chatLogController : ChatLogController {
        didSet {
            sendButton.addTarget(chatLogController, action: #selector(chatLogController.handleSend), for: .touchUpInside)
            
            let imageTap = UITapGestureRecognizer(target: chatLogController, action: #selector(chatLogController.handleUploadTap))
            imageTap.numberOfTapsRequired = 1
            uploadedImageView.addGestureRecognizer(imageTap)
        }
    }
    
    let  sendButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
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
        return imageView
    }()
    
    override init(frame: CGRect) {
        self.chatLogController = ChatLogController()
        super.init(frame: frame)
        self.backgroundColor = .white
        setupInputComponents()
        
    }
    
    func setupInputComponents(){
        
        addSubview(sendButton)
        addSubview(inputTextFiled)
        addSubview(separatorLineView)
        addSubview(uploadedImageView)
        constraintForViewComponents()
        
    }
    //    MARK: View Constraint
    func constraintForViewComponents(){
        // Send button Anchor x,y,w,h
        NSLayoutConstraint.activate([sendButton.rightAnchor.constraint(equalTo: rightAnchor), sendButton.centerYAnchor.constraint(equalTo: centerYAnchor), sendButton.widthAnchor.constraint(equalToConstant: 50), sendButton.heightAnchor.constraint(equalTo: heightAnchor)])
        
        // InputTextField Anchor x,y,w,h
        NSLayoutConstraint.activate([inputTextFiled.leftAnchor.constraint(equalTo: uploadedImageView.rightAnchor, constant: 4),inputTextFiled.centerYAnchor.constraint(equalTo: centerYAnchor), inputTextFiled.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 0),inputTextFiled.heightAnchor.constraint(equalTo: heightAnchor)])
        
        // saparatorLineView Anchor x,y,w,h
        NSLayoutConstraint.activate([separatorLineView.topAnchor.constraint(equalTo: topAnchor), separatorLineView.leftAnchor.constraint(equalTo: leftAnchor),separatorLineView.widthAnchor.constraint(equalTo: widthAnchor),separatorLineView.heightAnchor.constraint(equalToConstant: 1)])
        // Constraint for uploadedImageView
        NSLayoutConstraint.activate([uploadedImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 4), uploadedImageView.centerYAnchor.constraint(equalTo: centerYAnchor), uploadedImageView.widthAnchor.constraint(equalToConstant: 44), uploadedImageView.heightAnchor.constraint(equalToConstant : 44)])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatLogController.handleSend()
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
