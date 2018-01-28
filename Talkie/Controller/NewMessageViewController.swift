//
//  NewMessageViewController.swift
//  Talkie
//
//  Created by Ravi Pinamacha on 12/25/17.
//  Copyright © 2017 Divya. All rights reserved.
//

import UIKit
import Firebase

class NewMessageViewController: UITableViewController {
   
    var users = [User]()
    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //we are using usercell class
        tableView.register(UserCell.self, forCellReuseIdentifier: "cellId")
        fetchUser()
    }
    
    
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let user = User()
                
                //if you use this setter . your app will crash if your class properties doesn't exactly  match up with firebase
                //dictionary keys
              //user.setValuesForKeys(dictionary)
                user.id = snapshot.key
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                let currentUser: String = (Auth.auth().currentUser?.uid)!
                //Filter current user
                if user.id != currentUser {
                    self.users.append(user)
                } else {
                    debugPrint("Current user filtered")
                }
                //this will crash because of background thread, so let use dispatch async to fix
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
         
        }, withCancel: nil)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //for memory efficiency we are using deequeue
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCatchwithUrlString(urlString: profileImageUrl)
       }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
     var messageViewController: MessagesViewController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
       
       
//        dismiss(animated: true) {
//            let  user  = self.users[indexPath.row]
//            self.messageViewController?.showChatcontroller(user)
//        }
        let  user  = self.users[indexPath.row]
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
   

}

