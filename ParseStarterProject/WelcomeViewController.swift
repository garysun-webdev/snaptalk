/*
 File: WelcomeViewController
 Author: CoDex
 Purpose: This part is the cover page.
 */

import UIKit
import Parse

class WelcomeViewController: UIViewController {
    @IBOutlet var sideBar: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
               
            print("nihaoma dsjfdslfjldskjflkdsjflkjsdlkfdsjflsdlfsdljfldsj")
        
}

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
       
    }
    
    
    @IBAction func bbbb(_ sender: UIButton) {
        print("00000000000000000000000000000")
        print(PFUser.current())
    }
}
