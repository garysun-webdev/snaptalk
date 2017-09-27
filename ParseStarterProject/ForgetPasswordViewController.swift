/*
 File: ForgetPasswordViewController
 Author: CoDex
 Purpose: This part is used to traceback password.
 */

import UIKit
import Parse


var wantToFindUser:[PFUser] = []
var foundSecurityQuestion:[PFObject]=[]

class ForgetPasswordViewController: UIViewController {
    
    
    @IBOutlet var usernameIn: UITextField!
    
    
    @IBOutlet var subButton1: UIButton!
    
    
    @IBOutlet var rePassword: UITextField!
    
    
    @IBOutlet var setButton: UIButton!
    @IBOutlet var subView: UIView!
    
    
    @IBOutlet var question1Label: UILabel!
    
    @IBOutlet var answer1: UITextField!
    
    
    @IBOutlet var question2Label: UILabel!
    
    
    @IBOutlet var question3Label: UILabel!
    
    
    @IBOutlet var answer2: UITextField!
    
    
    @IBOutlet var answer3: UITextField!
    
    
    @IBOutlet var subButton2: UIButton!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subView.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y > -keyboardSize.height / 2{
                self.view.frame.origin.y -= keyboardSize.height / 2}
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y < 0{
                self.view.frame.origin.y += keyboardSize.height / 2
            }
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: { (completed) in
            })
            
        }
    }

    
    
    @IBAction func action1(_ sender:
        UIButton) {
       
        var query = PFUser.query()
        query?.whereKey("username", equalTo:self.usernameIn.text!)
        
        
        do {
            
            let users = try query?.findObjects()
            
            if let users =  users  as? [PFUser] {
                wantToFindUser = users
                
            }
            
            
        } catch {
        
            print ("Could not get users")
            
        }
        
       
        print("*************************************")
        print(wantToFindUser)
        
        if wantToFindUser == [] {
            
            let title = "Warning"
            
            let message = "The username is not found"
            
            let action1 = "OK"
            
            let loginAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
            
            loginAlert.addAction(UIAlertAction(title:action1,style: UIAlertActionStyle.default, handler:nil))
            self.present(loginAlert, animated: true, completion: nil)

        }else{
            
            
          
            
            var query =    PFQuery(className: "SecurityQuestion")
            
            query.whereKey("username", equalTo:self.usernameIn.text!)
            do {
                
                
                
                let questions = try query.findObjects()
                
                
                
                if let questions =  questions  as? [PFObject] {
                    
                    
                    
                    foundSecurityQuestion = questions
        
                }
                
                
            } catch {
                
            print ("Could not get users")
                
            }
            print("000000000000000000000000000000")
            print(foundSecurityQuestion)
            
            if wantToFindUser == []{
                print("?????????????????????????????????????")
                let title = "Warning"
                
                let message = "You have not set the securoty question!!"
                
                let action1 = "OK"
                
                let loginAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
                
                loginAlert.addAction(UIAlertAction(title:action1,style: UIAlertActionStyle.default, handler:nil))
                self.present(loginAlert, animated: true, completion: nil)
                
            }else{
                
                self.subView.isHidden = false
                
                self.question1Label.text = (foundSecurityQuestion[0]["question"] as! [String])[0]
                self.question2Label.text = (foundSecurityQuestion[0]["question"] as! [String])[1]
                self.question3Label.text = (foundSecurityQuestion[0]["question"] as! [String])[2]
                
                
            }
            
            
        }
        
        

    }
    
    
    
    
    
    
    @IBAction func subAction2(_ sender: UIButton) {
      let correctAnswer1 = (foundSecurityQuestion[0]["answer"] as! [String])[0]
     let correctAnswer2 = (foundSecurityQuestion[0]["answer"] as! [String])[1]
    let correctAnswer3 = (foundSecurityQuestion[0]["answer"] as! [String])[2]
        if (correctAnswer1 == self.answer1.text && correctAnswer2 == self.answer2.text && correctAnswer3 == self.answer3.text) {
            print("coanima")
            self.performSegue(withIdentifier: "setPassword", sender: self)
            
        }else{
            
            let title = "Warning"
            
            let message = "Your answers are wrong!"
            
            let action1 = "OK"
            
            let loginAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
            
            loginAlert.addAction(UIAlertAction(title:action1,style: UIAlertActionStyle.default, handler:nil))
            self.present(loginAlert, animated: true, completion: nil)
  
            
        }
        
    }
    
  
  
   
    
    
}
