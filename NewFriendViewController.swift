/*  
 File: NewFriendViewController
 Author: CoDex
 Purpose: This is the part of using username to add friends. Send friend invite to others.
 */

import UIKit
import Parse
class NewFriendViewController: UIViewController {
    
    
    @IBOutlet var searchUserField: UITextField!

    
    @IBOutlet var searchUserView: UIView!
    
    
    @IBOutlet var userResultLabel: UILabel!
    
    
    @IBOutlet var addUserButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    @IBAction func addUserAction(_ sender: UIButton) {
        
        //store friendship process to FriendInvite table
        var newInvite = PFObject(className:"FriendInvite")
        newInvite["sender"] = (PFUser.current()?.username!)! as String
        newInvite["receiver"] = userResultLabel.text
        newInvite["isProcessed"] = false
        
        do{
            newInvite.saveInBackground {
            (success, error) -> Void in
            
                if (success) {
                let title = "Invite successed"
                let message = "waiting for the response"
                let action1 = "OK"
                
                let inviteSuccessAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
             inviteSuccessAlert.addAction(UIAlertAction(title:action1,style: UIAlertActionStyle.default, handler:nil))
                self.present(inviteSuccessAlert, animated: true, completion: nil)
                //self.presentViewController(alert, dismiss(true, completion: nil))
            
                } else {
                let title = "Invite Failed"
                let message = "Please try again"
                let action1 = "OK"
                
                let inviteFailedAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
               inviteFailedAlert.addAction(UIAlertAction(title:action1,style: UIAlertActionStyle.default, handler:nil))
                self.present(inviteFailedAlert, animated: true, completion: nil)
                //self.presentViewController(alert, dismiss(true, completion: nil))
                
            }
        }
        }catch {
            
            let title = "Error"
            let message = "Error happened,Please try again"
            let action1 = "OK"
            let inviteErrorAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
          inviteErrorAlert.addAction(UIAlertAction(title:action1,style: UIAlertActionStyle.default, handler:nil))
            self.present(inviteErrorAlert, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func searchUserAction(_ sender: UIButton) {
        
        var matchUsers:[String] = []
        
        let query = PFUser.query()
        
        //search username which equals to typed in
        query?.whereKey("username", equalTo: searchUserField.text! as String)
        
        do {
            
            let users = try query?.findObjects()
            
             if let users = users as? [PFUser] {
                
                for user in users{
                    
                    matchUsers.append(user.username!)
                    
                }
                
            }
            
            
        } catch {
            
            print ("Could not get users")
            
        }
        
        //no matching user found
        if matchUsers.count == 0{
            
            userResultLabel.text = "no user found"
            addUserButton.isHidden = true
            
        }else{
            
            userResultLabel.text =  matchUsers[0]
            addUserButton.isHidden = false
        }
        
  
        
    }
    
}
