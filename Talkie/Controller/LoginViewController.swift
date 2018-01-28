//
//  LoginViewController.swift.swift
//  Talkie
//
//  Created by Ravi Pinamacha on 12/28/17.
//  Copyright © 2017 Divya. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
     var messagesViewcontroller : MessagesViewController!
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
        lb.backgroundColor = UIColor(red: 241/255, green: 92/255, blue: 37/255, alpha: 1.0)
        lb.setTitle("Login", for: .normal)
        lb.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return lb
    }()
    let registerBtn: UIButton = {
        let rb  = UIButton()
        rb.translatesAutoresizingMaskIntoConstraints = false
        rb.setTitle("Register", for: .normal)
        rb.addTarget(self, action: #selector(loginToRegister), for: .touchUpInside)
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
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        setupInputView()
    }
   
    func setupInputView() {
        
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
                                        toItem: view, attribute: .top, multiplier: 1.0, constant: 100)
       
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
    toItem: passwordTextField, attribute: .top, multiplier: 1.0, constant: 60)
    
    NSLayoutConstraint.activate([loginLeading, loginTrailing,logintop])
    
     view.addSubview(registerBtn)
        registerBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let rigLeading = NSLayoutConstraint(item: registerBtn, attribute:
            .leadingMargin, relatedBy: .equal, toItem: view,
                            attribute: .leadingMargin, multiplier: 1.0,
                            constant: 20)
        let rigTrailing = NSLayoutConstraint(item: registerBtn, attribute:
            .trailingMargin, relatedBy: .equal, toItem: view,
                             attribute: .trailingMargin, multiplier: 1.0, constant: -20)
        let rigtop = NSLayoutConstraint(item: registerBtn, attribute: .top, relatedBy: .equal,
                                        toItem: loginBtn, attribute: .top, multiplier: 1.0, constant: 60)
        NSLayoutConstraint.activate([rigLeading, rigTrailing,rigtop])
        
    }
    @objc func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("not valid")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error!)
                return
            }
            //self.messagesViewcontroller = MessagesViewController()
           self.messagesViewcontroller.fetchUserAndSetupNavBarTitle()
            self.present(self.messagesViewcontroller, animated: true, completion: nil)
        }
    }
     @objc func loginToRegister() {
        
   
        let registerVc = RegisterViewController()
        present(registerVc, animated: true, completion: nil)
    }

    
}
