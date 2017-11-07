//
//  ChatMessageCell.swift
//  Game Of Chat
//
//  Created by ashim Dahal on 11/7/17.
//  Copyright © 2017 ashim Dahal. All rights reserved.
//

import UIKit

class  ChatMessageCell: UICollectionViewCell {
    
    let textView : UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .blue
        textView.text = "some sample text"
        textView.textColor = .white
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textView)
        
        constraingForView()
        
    }
    
    func constraingForView() {
        NSLayoutConstraint.activate([textView.rightAnchor.constraint(equalTo: self.rightAnchor), textView.topAnchor.constraint(equalTo: self.topAnchor),textView.widthAnchor.constraint(equalToConstant: 180), textView.heightAnchor.constraint(equalTo: self.heightAnchor)  ])
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
