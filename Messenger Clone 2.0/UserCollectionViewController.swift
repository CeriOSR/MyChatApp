//
//  UserCollectionViewController.swift
//  Messenger Clone 2.0
//
//  Created by Rey Cerio on 2016-11-22.
//  Copyright © 2016 CeriOS. All rights reserved.
//

//HAVE TO USE A STRUCT TO POPULATE THE UICOLLECTIONVIEW!!!!!!!!!!!!!!!!*******************************

import UIKit
import Firebase

//id, name, email, profileImage
var chosenUser = [String]()

class UserCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    struct userObject {
        
        var userId: String
        var userName: String
        var userEmail: String
        var userProfilePicture: String?
        
    }

    
    var user: [userObject] = []
    
    //var chosen: UserCollectionViewController.userObject?
    
    @IBOutlet weak var currentUserImageView: UIImageView!
    
    @IBOutlet weak var currentUserNameLabel: UILabel!
    
    @IBOutlet weak var currentUserEmailLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //replace with overflow button later
    @IBAction func logoutButton(_ sender: Any) {
        
        handleLogout()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        
        collectionView.dataSource = self
        
        checkIfUserIsLoggedIn()
        
        fetchUser()

    }
    
    func checkIfUserIsLoggedIn() {
        
        if FIRAuth.auth()?.currentUser?.uid == nil{
            
            perform(#selector(handleLogout), with: nil, afterDelay: 0.3)
            
        } else {
            
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    if let profileImage = dictionary["profileImageURL"] as! String? {
                    
                        self.currentUserImageView.loadImageUsingCacheWithUrlString(urlString: profileImage)
                        
                    }
                    
                    self.currentUserNameLabel.text = dictionary["name"] as! String?
                    
                    self.currentUserEmailLabel.text = dictionary["email"] as! String?
                    
                }
                
            })
            
            
        }
        
    }
    
    func handleLogout() {
        
        do {
            
            try FIRAuth.auth()?.signOut()
        
        } catch let logoutError as NSError {
            
            print(logoutError.localizedDescription)
            
        }
        
        //Facebook logout
        //let logoutFacebook = FBSDKLoginManager()
        
        //logoutFacebook.logout()
        
        performSegue(withIdentifier: "logoutSegue", sender: self)
        
        
    }
    
    func fetchUser() {
        
        let ref = FIRDatabase.database().reference()
        
        let currentUserEmail = FIRAuth.auth()?.currentUser?.email
            
        ref.child("users").observe(FIRDataEventType.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let users = User()
                //users.setValuesForKeys(dictionary)
                
                users.id = snapshot.key as String?
                users.name = dictionary["name"] as! String?
                users.profileImageURL = dictionary["profileImageURL"] as! String?
                users.email = dictionary["email"] as! String?
                users.password = dictionary["password"] as! String?
                
                //if statement so current user isnt displayed on the collectionView
                if users.email != currentUserEmail {
                    self.user.append(userObject(userId: users.id!, userName: users.name!, userEmail: users.email!, userProfilePicture: users.profileImageURL!))
                }
                
                DispatchQueue.main.async(execute: {
                 
                    self.collectionView?.reloadData()
                 
                })
                
            }
            
        }, withCancel: nil)
        
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return user.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCell", for: indexPath) as! UserCollectionViewCell
        
        let cellUsers = user[indexPath.row]
        
        cell.userNameLabel.text = cellUsers.userName
        
        if let profileImageURL =  cellUsers.userProfilePicture {
            
            cell.userImageView?.loadImageUsingCacheWithUrlString(urlString: profileImageURL)
        }

        return cell
    }
    
    //var chatLogViewController: ChatLogViewController?
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        chosenUser = [self.user[indexPath.item].userId, self.user[indexPath.item].userName, self.user[indexPath.item].userEmail, self.user[indexPath.item].userProfilePicture! ]
        
        performSegue(withIdentifier: "usersToChatLogSegue", sender: self)
        
     }
    
}




