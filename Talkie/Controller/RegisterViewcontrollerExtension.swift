//
//  LoginViewcontrollerExtension.swift
//  Talkie
//
//  Created by Ravi Pinamacha on 12/25/17.
//  Copyright © 2017 Divya. All rights reserved.
//

import UIKit
import Firebase

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
   @objc func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("Form is not valid")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil
            {
                print(error!)
                return
            }
            guard let uid = user?.uid else {
                return
            }
            //successfully authenticated user
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
            // comressionimages 0.1 bcoz need to reduce database menory usage.
            if let profileImage = self.userImage.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                        self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                    }
                })
            }
        })
    }
    private func registerUserIntoDatabaseWithUID(uid: String, values:[String: AnyObject]) {
        let ref = Database.database().reference()
        let userReference = ref.child("users").child(uid)
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err!)
                return
            }
            print("successfully saved")
            //self.messagesViewController?.fetchUserAndSetupNavBarTitle()
            let user = User()
            user.name = values["name"] as! String
            user.profileImageUrl = values["profileImageUrl"] as! String
            self.messagesViewController?.setUpNavBarWithUser(user: user)
           
            self.dismiss(animated: true, completion: nil)
        })
    }
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //print(info)
        var selectedImageFromPicker : UIImage?
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        }else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        dismiss(animated: true, completion: nil)
        if let selectedImage = selectedImageFromPicker {
            userImage.image = selectedImage
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
