//
//  LoginStudyViewController.swift
//  Northland Church
//
//  Created by Gregory Weiss on 1/18/17.
//  Copyright © 2017 NorthlandChurch. All rights reserved.
//

import UIKit

class LoginStudyViewController: UIViewController, LoginMCAPIControllerProtocol, UITextFieldDelegate
{
    
    let defaultsSeries = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    
    @IBOutlet weak var submitButtonOutlet: UIButton!
    
    
    var loginController: LoginMCAPIController!
    
    let loginNotification = NSNotificationCenter.defaultCenter()



    override func viewDidLoad()
    {
        super.viewDidLoad()
       // submitButtonOutlet.layer.cornerRadius = 8.0
        self.hideKeyboardWhenTappedAround()
        
        loginController = LoginMCAPIController(delegate: self)
        
        
//        emailTextField.addTarget(self, action: #selector(LoginStudyViewController.checkFields(_:)), forControlEvents: .EditingDidEnd)
//        firstNameTextField.addTarget(self, action: #selector(LoginStudyViewController.checkFields(_:)), forControlEvents: .EditingDidEnd)
//        lastNameTextField.addTarget(self, action: #selector(LoginStudyViewController.checkFields(_:)), forControlEvents: .EditingDidBegin)
//


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissTapped(sender: UIButton)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func goToPolicyTapped(sender: UIButton)
    {
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("PrivacyViewController") as! PrivacyViewController
        self.presentViewController(detailVC, animated: true, completion: nil)
      //  let nacVC = segue.destinationViewController as! UINavigationController
        //        let privacyVC = nacVC.viewControllers[0] as! PrivacyViewController
        //            self.performSegueWithIdentifier("PrivacySegue", sender: sender)
                   // nacVC.pushViewController(privacyVC, animated: true)
        //        //nacVC.presentViewController(privacyVC, animated: true, completion: nil)
       // self.navigationController!.pushViewController(detailVC, animated: true)

    }
    
    @IBAction func submitTapped(sender: UIButton)
    {
        if  (emailTextField.text?.characters.count)! > 0 && (emailTextField.text?.containsString("@"))! && (emailTextField.text?.containsString("."))!
        {
            loginController.sendLoginToMailChimp(emailTextField.text!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!)
            loginNotification.postNotificationName("GoToStudy", object: nil)
            defaultsSeries.setBool(true, forKey: "IsSignedUp")
            anotherDismiss()
        }
        else
        {
            presentCheckAll()
        }
        
    }
    
    func tryToSubmitLogin()
    {
        if  (emailTextField.text?.characters.count)! > 0 && (emailTextField.text?.containsString("@"))! && (emailTextField.text?.containsString("."))!
        {
            loginController.sendLoginToMailChimp(emailTextField.text!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!)
            loginNotification.postNotificationName("GoToStudy", object: nil)
            defaultsSeries.setBool(true, forKey: "IsSignedUp")
            anotherDismiss()
        }
        else
        {
            presentCheckAll()
        }

        
    }
    
    func anotherDismiss()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func userHasSignedUpSuccessfully()
    {
        print("HAS SIGNED UP!!!")
        defaultsSeries.setBool(true, forKey: "IsSignedUp")
        
       // seriesScrollView.scrollEnabled = true
        
//        UIView.animateWithDuration(1.0) {
//            self.loginBaseView.alpha = 0
//        }
        
        
    }
    
    func checkFields(sender: UITextField)
    {
        sender.text = sender.text?.stringByTrimmingCharactersInSet(.whitespaceCharacterSet())
        guard
            let email = emailTextField.text where !email.isEmpty,
            let first = firstNameTextField.text where !first.isEmpty,
            let last = lastNameTextField.text where !last.isEmpty
            else { return }
        // enable your button if all conditions are met
        sender.returnKeyType = .Go
    }
    
    // TextField delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if  (emailTextField.text?.characters.count)! > 0 && (emailTextField.text?.containsString("@"))! && firstNameTextField.text?.characters.count > 0 && lastNameTextField.text?.characters.count > 0 && (emailTextField.text?.containsString("@"))!
        {
            textField.returnKeyType = .Go
            
        }
        if textField == emailTextField && emailTextField.text?.characters.count > 0 && !(emailTextField.text?.containsString("@"))! && (emailTextField.text?.containsString("."))!
        {
            presentRedoEmail()
            
        }
        
        
        if textField == emailTextField && emailTextField.text?.characters.count > 0
        {
            emailTextField.resignFirstResponder()
            if firstNameTextField.text?.characters.count == 0
            {
                firstNameTextField.becomeFirstResponder()
            }
            else if lastNameTextField.text?.characters.count == 0
            {
                lastNameTextField.becomeFirstResponder()
            }
        }
        else if textField == firstNameTextField && firstNameTextField.text?.characters.count > 0
        {
            firstNameTextField.resignFirstResponder()
            if lastNameTextField.text?.characters.count == 0
            {
                lastNameTextField.becomeFirstResponder()
            }
            else if emailTextField.text?.characters.count == 0
            {
                emailTextField.becomeFirstResponder()
            }

        }
        
        else if textField == lastNameTextField && lastNameTextField.text?.characters.count > 0
        {
            lastNameTextField.resignFirstResponder()
            if emailTextField.text?.characters.count == 0
            {
             emailTextField.becomeFirstResponder()
            }
            else if firstNameTextField.text?.characters.count == 0
            {
                firstNameTextField.becomeFirstResponder()
            }
            else if emailTextField.text?.characters.count > 0 && firstNameTextField.text?.characters.count > 0
            {
               tryToSubmitLogin()
            }
            
            
//            loginController.sendLoginToMailChimp(emailTextField.text!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!)
//            loginNotification.postNotificationName("GoToStudy", object: nil)
//            anotherDismiss()
            
        }
        return true
    }
    
    func presentRedoEmail()
    {
        let alertController1 = UIAlertController(title: "Please enter a valid email address", message: "example: jonsmith@gmail.com", preferredStyle: .Alert)
        // Add the actions
        alertController1.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
       // alertController1.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        
        print("Invalid email")
        alertController1.show()
        //loadingIndicator.stopAnimating()

        
    }
    
    func presentCheckAll()
    {
        let alertController1 = UIAlertController(title: "Please make sure all fields are completed", message: "Check that your email address is correct. You may use initials for your name if you prefer.", preferredStyle: .Alert)
        // Add the actions
        alertController1.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        // alertController1.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        
        print("Invalid email")
        alertController1.show()
        //loadingIndicator.stopAnimating()
        
        
    }
    
/*
    let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("LiturgyDetailViewController") as! LiturgyDetailViewController
    navigationController?.pushViewController(detailVC, animated: true)
*/

    
    


    
    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
//    {
//        if segue.identifier == "PrivacySegue"
//        {
//        let nacVC = segue.destinationViewController as! UINavigationController
//        let privacyVC = nacVC.viewControllers[0] as! PrivacyViewController
//            self.performSegueWithIdentifier("PrivacySegue", sender: sender)
//           // nacVC.pushViewController(privacyVC, animated: true)
//        //nacVC.presentViewController(privacyVC, animated: true, completion: nil)
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        }
//    }
    

}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
