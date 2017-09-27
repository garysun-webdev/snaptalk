/*
 File: SetPasswordViewController
 Author: CoDex
 Purpose: This part is used to set password.
 */

import UIKit
import Parse
class SetPasswordViewController: UIViewController {
    
    
    @IBOutlet var setPasswordInput: UITextField!
    
    
    
    @IBOutlet var subButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subButton.isEnabled = false
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    @IBAction func subAction(_ sender: UIButton) {
        
        
        print(wantToFindUser)
        var newUser = wantToFindUser[0]
        PFUser.current()?.password = self.setPasswordInput.text
        newUser.acl?.getPublicWriteAccess
        newUser.saveInBackground()
        let title = "success"
        
        let message = "password has been set successfully!"
        
        let action1 = "OK"
        
        let loginAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
        
        loginAlert.addAction(UIAlertAction(title:action1,style: UIAlertActionStyle.default, handler:nil))
        self.present(loginAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func editChange(_ sender: AnyObject) {
        if self.setPasswordInput.text != "" {
            self.subButton.isEnabled = true
        }else{
           self.subButton.isEnabled = false
        }
            
            
    }
    
    
    
}
