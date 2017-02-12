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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        FIRAuth.auth()?.addStateDidChangeListener({ (auth: FIRAuth, user: FIRUser?) in
            if user != nil {
                ChatHelper.sharedInstance.switchToNavigationViewController()
            } else {
                print("Unauthorized")
            }
        })
    }
    
    @IBAction func loginAnonymously(_ sender: Any) {
        ChatHelper.sharedInstance.loginAnonymously()
    }

}
