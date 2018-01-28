//
//  ViewController.swift
//  Talkie
//
//  Created by Ravi Pinamacha on 12/22/17.
//  Copyright © 2017 Divya. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UITableViewController {
    
    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let image = UIImage(named: "edit")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessages))

        self.navigationController?.navigationBar.barTintColor = UIColor(red: 241/255, green: 92/255, blue: 37/255, alpha: 1.0)
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
       
       observeUserMessages()
        checkIfUserIsLoggedIn()
      tableView.register(UserCell.self, forCellReuseIdentifier: "cellId")
        tableView.allowsMultipleSelectionDuringEditing = true
    }

    var messages = [Message]()
    var messagedictionary = [String: Message]() //message dictionary
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let userId = snapshot.key
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                self.fetchMessagesWithMessageId(messageId: messageId)
            }, withCancel: nil)

        }, withCancel: nil)
        ref.observe(.childRemoved, with: { (snapshot) in
            print(snapshot.key)
            print(self.messagedictionary)
            self.messagedictionary.removeValue(forKey: snapshot.key)
            self.attempyReloadOfTable()
        }, withCancel: nil)
       
    }
    private func fetchMessagesWithMessageId(messageId: String) {
        let messageRef = Database.database().reference().child("messages").child(messageId)
        messageRef.observeSingleEvent(of:.value , with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                if let chartPartnerId = message.chartPartnerId() {
                    self.messagedictionary[chartPartnerId] = message
                
                }
                self.attempyReloadOfTable()
                
            }
        }, withCancel: nil)
    }
    private func attempyReloadOfTable() {
        //this is for reload images corretly
        self.timer?.invalidate()
        // print("cancel reload")
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        
        // print("set timer o.1")
    }
    var timer: Timer?
   @objc func handleReloadTable() {
        self.messages = Array(self.messagedictionary.values)//we are casting with array
        //sorting messages
        self.messages.sort(by: { (msg1, msg2) -> Bool in
            return (msg1.timeStamp?.intValue)! > (msg2.timeStamp?.intValue)!
        })
        DispatchQueue.main.async {
            print("reload table")
            self.tableView.reloadData()
        }
    }
   
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        guard  let chartPartnerId = message.chartPartnerId() else {
            return
        }
        let ref = Database.database().reference().child("users").child(chartPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dict = snapshot.value as? [String: AnyObject]
                else {
                    return
            }
            let user  = User()
            user.id = chartPartnerId
            user.name = dict["name"] as! String
            user.email = dict["email"] as! String
            user.profileImageUrl = dict["profileImageUrl"] as! String
            self.showChatcontroller(user: user)
        }, withCancel: nil)
      
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard  let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let message = self.messages[indexPath.row]
        if let chatPartnerId = message.chartPartnerId() {
            Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    print("Failed to delete message", error!)
                    return
                }
                self.messagedictionary.removeValue(forKey: chatPartnerId)
                self.attempyReloadOfTable()
//                this is one way deleting technic but it won't deleted permanently
//                self.messages.remove(at: indexPath.row)
//                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            })
        }
        
    }
    
    func checkIfUserIsLoggedIn() {

        if Auth.auth().currentUser?.uid == nil {
            handleLogout()
     }else {
            fetchUserAndSetupNavBarTitle()
        }
    }
   
    @objc func handleNewMessages() {
        let newMessageViewCintroller = NewMessageViewController()
        self.navigationController?.pushViewController(newMessageViewCintroller, animated: true)
    }
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid  else {
            //for some reasons uid  is null
            return
        }
        Database.database().reference().child("users").child(uid).observe(.value, with: { (snapshot) in
            //print(snapshot)
            if let dictionary =  snapshot.value as? [String: AnyObject] {
                //self.navigationItem.title = dictionary["name"]?.capitalized
                let user = User()
                user.name = dictionary["name"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                print(user.name)
                self.setUpNavBarWithUser(user: user)
            }
        }, withCancel: nil)
    }
    func setUpNavBarWithUser(user: User)  {
        messages.removeAll()
        messagedictionary.removeAll()
        tableView.reloadData()
        observeUserMessages()
        
        //let titleView = UIView()
        let titleView = UIButton()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        //        titleView.backgroundColor = UIColor.redColor()

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)

        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCatchwithUrlString(urlString: profileImageUrl)
        }

        containerView.addSubview(profileImageView)

        //ios 9 constraint anchors
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let nameLabel = UILabel()

        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        //need x,y,width,height anchors
        nameLabel.leftAnchor.constraint(equalTo:profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo:profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo:containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo:profileImageView.heightAnchor).isActive = true

        containerView.centerXAnchor.constraint(equalTo:titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo:titleView.centerYAnchor).isActive = true

        self.navigationItem.titleView = titleView

       // titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatcontroller)))
    //titleView.addTarget(self, action: #selector(showChatcontroller), for: .touchUpInside)
    }
    func showChatcontroller(user: User) {
      let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
      chatLogController.user = user
      navigationController?.pushViewController(chatLogController, animated: true)
    }
   
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        }catch let logoutError {
            print(logoutError)
        }
       
        let loginViewController = LoginViewController()
        loginViewController.messagesViewcontroller = self
        present(loginViewController, animated: true, completion: nil)
    }

}
