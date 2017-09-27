/*
 File: LoginViewController
 Author: CoDex
 Purpose: This part is used to control the login view.
 */
import UIKit
import Parse

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginUsername: UITextField!
    
    
    @IBOutlet weak var loginPassword: UITextField!
    
    
    
    @IBOutlet weak var loginSubmitButton: UIButton!
    
    func defaultLoginButton(){
        if self.loginUsername.text == "" || self.loginPassword.text == ""{
            self.loginSubmitButton.isEnabled=false
            
        }else{
            self.loginSubmitButton.isEnabled=true
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginSubmitButton.isEnabled=false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y > -keyboardSize.height / 2{
                self.view.frame.origin.y -= keyboardSize.height / 2
                UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                    }, completion: nil)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y < 0{
                self.view.frame.origin.y = 0
            }
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: { (completed) in
            })
            
        }
    }
    
    
    
    @IBAction func loginSubmit(_ sender: UIButton) {
        self.loginUsername.resignFirstResponder()
        self.loginPassword.resignFirstResponder()
        //print(revealViewController().description)
        
        let patternUusername = "^[a-z]{1,10}$"
        let patternEmail =  "^[a-z0-9]+([._\\-]*[a-z0-9])*@([a-z0-9]+[-a-z0-9]*[a-z0-9]+.){1,63}[a-z0-9]+$"
        
        
        do {
            
            
            let regexUsername =  try NSRegularExpression(pattern: patternUusername, options: NSRegularExpression.Options.caseInsensitive)
            let regexEmail =  try NSRegularExpression(pattern: patternEmail, options: NSRegularExpression.Options.caseInsensitive)
            let resUsername = regexUsername.numberOfMatches(in: self.loginUsername.text!, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, (self.loginUsername.text?.characters.count)!))
            
            let resEmail = regexEmail.numberOfMatches(in: self.loginUsername.text!, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, (self.loginUsername.text?.characters.count)!))
            if resUsername != 0{
                PFUser.logInWithUsername(inBackground: loginUsername.text!, password: loginPassword.text!, block: { (user, error) in
                    if error != nil {
                        let title = "Login Failed"
                        let message = "Please check your username and password!"
                        let action1 = "OK"
                        let loginAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
                        loginAlert.addAction(UIAlertAction(title:action1,style: UIAlertActionStyle.default, handler:nil))
                        self.present(loginAlert, animated: true, completion: nil)
                        //self.presentViewController(alert, dismiss(true, completion: nil))
                    } else {
                        
                        print ("Logged In99999999999999999999999999999999999999999999")
                        self.performSegue(withIdentifier: "welcomeView", sender: self)
                        
                        
                    
                    }
                    
                    
                })
            }else if resEmail != 0{
                
            }else{
                let title = "Warning"
                let message = "The format of username or email is not correct!"
                let action1 = "OK"
                let loginAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
                loginAlert.addAction(UIAlertAction(title:action1,style: UIAlertActionStyle.default, handler:nil))
                self.present(loginAlert, animated: true, completion: nil)
            }
        
        }catch{
            
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
       
        
        
    }
    
    
    
    func editingChanged(_ sender: UITextField) {
        if (loginPassword.text != "" && loginUsername.text != ""){
            self.loginSubmitButton.isEnabled=true
            
        }else{
            self.loginSubmitButton.isEnabled=false
        }
        
    }
    
    
    
    //点击屏幕键盘隐藏
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
}



