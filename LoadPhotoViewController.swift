/*
 File: LoadPhotoViewController
 Author: CoDex
 Purpose: This class achieve to load all photo of current user
 */


import UIKit
import Parse
class LoadPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    let picker = UIImagePickerController()
    var selectedImage:UIImage?{
        didSet{
            imageView.image = selectedImage
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func fromCameraClicked(_ sender: AnyObject) {
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) else{
            showAlertWithTitle("Error", message: "No camera availabe.")
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.camera
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func fromLibraryClicked(_ sender: AnyObject) {
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func saveToLibraryClicked(_ sender: AnyObject) {
        if let selectedImage = selectedImage {
            UIImageWriteToSavedPhotosAlbum(selectedImage, self,#selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer){
        guard error == nil else{
            showAlertWithTitle("Error", message: error!.localizedDescription)
            return
        }
        showAlertWithTitle(nil, message: "Image Saved")
    }
    
    func showAlertWithTitle(_ title:String?, message:String?){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    //Mark: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        self.selectedImage = selectedImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier
        {
            if id == "addToMemory"
            {
                let vc = segue.destination as! MemoryViewController
                sendToServer(s: "Memory")
                vc.images.append(self.selectedImage!)
            }
            else if id == "addToStory"
            {
                let vc = segue.destination as! MyStory
                sendToServer(s: "Story")
                vc.images.append(self.selectedImage!)
            }
            
            
        }
    }
    
    func sendToServer(s: String) {
        var newMemoryPhoto = PFObject(className:s)
        newMemoryPhoto["owner"] = (PFUser.current()?.username)! as String//***************************
        newMemoryPhoto["photo"] = PFFile(name: "photo.jpg", data: UIImageJPEGRepresentation(self.selectedImage!, 1)!)
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
    
}

