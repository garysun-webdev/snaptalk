/*
 File: SignupViewController
 Author: CoDex
 Purpose: This part is used to sign up.
 */

import UIKit
import Parse
var newUser : [String : String] = [String : String]()

class SignupViewController: UIViewController,UIPickerViewDelegate{
    
    
    var areaCodeArray = ["dksjhfkj","dsfsdf","gfhfgh"]
    
    
   
    @IBOutlet weak var firstName: UITextField!
    
    
    
    @IBOutlet weak var lastName: UITextField!
    
    
    @IBOutlet weak var dataOfBirth: UIDatePicker!
    
    
    @IBOutlet weak var signupUsername: UITextField!
    
    
    @IBOutlet weak var signupPassword: UITextField!
    
   
    @IBOutlet weak var phoneOrEmail: UISegmentedControl!
    
    
    @IBOutlet weak var subViewPhone: UIView!
    
    
    
    
    @IBOutlet var areaCode: UILabel!
  
   
    @IBOutlet weak var phoneInput: UITextField!
    
    
    @IBOutlet weak var subViewEmail: UIView!
    
    
    
    @IBOutlet weak var emailInput: UITextField!
    
    
    
    
    func toJson(dict:[String:String]) -> String {
        
        var strJson = "{"
        for (key, value) in dict {
            //strJson = strJson +key = ":" +value; +","
            strJson = strJson + "'" + key + "'" + ":" + "'" + value + "'" + ","
            
        }
        strJson.remove(at: strJson.index(before: strJson.endIndex))
        strJson.insert("}", at: strJson.endIndex)
        return strJson
    }
    
    
    
    
    
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        return areaCodeArray.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        
        return areaCodeArray[row]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.subViewEmail.isHidden=true
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func infoNextButton(_ sender: UIButton) {
        self.firstName.resignFirstResponder()
        self.lastName.resignFirstResponder()
       
        
        
        
     
        
        let pattern = "^[a-z]{1,10}$"
        
        
          do {
          
           
            let regex =  try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let resFirstName = regex.numberOfMatches(in: self.firstName.text!, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, (self.firstName.text?.characters.count)!))
            let resLastName = regex.numberOfMatches(in: self.lastName.text!, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, (self.lastName.text?.characters.count)!))
            
