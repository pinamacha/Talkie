//
//  ChatLogController.swift
//  Talkie
//
//  Created by Ravi Pinamacha on 12/27/17.
//  Copyright © 2017 Divya. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation


class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    var messages = [Message]()
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else {
            return
        }
      let userMessageRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
        let messageId = snapshot.key
           let messageRef =  Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dict = snapshot.value as? [String: AnyObject] else {
                    return
                }
                self.messages.append(Message(dictionary: dict))
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    if self.messages.count > 0 {
                        let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0)
                        self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
                    }
                  
                }
            }, withCancel: nil)
        }, withCancel: nil )
        
    }

    
    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationItem.title = "new chat"
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
//        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 50, 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(chatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive

         setUpKeyBoardObserves()
    }
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    lazy var inputcontainerView : ChatInputContainerView = {
        let chatInputContainerView = ChatInputContainerView(frame:  CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainerView.chatLogController = self
        return chatInputContainerView

    }()
    @objc func handleUploadOnTap() {
       let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(imagePickerController, animated: true, completion: nil)
    }
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //print(info)
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] {
            //we selected a video
            handleVideoSelectedForUrl(url: videoUrl as! URL)
        }else {
            //we selected an image
            handleImageSelectedForInfo(info: info as [String : AnyObject])
        }
        dismiss(animated: true, completion: nil)
      
    }
    private func handleImageSelectedForInfo(info: [String: AnyObject]) {
        var selectedImageFromPicker : UIImage?
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        }else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            uploadFirbaseStorageUsingImage(image: selectedImage, completion: { (imageUrl) in
                
             self.sendMessageWithImageUrl(imageUrl: imageUrl,image: selectedImage)
            })
        }
    }
    private func handleVideoSelectedForUrl(url: URL) {
        let fileName = NSUUID().uuidString + ".mov"
        let uploadTask = Storage.storage().reference().child("messages_videos").child(fileName).putFile(from: url, metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                print("File Not uploaded: ",    error!)
                return
            }
            if let videoUrl =  metadata?.downloadURL()?.absoluteString {
                if let thumbnailImage = self.thumbnailImageForVideoUrl(fileUrl: url) {
                    
                    self.uploadFirbaseStorageUsingImage(image: thumbnailImage
                        , completion: { (imageUrl) in
                            let properties = ["imageWidth": thumbnailImage.size.width,"imageHeight": thumbnailImage.size.height,"imageUrl": imageUrl,"videoUrl": videoUrl ] as [String : Any]
                            self.sendMessageWithProperties(properties: properties as [String : Any])
                    })
                    
                }
               
            }
        })
        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completedUnitCount)
            }
        }
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
    }
    private func thumbnailImageForVideoUrl(fileUrl: URL)  -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator =  AVAssetImageGenerator(asset: asset)
        do {
            let thumnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumnailCGImage)
        }catch let err {
            print(err)
        }
       return nil
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    private func uploadFirbaseStorageUsingImage(image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Failed To Upload Image", error!)
                    return
                }
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                  completion(imageUrl)
                }
            })
        }
      
    }
   
    override var inputAccessoryView: UIView? {
        get {
           return inputcontainerView
        }
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    func setUpKeyBoardObserves() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardDidShow), name: .UIKeyboardDidShow, object: nil)
        
