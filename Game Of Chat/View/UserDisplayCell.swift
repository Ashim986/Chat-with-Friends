//
//  UserDisplayCell.swift
//  Game Of Chat
//
//  Created by ashim Dahal on 10/7/17.
//  Copyright © 2017 ashim Dahal. All rights reserved.
//

import UIKit


class UserCell: UITableViewCell {

    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: (textLabel?.frame.origin.y)! - 2, width: frame.width, height: (textLabel?.frame.height)!)
        detailTextLabel?.frame = CGRect(x: 64, y: (detailTextLabel?.frame.origin.y)! + 2, width: frame.width, height: (detailTextLabel?.frame.height)!)
        
    }
    
    let profileImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "nedstark")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    
        addSubview(profileImageView)
        anchorForProfileImageView()
    
    }
    func anchorForProfileImageView () {
        NSLayoutConstraint.activate([ profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant : 8),
                                      profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                                      profileImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 48),
                                      profileImageView.heightAnchor.constraint(equalToConstant: 48)
            ])
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
