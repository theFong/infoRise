//
//  LoginViewController.swift
//  InfoRise
//
//  Created by Alec Fong on 12/3/16.
//  Copyright © 2016 Alec Fong. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseDatabase

class LoginViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var GoogleSignInButton: GIDSignInButton!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var ErrorLabel: UILabel!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    var fireBaseRef: FIRDatabaseReference!
    
    let AccountExistsString: String? = "Account already exists."
    let InvalidLoginString: String? =  "Invalid login."
    let LoginSuccessString: String? = "Login Successful"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopLoadingAnimation()
        fireBaseRef = FIRDatabase.database().reference()
        
        EmailTextField.delegate = self
        EmailTextField.tag = 0
        PasswordTextField.delegate = self
        PasswordTextField.tag = 1
        
        GIDSignIn.sharedInstance().uiDelegate = self
        ErrorLabel.text = ""
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
                self.performSegueWithIdentifier("main", sender: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        EmailTextField.resignFirstResponder()
        PasswordTextField.resignFirstResponder()
    }
    
    //google sign in
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        startLoadingAnimation()
        if error != nil {
            ErrorLabel.text = error.localizedDescription
            stopLoadingAnimation()
            return
        }
        
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken, accessToken: authentication.accessToken)
        FIRAuth.auth()?.signInWithCredential(credential, completion: { (user: FIRUser?, error: NSError?) in
            if error != nil {
                self.ErrorLabel.text = error?.localizedDescription
                self.stopLoadingAnimation()
            } else {
                //if user doesnt exist create new one
                self.fireBaseRef.child("users").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    
                    if !snapshot.hasChild((user?.uid)!){
                        self.createUserInDB((user?.displayName)!, email: (user?.email)!, uid: (user?.uid)!)
                    }
                })
                
                self.loginSuccess()
            }
        })
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {}
    
    func stopLoadingAnimation(){
        ErrorLabel.hidden = false
        loadingView.stopAnimating()

    }
    
    func startLoadingAnimation(){
        ErrorLabel.hidden = true
        loadingView.startAnimating()
    }
    
    func handleLogout() {
        GIDSignIn.sharedInstance().signOut()
        try! FIRAuth.auth()!.signOut()
    }
    
    func createUserInDB(name: String, email: String, uid: String) {
        let databaseRef = FIRDatabase.database().reference()
        let usersValue: [String : String] = ["name" : name, "email" : email, "notify_time" : "15:00"]
        databaseRef.child("users").child((uid)).setValue(usersValue)
    }
    
    @IBAction func CreateAccountButton(sender: AnyObject) {
        //segue
    }
    
    @IBAction func LoginButton(sender: AnyObject) {
        self.login()
    }

    @IBAction func ForgotPasswordPressed(sender: AnyObject) {
        if EmailTextField.text?.characters.count == 0 {
            ErrorLabel.text = "Please provide an email"
            return
        }
        FIRAuth.auth()?.sendPasswordResetWithEmail(EmailTextField.text!, completion: { (error) in
            
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                
                if error != nil {
                    self.ErrorLabel.text = error?.localizedDescription
                    // Error - Unidentified Email
                    
                } else {
                    
                    // Success - Sends recovery email
                    let alertController = UIAlertController(title: "Email Sent", message: "An email has been sent. Please, check your email now.", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                
            }})
    }
    
    func login() {
        startLoadingAnimation()
            FIRAuth.auth()?.signInWithEmail(self.EmailTextField.text!, password: self.PasswordTextField.text!, completion: { (user, error) in
                if error != nil{
                    self.ErrorLabel.text = error?.localizedDescription
                    self.stopLoadingAnimation()
                } else {
                    self.loginSuccess()
                }
            })
        
    }
    
    func loginSuccess() {
        stopLoadingAnimation()
        self.ErrorLabel.textColor = UIColor.greenColor()
        self.ErrorLabel.text = self.LoginSuccessString
        self.performSegueWithIdentifier("main", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }

}
