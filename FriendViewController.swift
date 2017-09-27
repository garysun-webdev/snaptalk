/*
 File: FriendViewController
 Author: CoDex
 Purpose: This class control to load all friends of current user
 */
import UIKit
import Parse


class FriendViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var countdownNumTimer=5
    var usernames = [String]()
    var recipientUsername = ""
    
    func checkForMessages(){
        
        
        //track the normal path
        print("Timer activated")
        
        //Standard query steps:
        //1: difine a PFQuery to identify the class
        let query = PFQuery(className: "Image")
        
        //2: .whereKey() to find the objects with the key
        query.whereKey("recipientUsername", equalTo: (PFUser.current()?.username)!)
        query.whereKey("downloaded", equalTo: 2)
        //different image type: this type is used for countdown veiwing
        query.whereKeyExists("countdownNum")
        
        
        
        //3. use do catch to handle finding them or not.
        do {
            
            //4. .findObjects() to collect the "images"
            let images = try query.findObjects()
            //5. try to cast images as [PFObject]
            
            if images.count > 0 {
                //??where to declear image?
                
                //initialise
                var senderUsername="Unknown"
                
                
                if let username = images[0]["senderUsername"] as? String {
                    senderUsername = username
                    countdownNumTimer = images[0]["countdownNum"] as! Int
                }
                
                //get the image content
                
                if let pfFile = images[0]["photo"] as? PFFile {
                   
                    pfFile.getDataInBackground(block: { (data, error) in
                        
                        if let imageData = data {
                            
                            //delete the current image in database
                            images[0]["downloaded"]=1
                            images[0].saveInBackground()
                            
                            //images[0].deleteInBackground()
                            
                            //close timer
                            self.timer.invalidate()
                            
                            //image content
                            if let imageToDisplay = UIImage(data: imageData) {
                                //UIImageWriteToSavedPhotosAlbum(imageToDisplay, nil, nil, nil)
                                //make alert to notify user
                                let alertController = UIAlertController(title: "You have a message", message: "Message from "+senderUsername, preferredStyle: .alert)
                                
                                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    
                                    //create a imageview background
                                    let backgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                                    
                                    backgroundImageView.backgroundColor = UIColor.black
                                    
                                    backgroundImageView.alpha = 0.8
                                    
                                    backgroundImageView.tag = 10
                                    
                                    self.view.addSubview(backgroundImageView)
                                    
                                    //image View outer border
                                    let displayedImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                                    
                                    
                                    //use tag to mark this view(subview)
                                    displayedImageView.tag = 10
                                    
                                    displayedImageView.contentMode = UIViewContentMode.scaleAspectFit
                                    
                                    displayedImageView.image = imageToDisplay
                                    
                                    self.view.addSubview(displayedImageView)
                                    
                                    //image in the front for 5s
                                    _ = Timer.scheduledTimer(withTimeInterval: Double(self.countdownNumTimer), repeats: false, block: { (timer) in
                                        
                                        //repeat 5s to retrive from the server
                                        self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(UserTableViewController.checkForMessages), userInfo: nil, repeats: true)
                                        //remove the image from the view
                                        for subview in self.view.subviews {
                                            if subview.tag == 10 {
                                                subview.removeFromSuperview()
                                            }
                                        }
                                    })
                                    
                                }))
                                
                                self.present(alertController, animated: true, completion: nil)
                                
                            }
                            
                        }
                    })
                    
                    
                    
                    
                    
                }
                
            }
        } catch {
            print("Could not get image")
            
        }
    }
    
    var timer = Timer()
    
    @IBOutlet var friendTable: UITableView!
    
    var myFriendList:[PFUser] = []
    
    
   func loadFriend(){
    
         var query = PFQuery(className:"Friend")
         query.whereKey("userUsername", equalTo:(PFUser.current()?.username!)! as String)
    
    do {
        
        let friends = try query.findObjects()
        print(friends)
        if let friends =  friends  as? [PFObject] {
            
            for friend in friends {
                
                let query = PFUser.query()
                
                query?.whereKey("username", equalTo: friend["friendUsername"])
                
                do {
                    
                    let users = try query?.findObjects()
                    
                    if let users = users as? [PFUser] {
                        
                        for user in users {
                            
                            
                         self.myFriendList.append(user)
                           
                
                        
                    }
                    }
                    
                    
                } catch {
                    
                    print ("Could not get users")
                    
                }
                
 
    
            }
            
          
            
        }
        
        
    } catch {
        
        print ("Could not get users")
        
    }
    
   
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(FriendViewController.checkForMessages), userInfo: nil, repeats: true)
        
       loadFriend()
        print(myFriendList)
      
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
     
      
  
        return myFriendList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableCell
        
        //var myFriend = self.loadFriend()
        
        
        cell.nameLabel.text =  myFriendList[indexPath.row].username
   
        return cell
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            if (id == "ChatToDialog") {
                let vc = segue.destination as! ChatlogCollectionViewController
                let indexPath = self.friendTable.indexPathForSelectedRow
                
                timer.invalidate()
                vc.title = self.myFriendList[(indexPath?.row)!]["firstName"] as! String
                
                vc.host = PFUser.current()
                
                vc.chatmate = self.myFriendList[(indexPath?.row)!]
            }
            
        }
    }
    
}
