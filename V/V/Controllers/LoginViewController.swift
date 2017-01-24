//
//  LoginViewController.swift
//  V
//
//  Created by ddenis on 1/21/17.
//  Copyright © 2017 Dulio Denis. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController {

    @IBOutlet weak var loginAnonButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginAnonButton.layer.borderColor = UIColor.white.cgColor
        loginAnonButton.layer.borderWidth = 2.0
        loginAnonButton.layer.cornerRadius = 5        
    }
    
    @IBAction func loginAnonymously(_ sender: Any) {
        ChatHelper.sharedInstance.loginAnonymously()
    }

}