//      NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardWillShow), name: .UIKeyboardWillShow, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    @objc func handleKeyBoardDidShow() {
        if messages.count > 0 {
            let indexPath = NSIndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
        }
   
    }
    @objc func handleKeyBoardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo? [UIKeyboardFrameEndUserInfoKey] as? NSValue  {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyBoardduration = notification.userInfo? [UIKeyboardAnimationDurationUserInfoKey] as! Double

            //move container view up
            containerViewBottomAnchor?.constant = -keyboardRectangle.height
            UIView.animate(withDuration: keyBoardduration, animations: {
                self.view.layoutIfNeeded()
            })
        }

    }
    @objc func handleKeyBoardWillHide(notification: NSNotification) {
        //move container view down
        let keyBoardduration = notification.userInfo? [UIKeyboardAnimationDurationUserInfoKey] as! Double

        //move container view up
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyBoardduration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  =  collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! chatMessageCell
        cell.chatLogController = self
        let message = messages[indexPath.row]
        cell.message = message
        cell.textView.text = message.text
   
        setUpcell(cell: cell, message: message)
        
        if let text = message.text {
                cell.bubbleWidthAnchor?.constant = estimatedFrameForText(text: text).width + 30
                cell.textView.isHidden = false
        }else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
             cell.textView.isHidden = true
            cell.bubbleView.backgroundColor = UIColor.clear
            
        }
       cell.playButton.isHidden = message.videoUrl == nil
        return cell
    }
    private func setUpcell(cell: chatMessageCell, message: Message) {
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCatchwithUrlString(urlString: profileImageUrl)
        }
        if let messageImageUrl = message.imageUrl {
            cell.messageImageview.loadImageUsingCatchwithUrlString(urlString: messageImageUrl)
            cell.messageImageview.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        }else {
            cell.messageImageview.isHidden = true
        }
        if message.fromId == Auth.auth().currentUser?.uid {
            //orange bubble
            cell.bubbleView.backgroundColor = chatMessageCell.orangeColorShade
            cell.profileImageView.isHidden = true
            cell.bubbleRightAnchor?.isActive = true
            cell.bubbleLeftAnchor?.isActive = false
            
        }else {
            //gray bubble
            cell.bubbleView.backgroundColor = UIColor.lightGray
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
        }
        
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        //get estimated height
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimatedFrameForText(text: text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue  {
            
            // h1 / w1 = h2 / w2
            // solve for h1
            // h1  = h2 / w2 * w1
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    private func estimatedFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    @objc func handleSend() {
        let properties = ["text":inputcontainerView.inputTextField.text!] as [String : Any]
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithImageUrl(imageUrl: String,image: UIImage) {
        let properties = ["imageUrl": imageUrl,"imageWidth": image.size.width,"imageHeight": image.size.height ] as [String : Any]
        sendMessageWithProperties(properties: properties as [String : Any])
    }
    
    private func sendMessageWithProperties(properties: [String: Any]) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId() //to generate list of messages by id
        let toId = user?.id
        let fromId = Auth.auth().currentUser!.uid
        let timeStamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        var values = [ "toId" : toId!, "fromId" : fromId, "timeStamp": timeStamp ] as [String : Any]
        
        //append propeties dictionary into values
        //key is $0 value is $1
        //this is refactoring
        properties.forEach({values[$0.0] = $0.1})

        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            self.inputcontainerView.inputTextField.text = nil
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId
                ).child(toId!)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId!).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
    }
   
    
    
    //zooming logic
    var startingFrame: CGRect?
    var blackBagroundView: UIView?
    var startingImageView: UIImageView?
    
    func performZoomingForStartingImageView(startingImageView: UIImageView) {
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
       // print(startingFrame)
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBagroundView = UIView(frame: keyWindow.frame)
            blackBagroundView?.backgroundColor = UIColor.black
            keyWindow.addSubview(blackBagroundView!)
            keyWindow.addSubview(zoomingImageView)
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.blackBagroundView?.alpha = 1
                self.inputcontainerView.alpha = 0
                
                // h2/w1 = h1/w1
                //h2 = h1/w1 * w1
                let height = (self.startingFrame?.height)!/(self.startingFrame?.width)! * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
            }, completion: nil)
        }
        
    }
    @objc func handleZoomOut(tapGesture: UIGestureRecognizer) {
        if let zoominOutImage = tapGesture.view {
            //need to animate to back to controller
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                zoominOutImage.frame = self.startingFrame!
                zoominOutImage.layer.cornerRadius = 15
                zoominOutImage.clipsToBounds = true
                self.blackBagroundView?.alpha = 0
            }, completion: { (completed: Bool) in
                zoominOutImage.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
}



