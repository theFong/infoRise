//
//  CreateAccountViewController.swift
//  InfoRise
//
//  Created by Alec Fong on 12/3/16.
//  Copyright © 2016 Alec Fong. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var FirstNameTextField: UITextField!
    @IBOutlet weak var LastNameTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var ConfirmPassTextField: UITextField!
    @IBOutlet weak var ErrorLabel: UILabel!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    let PasswordDoesNotMatchString: String? = "passwords do not match"
    let MissingFieldString: String? = "missing information"
    let InvalidCreationString: String? = "account already exists"
    
    var TextFields:[UITextField] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopLoadingAnimation()
        
        ErrorLabel.text = ""
        TextFields = [FirstNameTextField,LastNameTextField,EmailTextField,PasswordTextField,ConfirmPassTextField]
        
        FirstNameTextField.delegate = self
        FirstNameTextField.tag = 0
        LastNameTextField.delegate = self
        LastNameTextField.tag = 1
        EmailTextField.delegate = self
        EmailTextField.tag = 2
        PasswordTextField.delegate = self
        PasswordTextField.tag = 3
        ConfirmPassTextField.delegate = self
        ConfirmPassTextField.tag = 4
        
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
        FirstNameTextField.resignFirstResponder()
        LastNameTextField.resignFirstResponder()
        EmailTextField.resignFirstResponder()
        PasswordTextField.resignFirstResponder()
        ConfirmPassTextField.resignFirstResponder()
    }
    
    @IBAction func CreateAndLoginButtonPressed(sender: AnyObject) {
        startLoadingAnimation()
        if self.validate() {
            stopLoadingAnimation()
            return
        }
        FIRAuth.auth()?.createUserWithEmail(EmailTextField.text!, password: PasswordTextField.text!, completion: { (user, error) in
            if error != nil {
                self.ErrorLabel.text = error?.localizedDescription
                self.stopLoadingAnimation()
            } else {
                //success
                self.createUserInDB()
                self.stopLoadingAnimation()
                self.performSegueWithIdentifier("main", sender: nil)
            }
        })
    }

    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("unwindToLogin", sender: self)
    }
    
    func createUserInDB() {
        let databaseRef = FIRDatabase.database().reference()
        let usersValue: [String : String] = ["name" : FirstNameTextField.text!+" "+LastNameTextField.text!, "email" : EmailTextField.text!, "notify_time" : "15:00"]
        databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).setValue(usersValue)
    }
    
    func validate() -> Bool {
        var once: Bool! = true
        var hasBeenAppended: Bool! = false
        var errorString: String! = ""
        for tf in self.TextFields {
            if tf.text?.characters.count == 0 && once {
                once = false
                hasBeenAppended = true
                errorString.appendContentsOf(MissingFieldString!)
            }
        }
        if PasswordTextField.text != ConfirmPassTextField.text  {
            errorString.appendContentsOf(hasBeenAppended ==  true ? ", \(PasswordDoesNotMatchString!)" : PasswordDoesNotMatchString!)
            hasBeenAppended = true
        }
        self.ErrorLabel.text = errorString
        return hasBeenAppended
    }
    
    func stopLoadingAnimation(){
        ErrorLabel.hidden = false
        loadingView.stopAnimating()
        
    }
    
    func startLoadingAnimation(){
        ErrorLabel.hidden = true
        loadingView.startAnimating()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }

}
