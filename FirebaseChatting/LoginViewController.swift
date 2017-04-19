//
//  LoginViewController.swift
//  Chatting
//
//  Created by magicmon on 2017. 4. 17..
//  Copyright © 2017년 magicmon. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var fbLogin: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fbLogin.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let navi = segue.destination as? UINavigationController else { return }
        guard let chatVc = navi.viewControllers.first as? ChannelListViewController else { return }
        
        if segue.identifier == "LoginToChat" {
            chatVc.senderDisplayName = sender as? String ?? "guest"
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
            
            self.performSegue(withIdentifier: "LoginToChat", sender: "guest")
        })
    }
    
    @IBAction func loginDidTouch(_ sender: UIButton) {
        
        guard let email = emailField.text, let password = passwordField.text else { return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { [weak self] (user, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if let error = error {
                self?.alert(error.localizedDescription)
                return
            }
            
            self?.performSegue(withIdentifier: "LoginToChat", sender: email)
        })
    }
    
    @IBAction func googleDidTouch(_ sender: UIButton) {
        
    }
}

extension LoginViewController {
    fileprivate func alert(_ message: String?) {
        let alert = UIAlertController(title: "Chatting", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension LoginViewController: FBSDKLoginButtonDelegate {
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }

    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        defer {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if let error = error {
            alert(error.localizedDescription)
            return
        }
        
        guard let token = FBSDKAccessToken.current().tokenString else {
            return
        }
        
        
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: token)
        
        FIRAuth.auth()?.signIn(with: credential) { [weak self] (user, error) in
            if let error = error {
                self?.alert(error.localizedDescription)
                return
            }
            
            guard let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil) else {
                return
            }
            
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                if let error = error {
                    self?.alert(error.localizedDescription)
                    return
                } else {
                    print("\(result)")
                    print("\(FBSDKProfile.current()?.name)")
                    print("\(FBSDKProfile.current()?.userID)")
                    
                    guard let result = result as? Dictionary<String, AnyHashable> else {
                        self?.performSegue(withIdentifier: "LoginToChat", sender: "guest")
                        return
                    }
                    
                    self?.performSegue(withIdentifier: "LoginToChat", sender: result["name"] ?? "guest")
                }
            })
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
