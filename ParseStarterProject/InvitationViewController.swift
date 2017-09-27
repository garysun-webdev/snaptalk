/*
 File: InvitationViewController
 Author: CoDex
 Purpose: This part is used to control the invitation View.
 */

import UIKit
import Parse

class InvitationViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
   
    @IBOutlet var invitationTable: UITableView!
    
    var myInvitationList:[String] = []
    
    func loadInvitation(){
        
        var query = PFQuery(className:"FriendInvite")
        query.whereKey("receiver", equalTo:(PFUser.current()?.username!)! as String)
        query.whereKey("isProcessed", equalTo:false)
        do {
            
            let invitations = try query.findObjects()
          
            if let invitations =  invitations  as? [PFObject] {
                
                for invitation in invitations {
                    
                    self.myInvitationList.append(invitation["sender"] as! String)
                    
                }
                
                
                
            }
            
            
        } catch {
            
            print ("Could not get users")
            
        }
        
        
        
        
    }
    
    
    
    
    
    
    
    var  name=["dsfds","dsfsdgfg "]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadInvitation()
        print(myInvitationList)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        
        
        return myInvitationList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "invitationCell", for: indexPath) as! InvitationTableCell
        
        //var myFriend = self.loadFriend()
        
        
        cell.usernameLabel.text =  myInvitationList[indexPath.row]
        
        return cell
        
        
    }
    
}
