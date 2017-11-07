//
//  MessageCell.swift
//  Game Of Chat
//
//  Created by ashim Dahal on 11/5/17.
//  Copyright © 2017 ashim Dahal. All rights reserved.
//

import UIKit
import Firebase

class MessageCell: UITableViewCell {
    
    var message : Message? {
        didSet {
            setupNameAndProfileImage()
            detailTextLabel?.text = message?.text

            if let seconds = message?.timeStamp?.doubleValue {
                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                timeLabel.text = dateFormatter.string(from: timestampDate as Date)

            }
            
        }
    }
    private func setupNameAndProfileImage (){
        if let id  = message?.chatPartnerID() {
            let refrence = Database.database().reference().child("users").child(id)
            
            refrence.observe(.value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String : Any]{
                    self.textLabel?.text = dictionary["name"] as? String
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageViewInMessage.sd_setImage(with: URL(string : profileImageUrl), completed: nil)
                    }
                    
                }
                
            }, withCancel: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: (textLabel?.frame.origin.y)! - 2, width: frame.width, height: (textLabel?.frame.height)!)
        detailTextLabel?.frame = CGRect(x: 64, y: (detailTextLabel?.frame.origin.y)! + 2, width: frame.width, height: (detailTextLabel?.frame.height)!)
        
    }
    
    let profileImageViewInMessage : UIImageView = {
       let image = UIImageView()
        image.image = #imageLiteral(resourceName: "nedstark")
        image.layer.cornerRadius = 24
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        return image
    }()
    let timeLabel : UILabel = {
        let label = UILabel()
        label.text = "HH:MM:SS"
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super .init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageViewInMessage)
        addSubview(timeLabel)
        addConstraintforViews()
        
    }
    func addConstraintforViews(){
        
       // constraint for profile Image view
        NSLayoutConstraint.activate([profileImageViewInMessage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),profileImageViewInMessage.centerYAnchor.constraint(equalTo: self.centerYAnchor), profileImageViewInMessage.widthAnchor.constraint(equalToConstant: 48), profileImageViewInMessage.heightAnchor.constraint(equalToConstant: 48) ])
        
        // constraint for Time Label (x,y,width,height)
        NSLayoutConstraint.activate([timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 5), timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant : 8), timeLabel.widthAnchor.constraint(equalToConstant: 90),timeLabel.heightAnchor.constraint(equalToConstant: 14)])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
