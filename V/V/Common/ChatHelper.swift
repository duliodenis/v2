//
//  ChatHelper.swift
//  V
//
//  Created by ddenis on 1/23/17.
//  Copyright © 2017 Dulio Denis. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class ChatHelper {
    static let sharedInstance = ChatHelper()
    
    func loginAnonymously() {
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if error == nil {
                print("UserID: \(user!.uid)")
                
                let newUser = FIRDatabase.database().reference().child("users").child((user?.uid)!)
                newUser.setValue(["username": "Anonymous",
                                  "id": "\(user!.uid)",
                                  "profileImageURL": "",
                                  "email": ""])
                
                self.switchToNavigationViewController()
            } else {
                print(error!.localizedDescription)
                return
            }
        })
    }
    
    func switchToNavigationViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = navigationController
    }

}
