/*
 File: InvitationTableCell
 Author: CoDex
 Purpose: This part is used to control the invitation table.
 */

import UIKit
import  Parse
class InvitationTableCell: UITableViewCell {
    
    
    @IBOutlet var photoImage: UIImageView!
    

    @IBOutlet var refuseButton: UIButton!
    @IBOutlet var acceptButton: UIButton!
    @IBOutlet var usernameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
    
    
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
    
    @IBAction func acceptButton(_ sender: UIButton) {
        self.acceptButton.isEnabled=false
        self.refuseButton.isEnabled=false
        
        var object1 = PFObject(className:"FriendInvite")
        
        object1["sender"] = PFUser.current()?.username!
        object1["receiver"] = self.usernameLabel.text!
        object1["isProcessed"] = false
     object1.saveInBackground()
      
        
    }
    
    
    
    @IBAction func refuseButton(_ sender: UIButton) {
        
        self.acceptButton.isEnabled=false
        self.refuseButton.isEnabled=false
        var myInvitationList:[PFObject]=[]
        var query = PFQuery(className:"FriendInvite")
        query.whereKey("receiver", equalTo:(PFUser.current()?.username!)! as String)
        query.whereKey("sender", equalTo:self.usernameLabel.text!)
        do {
            print("dsklfjlksdjklfsdjlkfjdskljldsjkflsdjklfj")
            let invitations = try query.findObjects()
            
            if let invitations =  invitations  as? [PFObject] {
                
                for invitation in invitations {
                    
                  myInvitationList.append(invitation)
                    
                }
                
            
                
            }
            
            
        } catch {
            
            print ("Could not get users")
            
        }
       
        
       var updateInvitation = myInvitationList[0]
        
        updateInvitation["isProcessed"] = true
        updateInvitation.saveInBackground()
        

    }
    
    
    
    
}
