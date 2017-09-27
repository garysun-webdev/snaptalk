/*  File: ProcessViewController
 Author: CoDex
 Purpose: This class is mainly used for process the image, including  cancel, add text, draw freehand, set timer, save, store as memory and so on.
 */


import Parse
import UIKit

class ProcessViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    //used for achieve the information of receiver
    var receiver:String = ""
    //default countdown parameter, here we set it as 5.
    var countdownNum = 5
    @IBOutlet var photo: UIImageView!
    
    @IBOutlet weak var StoryView: UIButton!
    @IBOutlet weak var MemoryView: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var paintButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var sendStoryButton: UIButton!
    
    @IBAction func saveCamera(_ sender: UIButton) {
        //Save the image into both album and memory
        screenShotHideButton()
        //Step 1: to album
        UIImageWriteToSavedPhotosAlbum(screenShot(), nil, nil, nil)
        //Step 2: to memory
        sendToServer(s: "Memory")
        screenShotShowButton()

    }
    //user can click this button to send the message into his story part.
    @IBAction func sendStory(_ sender: UIButton) {
        screenShotHideButton()
        sendToServer(s: "Story")
        screenShotShowButton()
    }
    
    
    func sendToServer(s: String) {
        var newMemoryPhoto = PFObject(className:s)
        newMemoryPhoto["owner"] = (PFUser.current()?.username)! as String//
        newMemoryPhoto["photo"] = PFFile(name: "photo.jpg", data:
        //the number means the ratio of compression.
        UIImageJPEGRepresentation(screenShot(), 1)!)
        
        do{
            newMemoryPhoto.acl?.getPublicWriteAccess=true
            newMemoryPhoto.saveInBackground {
                (success,error) -> Void in
                if(success) {
                    let title = "Upload successed"
                    let message = "Upload successed"
                    let action1 = "OK"
                    let inviteSuccessAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
                    inviteSuccessAlert.addAction(UIAlertAction(title:action1,style: UIAlertActionStyle.default, handler:nil))
                    self.present(inviteSuccessAlert, animated: true, completion: nil)
                }else{
                    let title = "Upload failure"
                    let message = "Upload failure"
                    let action1 = "OK"
                    let inviteSuccessAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
                    inviteSuccessAlert.addAction(UIAlertAction(title:action1,style: UIAlertActionStyle.default, handler:nil))
                    self.present(inviteSuccessAlert, animated: true, completion: nil)
                }
            }
        }catch{
            
        }
    }
    
    @IBOutlet weak var saveCamera: UIButton!
    
    @IBOutlet weak var paintBackButton: UIButton!
    
    @IBOutlet weak var paintUndoButton: UIButton!
    
    @IBOutlet weak var countDownButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    //send the image to the user's friend.
    @IBAction func saveButton(_ sender: UIButton) {
        if (label.isHidden == false) {
            screenShotHideButton()
            self.photo.image = screenShot()
            screenShotShowButton()
        }
        //transfer the image to server.
        let imageToSend = PFObject(className: "Image")
        imageToSend["photo"] = PFFile(name: "photo.jpg", data: UIImageJPEGRepresentation(self.photo.image!, 1)!)
        imageToSend["senderUsername"] = PFUser.current()?.username
        imageToSend["recipientUsername"] = self.receiver
        //downloaded = 2 means the image can be replayed.
        imageToSend["downloaded"] = 2
        imageToSend["countdownNum"] = countdownNum
        //set the authority. In this case user can delete his memory.
        imageToSend.acl?.getPublicWriteAccess=true
        //achieve the image data from server.
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
            let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }))
            self.present(alertController, animated: true, completion: nil)
        })
        
    }
    
    var processType = "text"
    
    //used for input text
    var touchCountButton = 1
    var enableDrag = false
    //
    
    //used for paint
    var lastPoint:CGPoint!
    var isSwiping:Bool!
    var red:CGFloat!
    var green:CGFloat!
    var blue:CGFloat!
    var oldimage:[UIImage] = []
    var paintCount = 0
    //
    
    var processImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.photo.image = processImage
        //self.photo.image = UIImage(named : "xiaowanzi")
        
        //set paint color  ----may change
        red   = (0.0/255.0)
        green = (0.0/255.0)
        blue  = (0.0/255.0)
        //
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func ClickTextButton(_ sender: AnyObject) {
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        label.center = CGPoint(x: w / 2, y: h / 2)
        label.textAlignment = .center
        label.textColor = UIColor.black
        if (touchCountButton == 1) {
            self.addText()
            textField.isHidden = false
        }
        else if (touchCountButton % 2 == 1) {
            textField.textAlignment = .left
            enableDrag = false
            label.isHidden = true
            textField.isHidden = false
        }
        else{
            view.endEditing(true)
            label.text = textField.text
            label.sizeToFit()
            label.adjustsFontSizeToFitWidth = true
            label.textAlignment = .center
            enableDrag = true
            label.isHidden = false
            textField.isHidden = true
        }
        touchCountButton += 1
    }
   
    //MARK: - Paint
    @IBAction func ClickPaintButton(_ sender: AnyObject)
    {
        oldimage.append(self.photo.image!)
        processType = "paint"
        textButton.isHidden = true
        countDownButton.isHidden = true
        paintBackButton.isHidden = false
        paintUndoButton.isHidden = false
        saveButton.isHidden = true
    }
    
    @IBAction func PaintBackButton(_ sender: AnyObject) {
        textButton.isHidden = false
        countDownButton.isHidden = false
        paintBackButton.isHidden = true
        paintUndoButton.isHidden = true
        processType = "text"
        saveButton.isHidden = false
    }
    //using an UIimage array to save image when it changed
    @IBAction func PaintUndoButton(_ sender: AnyObject) {
        if (paintCount > 0) {
            self.photo.image = oldimage[paintCount - 1]
            paintCount -= 1
        }else
        {
            self.photo.image = oldimage[0]
        }
        
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (processType == "text" && touchCountButton == 1 ) {
            self.addText()
            textField.isHidden = false
            touchCountButton += 1
        }
        else if (processType == "paint") {
            oldimage.append(self.photo.image!)

            paintCount += 1
            if(!isSwiping) {
                // This is a single touch, draw a point
                UIGraphicsBeginImageContext(self.photo.frame.size)
                self.photo.image?.draw(in: CGRect(x: 0, y: 0, width: self.photo.frame.size.width, height: self.photo.frame.size.height))
                UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.round)
                UIGraphicsGetCurrentContext()?.setLineWidth(9.0)
                UIGraphicsGetCurrentContext()?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
                UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
                UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
                UIGraphicsGetCurrentContext()?.strokePath()
                self.photo.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        if (processType == "text" && textField.isHidden == false) {
            view.endEditing(true)
            super.touchesBegan(touches, with: event)
            textField.textAlignment = .center
        }
        else if (processType == "paint") {
            isSwiping = false
            if let touch = touches.first{
                lastPoint = touch.location(in: photo)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (processType == "text" && enableDrag == true) {
            for touch in (touches ){
                let location = touch.location(in: self.view)
                if label.frame.contains(location){
                    label.center = location
                }
            }
        }else if (processType == "paint") {
            isSwiping = true;
            if let touch = touches.first{
                let currentPoint = touch.location(in: photo)
                UIGraphicsBeginImageContext(self.photo.frame.size)
                self.photo.image?.draw(in: CGRect(x: 0, y: 0, width: self.photo.frame.size.width, height: self.photo.frame.size.height))
                UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
                UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: currentPoint.x, y: currentPoint.y))
                UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.round)
                UIGraphicsGetCurrentContext()?.setLineWidth(9.0)
                UIGraphicsGetCurrentContext()?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
                UIGraphicsGetCurrentContext()?.strokePath()
                self.photo.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                lastPoint = currentPoint
                
            }
        }
    }
    
    fileprivate func addText(){
        
        textField.font = UIFont.systemFont(ofSize: 30)
        textField.textColor = UIColor.black
        textField.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        textField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        
    }
    
    //MARK: - Countdown
    @IBAction func ClickCountdownButton(_ sender: AnyObject) {
        //UIPickerView
        let pickerView = UIPickerView()
        pickerView.center = self.view.center
        pickerView.delegate = self
        pickerView.dataSource = self
        self.view.addSubview(pickerView)
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row) second"
    }
    
    //call the function when user select row
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("User selected row at index \(row)")
        pickerView.isHidden = true
        countdownNum = row
        
    }
    
    func screenShot() -> UIImage {
        UIGraphicsBeginImageContext(self.view.bounds.size);
        self.view.layer.render(in: UIGraphicsGetCurrentContext()!)
        var screenShot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return screenShot!
    }
    
    //before sending the image, all buttons should be hidden.
    func screenShotHideButton() {
            countDownButton.isHidden = true
            paintButton.isHidden = true
            textButton.isHidden = true
            cancelButton.isHidden = true
            saveButton.isHidden = true
            saveCamera.isHidden = true
            MemoryView.isHidden = true
            StoryView.isHidden = true
            sendStoryButton.isHidden = true
    }
    //after sending the image, all buttons should be emerged.
    func screenShotShowButton() {
        countDownButton.isHidden = false
        paintButton.isHidden = false
        textButton.isHidden = false
        cancelButton.isHidden = false
        saveButton.isHidden = false
        saveCamera.isHidden = false
        MemoryView.isHidden = false
        sendStoryButton.isHidden = false
        StoryView.isHidden = false
    }
}


