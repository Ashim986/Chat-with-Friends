//
//  LoginController+Handeller.swift
//  Game Of Chat
//
//  Created by ashim Dahal on 10/6/17.
//  Copyright © 2017 ashim Dahal. All rights reserved.
//
//
import UIKit
import Firebase

extension LoginViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func handleRegister(){
        
        guard  let email = emailTextField.text, let password = passwordTextField.text , let name = nameTextField.text else {
            print("Form is not valid")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (user, err) in
            if err != nil {
                print(err as Any)
                return
            }
            guard let uid = user?.uid else {
                return
            }
            // sucessfully authenticated user
            
            // stroing Image in Data
            // fireBase will throw error if the child refrence is not created to store image
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profileImage").child("\(imageName).jpg")
            
            if let profileImage = self.profileImageView.image,let uploadData = UIImageJPEGRepresentation(profileImage, 0.1){
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, err) in
                    if err != nil{
                        print(err as Any)
                        return
                    }
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                        let values = ["name": name, "email" : email, "profileImageUrl": profileImageUrl]
                        self.registerUserIntoDatabaseWithUID(uid : uid, values: values as [String : AnyObject])
                    }
                    
                })
            }
        }
    }
    
    private func registerUserIntoDatabaseWithUID(uid : String, values: [String : AnyObject]){
        
        // Data upload Data
        let ref = Database.database().reference(fromURL: "https://gameofchat-b295a.firebaseio.com/")
        let userReference = ref.child("user").child(uid)
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil
            {
                print(err as Any)
            }
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    
    @objc func handleSelectProfileImageView(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated : true, completion : nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker : UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            //        print ((editedImage as AnyObject).size())
            selectedImageFromPicker = editedImage
        }
            
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        {
            selectedImageFromPicker = originalImage
            
        }
        if let selectedImage = selectedImageFromPicker{
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

