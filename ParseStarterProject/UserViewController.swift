/*
 File: UserViewController
 Author: CoDex
 Purpose: This part is used to control the User View.
 */


import UIKit
import Parse
class UserViewController: UIViewController {
    
    
   
    
    @IBOutlet var nameLabel: UILabel!
    
    
    @IBOutlet var ageLabel: UILabel!
    
    
    var userInfo = PFUser()
    
    func loadUserInfo(){
        let query = PFUser.query()
        
        query?.whereKey("objectId", equalTo: (PFUser.current()?.objectId)!)
        
        do {
            
            let users = try query?.findObjects()
            
            if let users = users as? [PFUser] {
                
                for user in users {
                    
                    self.userInfo = user
                   
                }
                
                
                
            }
            
            
        } catch {
            
            print ("Could not get users")
            
        }
        
   
    }
    
    
    
    @IBAction func logoutAction(_ sender: UIButton) {
        
        PFUser.logOut()
        
        self.performSegue(withIdentifier: "logout", sender: self)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserInfo()
    
        self.nameLabel.text = ((self.userInfo["firstName"])) as! String + " " + ((self.userInfo["lastName"]) as! String)
             self.ageLabel.text = self.userInfo["dateOfBirth"] as! String
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
