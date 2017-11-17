//
//  ChatMessageCell.swift
//  Game Of Chat
//
//  Created by ashim Dahal on 11/7/17.
//  Copyright © 2017 ashim Dahal. All rights reserved.
//

import UIKit
import AVFoundation

class  ChatMessageCell: UICollectionViewCell {
    var chatLogController : ChatLogController?
    var message : Message?
    let activityIndicatorView : UIActivityIndicatorView = {
        let activityIndicator =  UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
       return activityIndicator
    }()
    
    static let blueColor = UIColor(r: 0, g: 137, b: 240)
    
    let textView : UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.text = "some sample text"
        textView.textColor = .white
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    let profileImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "nedstark")
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
        let bubbleView : UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var playButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
   lazy var messageImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(handleMessageImageTap))
        imageTap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(imageTap)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    @objc func handleMessageImageTap(tapGesture: UITapGestureRecognizer){
        
        if message?.videoURL != nil {
            return
        }
        let imageView = tapGesture.view as! UIImageView
        self.chatLogController?.performZoomInForStratingImageView(stargingImageView: imageView)
    }
    
    var bubbleWidthAnchor : NSLayoutConstraint?
    var bubbleViewRightAnchor : NSLayoutConstraint?
    var bubbleViewLeftAnchor : NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        bubbleView.addSubview(messageImageView)
        bubbleView.addSubview(playButton)
        bubbleView.addSubview(activityIndicatorView)
        constraingForView()
        
    }
    
    func constraingForView() {
        // x,y,width, height
        
        NSLayoutConstraint.activate([textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant : 8), textView.topAnchor.constraint(equalTo: self.topAnchor),textView.rightAnchor.constraint(equalTo : bubbleView.rightAnchor), textView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor)  ])
        // bubble constraint x,y, w, h
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant : 8)
            
        NSLayoutConstraint.activate([bubbleView.topAnchor.constraint(equalTo: self.topAnchor), bubbleWidthAnchor!,bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor) ])
        
        // profile Image view constraint
        NSLayoutConstraint.activate([profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor , constant : 8), profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor), profileImageView.widthAnchor.constraint(equalToConstant: 32), profileImageView.heightAnchor.constraint(equalToConstant: 32)])
        
        // messageImageView constraing inside bubble view
        NSLayoutConstraint.activate([messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor), messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor), messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor), messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor)])
       
        // playButton constraint
       NSLayoutConstraint.activate([playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor), playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor), playButton.widthAnchor.constraint(equalToConstant: 40), playButton.heightAnchor.constraint(equalToConstant: 40)])
        
        // activity Indicator vie
       NSLayoutConstraint.activate([activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor), activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor), activityIndicatorView.widthAnchor.constraint(equalToConstant: 40), activityIndicatorView.heightAnchor.constraint(equalToConstant: 40)])
    }
    
    var playerLayer : AVPlayerLayer?
    var player : AVPlayer?
    @objc func handlePlay() {
        
        if let videoURLString = message?.videoURL , let url = URL(string : videoURLString) {
            player = AVPlayer(url: url)
            
            playerLayer = AVPlayerLayer(player: player!)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            player?.play()
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
            
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
