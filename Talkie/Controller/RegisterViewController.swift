//
//  LoginVC.swift
//  Talkie
//
//  Created by Ravi Pinamacha on 12/22/17.
//  Copyright © 2017 Divya. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    lazy var userImage : UIImageView = {
        let uimg = UIImageView()
        uimg.translatesAutoresizingMaskIntoConstraints = false
        uimg.backgroundColor = UIColor(red: 241/255, green: 92/255, blue: 37/255, alpha: 1.0)
        uimg.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(handleSelectProfileImageView)))
        uimg.isUserInteractionEnabled = true
        return uimg
    }()
    let nameTextField: UITextField = {
        let ntf = UITextField()
        ntf.translatesAutoresizingMaskIntoConstraints = false
        ntf.backgroundColor = UIColor.lightText
        ntf.textColor = UIColor.white
        ntf.placeholder = "Enter User Name"
        ntf.borderStyle = .roundedRect
        ntf.autocorrectionType = UITextAutocorrectionType.no
        ntf.keyboardType = UIKeyboardType.default
        ntf.returnKeyType = UIReturnKeyType.done
        ntf.clearButtonMode = UITextFieldViewMode.whileEditing;
        ntf.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return ntf
    }()
    
    let emailTextField : UITextField = {
        let etf = UITextField()
        etf.translatesAutoresizingMaskIntoConstraints = false
        etf.backgroundColor = UIColor.lightText
        etf.textColor = UIColor.white
        etf.placeholder = "Enter email here"
        etf.borderStyle = .roundedRect
        etf.autocorrectionType = UITextAutocorrectionType.no
        etf.keyboardType = UIKeyboardType.default
        etf.returnKeyType = UIReturnKeyType.done
        etf.clearButtonMode = UITextFieldViewMode.whileEditing;
        return etf
    }()
    
    let passwordTextField : UITextField = {
        let ptf = UITextField()
        ptf.translatesAutoresizingMaskIntoConstraints = false
        ptf.backgroundColor = UIColor.lightText
        ptf.textColor = UIColor.white
        ptf.placeholder = "Enter password here"
        ptf.isSecureTextEntry = true
        ptf.borderStyle = .roundedRect
        ptf.autocorrectionType = UITextAutocorrectionType.no
        ptf.keyboardType = UIKeyboardType.default
        ptf.returnKeyType = UIReturnKeyType.done
        ptf.clearButtonMode = UITextFieldViewMode.whileEditing;
        return ptf
    }()
    let loginBtn: UIButton = {
        let lb  = UIButton()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.setTitle("Login", for: .normal)
        lb.addTarget(self, action: #selector(RegisterToLogin), for: .touchUpInside)
        return lb
    }()
    let registerBtn: UIButton = {
        let rb  = UIButton()
        rb.translatesAutoresizingMaskIntoConstraints = false
        rb.backgroundColor = UIColor(red: 241/255, green: 92/255, blue: 37/255, alpha: 1.0)
        rb.setTitle("Register", for: .normal)
        rb.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return rb
    }()
    let backgorundImage: UIImageView = {
        let bg = UIImageView()
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.image = UIImage(named: "bg")
        bg.alpha = 0.25
        bg.contentMode = .scaleAspectFill
        return bg
    }()
    let logo : UIImageView = {
        let lg = UIImageView()
        lg.translatesAutoresizingMaskIntoConstraints = false
        lg.image = UIImage(named: "talkie")
        return lg
    }()
    var messagesViewController: MessagesViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        setInputFileds()

        
    }
    func setInputFileds() {
        
        view.addSubview(backgorundImage)
        backgorundImage.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgorundImage.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgorundImage.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgorundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
 
        view.addSubview(logo)
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logo.bottomAnchor.constraint(equalTo:view.bottomAnchor , constant: -50).isActive = true
        logo.widthAnchor.constraint(equalToConstant: 250).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
  
        view.addSubview(userImage)
        
        let imageCenterX = NSLayoutConstraint(item: userImage, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
        let imagetop = NSLayoutConstraint(item: userImage, attribute: .top, relatedBy: .equal,
                                          toItem: view, attribute: .top, multiplier: 1.0, constant: 30)
        let imageHeight = NSLayoutConstraint(item: userImage, attribute: .height, relatedBy: .equal,
                toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 120)
        let imageWidth = NSLayoutConstraint(item: userImage, attribute: .width, relatedBy: .equal,
                                             toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 120)
        
            NSLayoutConstraint.activate([imageCenterX,imagetop,imageHeight,imageWidth])


         view.addSubview(nameTextField)
        let nameLeading = NSLayoutConstraint(item: nameTextField, attribute:
            .leadingMargin, relatedBy: .equal, toItem: view,
                            attribute: .leadingMargin, multiplier: 1.0,
                            constant: 20)

        let nameTrailing = NSLayoutConstraint(item: nameTextField, attribute:
            .trailingMargin, relatedBy: .equal, toItem: view,
                             attribute: .trailingMargin, multiplier: 1.0, constant: -20)

        let nametop = NSLayoutConstraint(item: nameTextField, attribute: .top, relatedBy: .equal,
                                          toItem: userImage, attribute: .top, multiplier: 1.0, constant: 140)



        NSLayoutConstraint.activate([nameLeading, nameTrailing,nametop])

        
        view.addSubview(emailTextField)
        emailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        let emailLeading = NSLayoutConstraint(item: emailTextField, attribute:
            .leadingMargin, relatedBy: .equal, toItem: view,
                            attribute: .leadingMargin, multiplier: 1.0,
                            constant: 20)

        let emailTrailing = NSLayoutConstraint(item: emailTextField, attribute:
            .trailingMargin, relatedBy: .equal, toItem: view,
                             attribute: .trailingMargin, multiplier: 1.0, constant: -20)

        let emailtop = NSLayoutConstraint(item: emailTextField, attribute: .top, relatedBy: .equal,
                                          toItem: nameTextField, attribute: .top, multiplier: 1.0, constant: 60)



        NSLayoutConstraint.activate([emailLeading, emailTrailing,emailtop])


        
        view.addSubview(passwordTextField)
        passwordTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        let pwdLeading = NSLayoutConstraint(item: passwordTextField, attribute:
            .leadingMargin, relatedBy: .equal, toItem: view,
                            attribute: .leadingMargin, multiplier: 1.0,
                            constant: 20)

        let pwdTrailing = NSLayoutConstraint(item: passwordTextField, attribute:
            .trailingMargin, relatedBy: .equal, toItem: view,
                             attribute: .trailingMargin, multiplier: 1.0, constant: -20)

        let pwdtop = NSLayoutConstraint(item: passwordTextField, attribute: .top, relatedBy: .equal,
                                        toItem: emailTextField, attribute: .top, multiplier: 1.0, constant: 60)

        NSLayoutConstraint.activate([pwdLeading, pwdTrailing,pwdtop])


        
        view.addSubview(registerBtn)
        registerBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        let regLeading = NSLayoutConstraint(item: registerBtn, attribute:
            .leadingMargin, relatedBy: .equal, toItem: view,
                            attribute: .leadingMargin, multiplier: 1.0,
                            constant: 20)
        let regTrailing = NSLayoutConstraint(item: registerBtn, attribute:
            .trailingMargin, relatedBy: .equal, toItem: view,
                             attribute: .trailingMargin, multiplier: 1.0, constant: -20)
        let regtop = NSLayoutConstraint(item: registerBtn, attribute: .top, relatedBy: .equal,
                                          toItem: passwordTextField, attribute: .top, multiplier: 1.0, constant: 60)
        NSLayoutConstraint.activate([regLeading, regTrailing,regtop])



        
        view.addSubview(loginBtn)
        loginBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        let loginLeading = NSLayoutConstraint(item: loginBtn, attribute:
            .leadingMargin, relatedBy: .equal, toItem: view,
                            attribute: .leadingMargin, multiplier: 1.0,
                            constant: 20)
        let loginTrailing = NSLayoutConstraint(item: loginBtn, attribute:
            .trailingMargin, relatedBy: .equal, toItem: view,
                             attribute: .trailingMargin, multiplier: 1.0, constant: -20)
        let logintop = NSLayoutConstraint(item: loginBtn, attribute: .top, relatedBy: .equal,
                                        toItem: registerBtn, attribute: .top, multiplier: 1.0, constant: 60)
        NSLayoutConstraint.activate([loginLeading, loginTrailing,logintop])

    }
    @objc func RegisterToLogin() {
        let loginViewcontroller = LoginViewController()
        present(loginViewcontroller, animated: true, completion: nil)
    }

}

    

