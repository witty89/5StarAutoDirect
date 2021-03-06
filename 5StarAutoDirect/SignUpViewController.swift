//
//  SignUpViewController.swift
//  5StarAutoDirect
//
//  Created by Clay Mills on 6/14/17.
//  Copyright © 2017 PineAPPle LLC. All rights reserved.
//

import UIKit
import FirebaseAuth
import KeychainSwift
import FirebaseDatabase

// We may want to put the code to tell what the initial VC is in the AppDelegate, appDidFinishLaunching instead of here

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var submitButton: UIImageView!
    @IBOutlet weak var signOutButton: UIButton!
    
    var isSignUp: Bool = true
    
    override func viewDidLoad() { // we can change this to VWA to stop the login from flashing
        super.viewDidLoad()
        
        let keyChain = DatabaseManager().keyChain
        if keyChain.get("uid") != nil {
            performSegue(withIdentifier: "signinToUserHomeVC", sender: nil)
        }
        
        signOutButton.imageView?.image = #imageLiteral(resourceName: "SignOut")
    }
    
    func completeSignIn (id: String) {
        let keyChain = DatabaseManager().keyChain
        keyChain.set(id , forKey: "uid")
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        guard let name = nameTextField.text, let phone = phoneTextField.text, let email = emailTextField.text, let password = passwordTextField.text else { return }
        // TODO: - add password field
        
        if isSignUp {
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                
                // This is my attempt to check if the user's email contains 5StarAuto, and then make them either a broker or not, based on that. If this doesn't work, delete next few lines
                
                let broker: Bool
                if email.uppercased().contains("5STARAUTO") {
                    broker = true
                } else {
                    broker = false
                }
                let user = User(name: name, phone: phone, email: email, isBroker: broker, messages: [])
                if user.isBroker {
                    self.completeSignIn(id: user.name)
                    self.performSegue(withIdentifier: "signinToBrokerTVC", sender: self)
                } else {
                    self.performSegue(withIdentifier: "signinToUserHomeVC", sender: self)
                    self.completeSignIn(id: user.name)
                }
                
            })
        } else {
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                if user != nil {
                    self.completeSignIn(id: user!.uid)
                    //User is found, go to home screen
                    
                    self.performSegue(withIdentifier: "signinToUserHomeVC", sender: self)
                } else {
                    //Error: check error and show message
                }
            })
        }
    }
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        DatabaseManager().keyChain.delete("uid")
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signinToBrokerTVC" {
            
            let createdUser = BrokerTableViewController.shared.user
            if let detailVC = segue.destination as? BrokerTableViewController {
                detailVC.user = createdUser
            }
        } else {
            if segue.identifier == "signinToUserHomeVC"{
            
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        phoneTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
    }
}
