//
//  chatLogContainerView.swift
//  Talkie
//
//  Created by Ravi Pinamacha on 1/5/18.
//  Copyright © 2018 Divya. All rights reserved.
//

import UIKit

class ChatInputContainerView: UIView , UITextFieldDelegate{
    var chatLogController : ChatLogController? {
        didSet {
               sendButton.addTarget(chatLogController, action: #selector(ChatLogController.handleSend), for: .touchUpInside)
              uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.handleUploadOnTap)))
        }
    }
    //classlevel textfiled
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Text Message"
        textField.textColor = UIColor.black
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
   let  uploadImageView: UIImageView = {
        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named: "photos")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        return uploadImageView
    }()
    
      let sendButton = UIButton(type: .system)
   
    override init(frame: CGRect) {
        super.init(frame: frame)
   
        backgroundColor = UIColor.white
  
    
        addSubview(uploadImageView)
    
    //x,y,w,h
    uploadImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    uploadImageView.centerYAnchor.constraint(equalTo:centerYAnchor).isActive = true
    uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
    uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
    
  
    sendButton.setTitle("send", for: .normal)
    sendButton.translatesAutoresizingMaskIntoConstraints = false
    addSubview(sendButton)
    //x,y,w,h
    sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
    sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
 
    
    addSubview(self.inputTextField)
    
    //x,y,w,h
    self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
    self.inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
    self.inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    
    let separatorLineView = UIView()
    separatorLineView.backgroundColor = UIColor(red: 220, green: 220, blue: 220, alpha: 1.0)
    separatorLineView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(separatorLineView)
    
    //x,y,w,h
    separatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    separatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    separatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatLogController?.handleSend()
        return true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
