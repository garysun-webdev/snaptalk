/*
 File: SecurityQuestionViewController
 Author: CoDex
 Purpose: This part is used to set the security questions.
 */

import UIKit
import Parse
class SecurityQuestionViewController: UIViewController {
    
    
    @IBOutlet var question1: UITextField!
    
    @IBOutlet var question2: UITextField!

    @IBOutlet var question3: UITextField!
    
    
    @IBOutlet var answer1: UITextField!
    
    
    
    @IBOutlet var answer2: UITextField!
    
 
    @IBOutlet var answer3: UITextField!
    
    
    @IBOutlet var password: UITextField!
    
    

    @IBOutlet var submitButton: UIButton!
   
    
    var securityQuestion:[PFObject] = []
    
    func loadQuestion(){
        var query = PFQuery(className:"SecurityQuestion")
        query.whereKey("username", equalTo:(PFUser.current()?.username!)! as String)
        
        do {
            
            let questions = try query.findObjects()
            
            if let questions =  questions  as? [PFObject] {
                
                for question in questions {
                    
                    self.securityQuestion.append(question)
                    
                }
                
                
                
            }
            
            
        } catch {
            
            print ("Could not get users")
            
        }

    }
    
    
    
    
    @IBAction func sbumitAction(_ sender: UIButton) {
        
        var question:[String] = []
        var answer:[String] = []
        question.append(self.question1.text!)
        question.append(self.question2.text!)
        question.append(self.question3.text!)
        
        
        answer.append(self.answer1.text!)
        answer.append(self.answer2.text!)
        answer.append(self.answer3.text!)
        
        print("************************************")
        print(self.securityQuestion)
        
        PFUser.logInWithUsername(inBackground: (PFUser.current()?.username!)!, password: self.password.text!, block: { (user, error) in
            if user != nil{
             
                if self.securityQuestion==[]{
                    var newQueston = PFObject(className:"SecurityQuestion")
                    newQueston["username"] = (PFUser.current()?.username)! as String
                    newQueston["question"] = question
                    newQueston["answer"] = answer
                    
                    do{
                    newQueston.saveInBackground()
                        let title = "successfully"
                        let message = "The security question is setted successfully"
                        let action1 = "OK"
                        let submitAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
                        submitAlert.addAction(UIAlertAction(title:action1,style: UIAlertActionStyle.default, handler:nil))
                        self.present(submitAlert, animated: true, completion: nil)
                        
                    }catch{
                        let title = "Error"
                        let message = "Error happened, try later"
                        let action1 = "OK"
                        let submitAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
                        submitAlert.addAction(UIAlertAction(title:action1,style: UIAlertActionStyle.default, handler:nil))
                        self.present(submitAlert, animated: true, completion: nil)
                        
                    }
                }else{
                    var newQuestion = self.securityQuestion[0]
                    newQuestion["username"] = (PFUser.current()?.username)! as String
                    newQuestion["question"] = question
                    newQuestion["answer"] = answer
                    do{
                    newQuestion.saveInBackground()
                        let title = "Failed"
                        let message = "The security is updated successfully"
                        let action1 = "OK"
                        let submitAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
                        submitAlert.addAction(UIAlertAction(title:action1,style: UIAlertActionStyle.default, handler:nil))
                        self.present(submitAlert, animated: true, completion: nil)
                    }catch{
                        let title = "Error"
                        let message = "Error happened, try later"
                        let action1 = "OK"
                        let submitAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
                        submitAlert.addAction(UIAlertAction(title:action1,style: UIAlertActionStyle.default, handler:nil))
                        self.present(submitAlert, animated: true, completion: nil)
                    }
                }
            
                
            }else{
                let title = "Failed"
                let message = "The password is not correct"
                let action1 = "OK"
                let submitAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
                submitAlert.addAction(UIAlertAction(title:action1,style: UIAlertActionStyle.default, handler:nil))
                self.present(submitAlert, animated: true, completion: nil)

                
            }
        })
 

    }
    
    
    @IBAction func editingChanged(_ sender: UITextField) {
       
            if (self.question1.text != "" && self.question2.text != "" && self.question3.text != "" && self.answer1.text != "" && self.answer2.text != "" && self.answer3.text != "" && self.password.text != ""){
                self.submitButton.isEnabled=true
                
            }else{
                self.submitButton.isEnabled=false
            }
        }
    

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.submitButton.isEnabled=false
        loadQuestion()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            
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
    
    
        // Do any additional setup after loading the view, typically from a nib.
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
}

