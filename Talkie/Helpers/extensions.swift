//
//  extensions.swift
//  Talkie
//
//  Created by Ravi Pinamacha on 12/26/17.
//  Copyright © 2017 Divya. All rights reserved.
//

import UIKit


//catching images

let  imageCache = NSCache<NSString, UIImage >()
extension UIImageView {
    @objc func loadImageUsingCatchwithUrlString(urlString: String) {
        self.image = nil
        //first check catche for image
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage as? UIImage
            return
        }
        //otherwise fire of new download
        let url = URL(string: urlString)
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            DispatchQueue.main.async {
                if let downloadingImage = UIImage(data: data!) {
                    imageCache.setObject(downloadingImage, forKey: urlString as NSString )
                    self.image = downloadingImage
                }
                
            }
        })
        task.resume()
    }
   
}
