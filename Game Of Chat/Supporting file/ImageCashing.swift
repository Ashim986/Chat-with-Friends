//
//  ImageCashing.swift
//  Game Of Chat
//
//  Created by ashim Dahal on 10/7/17.
//  Copyright © 2017 ashim Dahal. All rights reserved.
//

import UIKit

let imageCashe = NSCache<NSString, UIImage>()

extension UIImageView{
    
    func loadImageUingCasheWithUrlString(urlString : String){
       // check for cache Image first
        self.image = nil
        if let cashedImage = imageCashe.object(forKey: urlString as NSString){
            self.image = cashedImage
            return
        }
        
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, respons, err) in
                // download hit an error so lets retun out
                if err != nil {
                    print(err as Any)
                    return
                }
                DispatchQueue.main.async {
                    
                    if let downloadedImage = UIImage(data : data!) {
                        imageCashe.setObject(downloadedImage, forKey: (urlString as NSString))
                    }
                    
                
//                    self.image = UIImage(data: data!)
                }
                
                
            }).resume()
        }
    }
    
}
