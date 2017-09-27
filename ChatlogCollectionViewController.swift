/*
 File: ChatlogCollectionViewController
 Author: CoDex
 Purpose: This class control the chat form.
 */
import UIKit
import  Parse
private let reuseIdentifier = "MessageCell"
private let aspect:CGFloat = 0.3

class ChatlogCollectionViewController: UIViewController,
    UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet var messageCollection: UICollectionView!
    var host:PFObject?
    var chatmate:PFObject?
    var wholeTime = Timer()
    @IBAction func pickUpImage(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    //function after user picked the image
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //errors existing with logs but does not hinder running
        //what's UIImage??
        //"An object that manages image data in your app."
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //transfer the image to parse
            //set up a new class: Image
            let imageToSend = PFObject(className: "Image")
            //set up a new attribute for Image
            imageToSend["photo"] = PFFile(name: "photo.jpg",
                                          data: UIImageJPEGRepresentation(image, 1)!)
            imageToSend["senderUsername"] = PFUser.current()?.username
            imageToSend["recipientUsername"] = (chatmate as! PFUser).username!
            imageToSend["downloaded"]=1
            imageToSend.acl?.getPublicWriteAccess=true
            imageToSend.saveInBackground(block: { (success, error) in
                //use alert to notify the result to user
                //error situation first
                var title = "Sending Failed"
                var description = "Please try again later"
                // success second
                if success{
                    title = "Message Sent"
                    description = "Your message has been sent"
                }
                //customize alert
                let alertController = UIAlertController(title: title,
                                                        message: description,
                                                        preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK",
                                                        style: .default,
                                                        handler: { (action) in
                    alertController.dismiss(animated: true, completion: nil)
                }))
                self.present(alertController, animated: true, completion: nil)
            })
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var enterFieldToMessageCollection: NSLayoutConstraint!
    @IBOutlet weak var buttomContraintOfMessageCollection: NSLayoutConstraint!
    
    var combinedArray = [PFObject]()
    var messages = [PFObject]()
    var fromMessages = [PFObject]()
    var sendMessages = [PFObject]()
    
    @IBOutlet var enterField: UIView!
    
    @IBOutlet var sendButton: UIButton!
    
    @IBAction func sendAction(_ sender: UIButton) {
        if let text = self.textField.text{
            if text != ""{
                self.createMessageWithText(text, minutesAgo: 0)
                self.messageCollection.reloadData()
                self.textField.text = ""
                let indexPath = IndexPath(item: self.messages.count - 1,
                                          section: 0)
                self.messageCollection?.scrollToItem(at: indexPath,
                                                     at: .bottom, animated: true)
            }
        }
    }
    @IBOutlet var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageCollection.dataSource = self
        self.messageCollection.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        initialButton()
        initial()
        //repeat 5s to retrive from the server
        self.wholeTime = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(ChatlogCollectionViewController.initial), userInfo: nil, repeats: true)
    }
    
    func initialButton(){
        self.sendButton.setTitle("Send", for: UIControlState())
        self.sendButton.setTitleColor(UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1), for: UIControlState())
        self.sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y -= keyboardSize.height
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: { (completed) in
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    if indexPath.row > -1{
                        self.messageCollection?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                    }
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y < 0{
                self.view.frame.origin.y += keyboardSize.height
            }
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: { (completed) in
            })
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ChatlogCollectionViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = messages[indexPath.item]
        let size = CGSize(width: 250, height: 1000)
        if (message["text"]==nil) {
            //for images
            if(message["countdownNum"]==nil){
                //it is perminent
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
                var img = UIImage()
                if let pfFile = message["photo"] as? PFFile {
                    var imgWidth:CGFloat = view.frame.size.width
                    var imgHeight:CGFloat = view.frame.size.height
                    pfFile.getDataInBackground(block: { (data, error) in
                        if let imageData = data {
                            img = UIImage(data: imageData)!
                            imgWidth = img.size.width
                            imgHeight = img.size.height
                            cell.imageView.image = UIImage(data: imageData)
                        }
                    })
                    cell.imageView.frame = CGRect(x: 10, y: 10,width: imgWidth * aspect, height: imgHeight * aspect)
                    cell.bubbleView.frame = CGRect(x: 10, y: 0, width: imgWidth * aspect + 20, height: imgHeight * aspect + 20)
                }
                if (message["senderUsername"] as! String) == PFUser.current()?.username{
                    //is user
                    cell.bubbleView.backgroundColor = UIColor(white: 0.95, alpha: 1)
                }else{
                    //not user
                    cell.bubbleView.backgroundColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                }
                cell.bubbleView.layer.cornerRadius = 8
                cell.layer.masksToBounds = true
                return cell
            }else{
                //for snap
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "replyCell", for: indexPath) as! ReplyCell
                cell.imageID = message.objectId! as String
                var text:String = ""
                if(message["senderUsername"] as! String) == PFUser.current()?.username {
                    //is user
                    text = "Opened!"
                    cell.bubble.backgroundColor = UIColor(white: 0.95, alpha: 1)
                }else{
                    //not user
                    if((message["downloaded"] as! Int) != 0){
                        text = "Tap to reply!"
                        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
                        cell.addGestureRecognizer(tap)
                        //////
                    }else{
                        text = "Replied!"
                    }
                    cell.bubble.backgroundColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                }
                let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                let estimatedFrame = NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
                cell.label.frame = CGRect(x: 8, y: -2, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                //cell.label.frame.size = CGSize(width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 20)
                cell.label.text = text
                cell.bubble.frame = CGRect(x: 10, y: 0, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 20)
                cell.bubble.layer.cornerRadius = 8
                cell.layer.masksToBounds = true
                return cell
            }
        }else{
            //it is a text
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
            let text = messages[indexPath.item]["text"] as! String
            cell.content.text = text
            let message = messages[(indexPath as NSIndexPath).item]
            if !(text.isEmpty) {
                // Configure the cell
                let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                let estimatedFrame = NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
                //if the sender is the user
                if !((message["senderUsername"] as! String) == PFUser.current()?.username){
                    //not user
                    cell.bubbleView.backgroundColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                }else{// not the user
                    cell.bubbleView.backgroundColor = UIColor(white: 0.95, alpha: 1)
                    cell.layer.masksToBounds = true
                }
                cell.content.frame = CGRect(x: 8, y: 1, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                cell.bubbleView.frame = CGRect(x: 10, y: 0, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 20)
                cell.bubbleView.layer.cornerRadius = 8
                cell.layer.masksToBounds = true
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let msg = messages[indexPath.item]
        if (msg["text"]==nil) {
            //this part is for images
            if(msg["countdownNum"]==nil){
                //this part is for perminent images
                if let pfFile = msg["photo"] as? PFFile {
                    var imgWidth:CGFloat = self.view.frame.width
                    var imgHeight:CGFloat = self.view.frame.height
                    pfFile.getDataInBackground(block: { (data, error) in
                        if let imageData = data {
                            let img = UIImage(data: imageData)
                            imgWidth = (img?.size.width)!
                            imgHeight = (img?.size.height)!
                        }
                    })
                    let newHeight = imgHeight * aspect
                    return CGSize(width: view.frame.width, height: newHeight + 20 + 8)
                }
                return CGSize(width:view.frame.width,height:100)
            }else{
                //this is for snaps
                var text:String = ""
                if(msg["senderUsername"] as! String) == PFUser.current()?.username {
                    //is user
                    text = "Opened!"
                }else{
                    //not user
                    if((msg["downloaded"] as! Int) != 0){
                        text = "Tap to reply!"
                    }else{
                        text = "Replied!"
                    }
                }
                let size = CGSize(width: 250, height: 1000)
                let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                let estimatedFrame = NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
                return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
            }
        }else{
            //this is text
            let text = msg["text"] as! String
            if !(text.isEmpty){
                //text frame
                let size = CGSize(width: 250, height: 1000)
                let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                let estimatedFrame = NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
                return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
            }
        }
        return CGSize(width:view.frame.width,height:100)
    }
    
    func createMessageWithText(_ text: String, minutesAgo: Double) {
        //transfer the image to parse
        //set up a new class: Image
        let textToSend = PFObject(className: "Image")
        //set up a new attribute for Image
        textToSend["senderUsername"] = PFUser.current()?.username
        textToSend["recipientUsername"] = (self.chatmate as! PFUser).username
        textToSend["downloaded"] = 1
        textToSend["text"]=text
        textToSend.acl?.getPublicWriteAccess=true
        textToSend.saveInBackground(block: { (success, error) in
            //use alert to notify the result to user
            //error situation first
            var title = "Sending Failed"
            var description = "Please try again later"
            // success second
            if success{
                title = "Message Sent"
                description = "Your message has been sent"
            }
            //customize alert
            let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }))
            self.present(alertController, animated: true, completion: nil)
        })
        messages.append(textToSend)
    }
    
    func initial(){
        //track the normal path
        //Standard query steps:
        //1: difine a PFQuery to identify the class
        let queryFrom = PFQuery(className: "Image")
        //2: .whereKey() to find the objects with the key
        queryFrom.whereKey("senderUsername", equalTo: (chatmate as! PFUser).username!)
        queryFrom.whereKey("recipientUsername", equalTo: (PFUser.current()?.username)!)
        queryFrom.whereKey("downloaded", equalTo: 1)
        //3. use do catch to handle finding them or not.
        do {
            //4. .findObjects() to collect the "images"
            self.fromMessages = try queryFrom.findObjects()
        } catch {
            print("There's no messages from "+(chatmate as! PFUser).username!)
        }
        let querySend =  PFQuery(className: "Image")
        //2: .whereKey() to find the objects with the key
        querySend.whereKey("senderUsername", equalTo: (PFUser.current()?.username)!)
        querySend.whereKey("recipientUsername", equalTo: (chatmate as! PFUser).username!)
        querySend.whereKey("downloaded", equalTo: 1)
        //3. use do catch to handle finding them or not.
        do {
            //4. .findObjects() to collect the "images"
            self.sendMessages = try querySend.findObjects()
            //createdAt,PFObject
        } catch {
            print("There's no messages sent to "+(chatmate as! PFUser).username!)
        }
        combinedArray=fromMessages+sendMessages
        self.messages = sortPFObject(array: combinedArray)
        self.messageCollection.reloadData()
    }
    
    func handleTap(sender:UITapGestureRecognizer!) {
        // handling code
        //using sender, we can get the point in respect to the table view
        let tapLocation = sender.location(in: self.messageCollection)
        //using the tapLocation, we retrieve the corresponding indexPath
        let indexPath = self.messageCollection.indexPathForItem(at:tapLocation)
        //finally, we print out the value
        print(indexPath)
        //we could even get the cell from the index, too
        let cell = self.messageCollection.cellForItem(at:indexPath!) as! ReplyCell
        let queryID = PFQuery(className: "Image")
        do{
            let msg = try queryID.getObjectWithId(cell.imageID)
            if let pfFile = msg["photo"] as? PFFile {
                //记住这个语法的syntex,两种结果data 或者 error
                pfFile.getDataInBackground(block: { (data, error) in
                    if let imageData = data {
                        //image content
                        if let imageToDisplay = UIImage(data: imageData) {
                            //make alert to notify user
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
                            _ = Timer.scheduledTimer(withTimeInterval: msg["countdownNum"] as! TimeInterval, repeats: false, block: { (timer) in
                                for subview in self.view.subviews {
                                    if subview.tag == 10 {
                                        subview.removeFromSuperview()
                                    }
                                }
                            })
                        }
                    }
                })
            }
            msg["downloaded"]=0
            msg.saveInBackground()
        }catch{
        }
        self.initial()
        //self.messageCollection.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            if (id == "chatToCamera") {
                let vc = segue.destination as! CameraViewController
                print(chatmate)
                print("........................")
                //print(chatmate?["friendUsername"] as! String)
                vc.receiver = (chatmate as! PFUser).username!
            }
            
        }
    }
    
    func sortPFObject(array:[PFObject])->[PFObject]{
        let dateDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        let sortDescriptors = NSArray(array: array)
        let sorted = sortDescriptors.sortedArray(using: [dateDescriptor])
        return sorted as! [PFObject]
    }
    
}



