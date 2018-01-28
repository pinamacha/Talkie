//
//  UserCell.swift
//  Talkie
//
//  Created by Ravi Pinamacha on 12/29/17.
//  Copyright © 2017 Divya. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    var message: Message? {
        didSet {
             setUpNameAndProfileImage()
            detailTextLabel?.text = message?.text
            if let seconds = message?.timeStamp?.doubleValue {
                let timeStampDate = NSDate(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timeStampDate as Date)
            }
    
           
        }
    }
    private func setUpNameAndProfileImage() {
      
        
        if let id = message?.chartPartnerId() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observe(.value, with: { (snapshot) in
                //print(snapshot)
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dict["name"] as? String
                    if let profileImageUrl = dict["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCatchwithUrlString(urlString: profileImageUrl)
                    }
                }
                
            }, withCancel: nil)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 80, y: (textLabel?.frame.origin.y)!-2, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        detailTextLabel?.frame = CGRect(x: 80, y: (detailTextLabel?.frame.origin.y)!+2, width: (detailTextLabel?.frame.width)!, height: (detailTextLabel?.frame.height)!)
    }
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        // imageView.image = UIImage(named: "bg")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.darkGray
        return label
    }()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        //        //ios 9 anchors
        //        //x,y,width, height  anchors
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        //x,y, width, height kKERXActionTypeAnchorPoints
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 17).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
