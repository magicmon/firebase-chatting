//
//  LoginViewController.swift
//  Chatting
//
//  Created by magicmon on 2017. 4. 17..
//  Copyright © 2017년 magicmon. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let email = emailField.text else { return }
        guard let navi = segue.destination as? UINavigationController else { return }
        guard let chatVc = navi.viewControllers.first as? ChannelListViewController else { return }
        
        if segue.identifier == "LoginToChat" {
            chatVc.senderDisplayName = email
        }
    }
}

extension LoginViewController {
    @IBAction func guestDidTouch(_ sender: UIButton) {
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self.performSegue(withIdentifier: "LoginToChat", sender: nil)
        })
    }
    
    @IBAction func loginDidTouch(_ sender: UIButton) {
        
        guard let email = emailField.text, let password = passwordField.text else { return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if let error = error {
                let alert = UIAlertController(title: "Chatting", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            
            self.performSegue(withIdentifier: "LoginToChat", sender: nil)
        })
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