            if resFirstName == 0{
               
                let title = "Warning"
                let message = "Invald first name input!"
                let action = "OK"
                let infoAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
                infoAlert.addAction(UIAlertAction(title:action,style: UIAlertActionStyle.default, handler:nil))
                self.present(infoAlert, animated: true, completion: nil)
               
            }
            else if resLastName==0{
                let title = "Warning"
                let message = "Invald last name  input!"
                let action = "OK"
                let infoAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
                infoAlert.addAction(UIAlertAction(title:action,style: UIAlertActionStyle.default, handler:nil))
                self.present(infoAlert, animated: true, completion: nil)
 
            }else{
                newUser["firstName"] = self.firstName.text
                newUser["lastName"] = self.lastName.text
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM dd, yyyy"
                let convertedDate = dateFormatter.string(from: self.dataOfBirth.date)
                newUser["dateOfBirth"] = convertedDate
                
                self.performSegue(withIdentifier: "infoToUsername", sender: self)
            }
                
            
            

          }catch {
            print(error)
            }
        

        


        
        
        
        
        
        
        
        
        
    }
    
    
   //username and password signup view
    @IBAction func signUsernamePasswordButton(_ sender: UIButton) {
        self.signupUsername.resignFirstResponder()
        self.signupPassword.resignFirstResponder()
        
        let patternUusername = "^[a-z]{1,10}$"
        let patternPassword =  "^(?![a-zA-z]+$)(?!\\d+$)(?![!@#$%^&*]+$)(?![a-zA-z\\d]+$)(?![a-zA-z!@#$%^&*]+$)(?![\\d!@#$%^&*]+$)[a-zA-Z\\d!@#$%^&*]+$"
        
        
        do {
            
            
            let regexUsername =  try NSRegularExpression(pattern: patternUusername, options: NSRegularExpression.Options.caseInsensitive)
            let regexPassword =  try NSRegularExpression(pattern: patternPassword, options: NSRegularExpression.Options.caseInsensitive)
            let resUsername = regexUsername.numberOfMatches(in: self.signupUsername.text!, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, (self.signupUsername.text?.characters.count)!))
            
            let resPassword = regexPassword.numberOfMatches(in: self.signupPassword.text!, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, (self.signupPassword.text?.characters.count)!))
            
            if resUsername == 0{
                
                let title = "Warning"
                let message = "Username can only consist of letter and numbers!"
                let action = "OK"
                let infoAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
                infoAlert.addAction(UIAlertAction(title:action,style: UIAlertActionStyle.default, handler:nil))
                self.present(infoAlert, animated: true, completion: nil)
                
            }
            else if resPassword==0{
                let title = "Warning"
                let message = "Password should include at least one letter,number and special character!"
                let action = "OK"
                let infoAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
                infoAlert.addAction(UIAlertAction(title:action,style: UIAlertActionStyle.default, handler:nil))
                self.present(infoAlert, animated: true, completion: nil)
                
            }else{
                
                
                
                let query = PFUser.query()
                
                query?.whereKey("username", equalTo:self.signupUsername.text! )
                
                do {
                    
                    let users = try query?.findObjects()
                    
                    if let users = users as? [PFUser] {
                        if users.count == 0 {
                            
                            
                            newUser["signupUsername"] = self.signupUsername.text
                            newUser["signupPassword"] = self.signupPassword.text
                            
                          
                            self.performSegue(withIdentifier: "usernameToPhone", sender: self)
                            
                            
                            
                            
                        }else{
                            
                            
                            let title = "Warning"
                            let message = "This username has been registered!"
                            let action = "OK"
                            let usernameAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
                             usernameAlert.addAction(UIAlertAction(title:action,style: UIAlertActionStyle.default, handler:nil))
                            self.present(usernameAlert, animated: true, completion: nil)
                            
                            
                        }
                    }
                    
                } catch {
                    
                    print ("Could not get users")
                    
                }

                
                
               
                
                
                
                
                
                
                
                
            }
            
            
            
            
        }catch {
            print(error)
        }
        

       
        
        
        
        
        
        
    }
    
    
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    
    //phone signup
    @IBAction func phoneSubmitButton(_ sender: UIButton) {
        let pattern = "^\\d{9}$"
        
        do {
            
            let regex =  try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let resPhone = regex.numberOfMatches(in: self.phoneInput.text!, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, (self.phoneInput.text?.characters.count)!))
            
            if resPhone == 0{
                
                let title = "Warning"
                let message = "Invalid phone format!"
                let action = "OK"
                let phoneAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
                phoneAlert.addAction(UIAlertAction(title:action,style: UIAlertActionStyle.default, handler:nil))
                self.present(phoneAlert, animated: true, completion: nil)
                
            }
            else{
                
                let query = PFUser.query()
                
                query?.whereKey("phone", equalTo:self.phoneInput.text! )
                do {
                    
                    let users = try query?.findObjects()
                    
                    if let users = users as? [PFUser] {
                        if users.count == 0 {
                            
                            print("nimanimaniamniamanimaniam")
                            newUser["phone"]=self.phoneInput.text
                            
                            
                            var user = PFUser()
                            user["firstName"] = newUser["firstName"];
                            user["lastName"] = newUser["lastName"];
                            user["dateOfBirth"] = newUser["dateOfBirth"];
                            user.username = newUser["signupUsername"];
                            user.password = newUser["signupPassword"];
                            user["phone"] = newUser["phone"];
                            user.acl?.getPublicWriteAccess
                            
                            user.signUpInBackground(block: { (success, error) in
                                
                                if (error as? NSError) != nil {
                                    let title = "Signup Failed"
                                    let message = "This phone has been registered"
                                    let action1 = "OK"
                                    let phoneSignupAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
                                    phoneSignupAlert.addAction(UIAlertAction(title:action1,style: UIAlertActionStyle.default, handler:nil))
                                    self.present(phoneSignupAlert, animated: true, completion: nil)
                                    
                                    
                                    
                                } else {
                                     self.performSegue(withIdentifier: "signupLogin", sender: self)
                                    let title = "Signup success"
                                    let message = "welcome"
                                    let action1 = "OK"
                                    let sSignupAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
                                    sSignupAlert.addAction(UIAlertAction(title:action1,style: UIAlertActionStyle.default, handler:nil))
                                    self.present(sSignupAlert, animated: true, completion: nil)
                                    
                                    
                                }
                                
                            })
                            
                            
                            
                        }else{
                            
                            
                            let title = "Warning"
                            let message = "This phone has been registered!"
                            let action = "OK"
                            let phoneAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
                            phoneAlert.addAction(UIAlertAction(title:action,style: UIAlertActionStyle.default, handler:nil))
                            self.present(phoneAlert, animated: true, completion: nil)
                            
                            
                        }
                    }
                    
                } catch {
                    
                    print ("Could not get users")
                    
                }

                }
        }catch {
            print(error)
        }
        
        
        
        
    }

    
    
    
    
    //email signup
    @IBAction func emailSubmitButton(_ sender: UIButton) {
        
        let pattern = "^[a-z0-9]+([._\\-]*[a-z0-9])*@([a-z0-9]+[-a-z0-9]*[a-z0-9]+.){1,63}[a-z0-9]+$"
        
        
        do {
            
            
            let regex =  try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let resEmail = regex.numberOfMatches(in: self.emailInput.text!, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, (self.emailInput.text?.characters.count)!))
            
            
            if resEmail == 0{
                
                let title = "Warning"
                let message = "Invalid email format!"
                let action = "OK"
                let emailAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
                emailAlert.addAction(UIAlertAction(title:action,style: UIAlertActionStyle.default, handler:nil))
                self.present(emailAlert, animated: true, completion: nil)
                
            }
            else{
                
                newUser["email"]=self.emailInput.text
                
                
                var user = PFUser()
                user["firstName"] = newUser["firstName"];
                user["lastName"] = newUser["lastName"];
                user["dateOfBirth"] = newUser["dateOfBirth"];
                user.username = newUser["signupUsername"];
                user.password = newUser["signupPassword"];
                user.email = newUser["email"];
                user.acl?.getPublicWriteAccess
                
                
                user.signUpInBackground(block: { (success, error) in
                    
                    if (error as? NSError) != nil {
                        let title = "Signup Failed"
                        let message = "This email has been registered"
                        let action1 = "OK"
                        let phoneSignupAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
                        phoneSignupAlert.addAction(UIAlertAction(title:action1,style: UIAlertActionStyle.default, handler:nil))
                        self.present(phoneSignupAlert, animated: true, completion: nil)
                        
                        
                        
                    } else {
                        self.performSegue(withIdentifier: "signupLogin", sender: self)

                        let title = "Signup success"
                        let message = "welcome"
                        let action1 = "OK"
                        let sSignupAlert = UIAlertController(title:title, message:message,preferredStyle:UIAlertControllerStyle.alert)
                        sSignupAlert.addAction(UIAlertAction(title:action1,style: UIAlertActionStyle.default, handler:nil))
                        self.present(sSignupAlert, animated: true, completion: nil)
                        
                        
                    }
                    
                    
                })
                

            }
            
            
            
            
        }catch {
            print(error)
        } 
        
        
        
    }
    
    
    // segmented control
    @IBAction func switchPhoneEmail(_ sender: UISegmentedControl) {
        
        switch phoneOrEmail.selectedSegmentIndex
        {
        case 0:
            subViewPhone.isHidden=false
            subViewEmail.isHidden=true
            print(newUser)
            print("dddd")
            
            
            
        case 1:
            subViewPhone.isHidden=true
            subViewEmail.isHidden=false
            print("dfdfdfd")
        default:
            
            break;
        }
    }
    
}
