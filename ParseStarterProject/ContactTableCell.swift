/*
 File: ContactTableCell
 Author: CoDex
 Purpose: This part is used to control the contact table.
 */

import UIKit
import Parse
class ContactTableCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    
    
    @IBOutlet var phoneLabel: UILabel!
    
    @IBOutlet var addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
    @IBAction func addAction(_ sender: UIButton) {
        
        
        
        
        var newInvite = PFObject(className:"FriendInvite")
        newInvite["sender"] = (PFUser.current()?.username!)! as String
        newInvite["receiver"] = nameLabel.text
        newInvite["isProcessed"] = false
        do{
            newInvite.saveInBackground {
                (success, error) -> Void in
                if (success) {
                    self.addButton.isEnabled=false
                } else {
                    self.addButton.isEnabled=true
                    
                }
            }
        }catch {
            
            print("erroe")
            
        }
        
        
        
        
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
