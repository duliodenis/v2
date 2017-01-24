//
//  LoginViewController.swift
//  V
//
//  Created by ddenis on 1/21/17.
//  Copyright © 2017 Dulio Denis. All rights reserved.
//

import UIKit
import FirebaseAuth


class LoginViewController: UIViewController {

    @IBOutlet weak var loginAnonButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginAnonButton.layer.borderColor = UIColor.white.cgColor
        loginAnonButton.layer.borderWidth = 2.0
        loginAnonButton.layer.cornerRadius = 5        
    }
    
    @IBAction func loginAnonymously(_ sender: Any) {
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if error == nil {
                print("UserID: \(user!.uid)")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = navigationController
            } else {
                print(error!.localizedDescription)
                return
            }
        })
    }

}
