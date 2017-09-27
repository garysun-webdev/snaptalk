/*
 File: ContactViewCotroller
 Author: CoDex
 Purpose: This class is used to control to read the contact from iphone and get user that have been signuped .Aslo can send friend invitation to them
 */

import UIKit
import Parse
import Contacts
class ContactViewCotroller: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet var contactTable: UITableView!
    
    var allUsers:[PFUser] = []
    var SigupedPhoneNumbers: [PFUser] = []
     var phoneNumbers:[String]=[]
    
    var images:[UIImage]=[]
    
   
    
    
   
    
    
    
    //load all users who have phone information
    func loadFriend(){
       
        var query = PFUser.query()
        query?.whereKeyExists("phone")
        
        do {
            
            let users = try query?.findObjects()
            
            if let users =  users  as? [PFUser] {
                
                self.allUsers = users
                
            }
            
            
        } catch {
            
            print ("Could not get users")
            
        }
        
    }
    
    
    
    
    // read contact of phones
    func loadContact(){
        
            // Fetch contacts when granted
            ContactsManager.sharedManager.fetchValidAddressBookContacts(completion: { (contacts, e) -> Void in
                
                if let contacts = contacts {
                    for contact in contacts {
                        
                        for phoneNumber in contact.phoneNumbers {
                            let value = phoneNumber.value
                            
                          self.phoneNumbers.append(value.stringValue)
                        }
                    
                    }
                }
                
            })
      
        }
    
    //get all users in my contact
    func getSignuped(){
        for user in allUsers{
            if self.phoneNumbers.contains(user["phone"] as! String){
               self.SigupedPhoneNumbers.append(user)
            }
        }
        
    }
    
   
    
    
    
    
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadContact()
        loadFriend()
        getSignuped()
       
       print(allUsers)
        print(SigupedPhoneNumbers)
        print()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.SigupedPhoneNumbers.count
        
    }
    
    //table view of users in my contact which are not my friends
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactTableCell
        
        
        var query = PFQuery(className:"Friend")
       
        query.whereKey("userUsername", equalTo:(PFUser.current()?.username)! as String)
        
       
        print(SigupedPhoneNumbers[indexPath.row].username! as String)
        query.whereKey("friendUsername", equalTo:SigupedPhoneNumbers[indexPath.row].username! as String)
        
        do {
            
            let friends = try query.findObjects()
            
            if let friends =  friends  as? [PFObject] {
                
                if friends.count == 0{
                    cell.nameLabel.text =  SigupedPhoneNumbers[indexPath.row].username! as String
                    cell.phoneLabel.text =  SigupedPhoneNumbers[indexPath.row]["phone"]! as! String
                }else{
                    cell.nameLabel.text =  SigupedPhoneNumbers[indexPath.row].username! as String
                    cell.phoneLabel.text =  SigupedPhoneNumbers[indexPath.row]["phone"]! as! String
                    cell.addButton.isEnabled=false
                }
                
            }
        } catch {
            
            print ("Could not get users")
            
        }

        
        return cell
        
        
    }
    
    
}
