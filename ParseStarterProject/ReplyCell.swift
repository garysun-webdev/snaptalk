/*
 File: ReplyCell
 Author: CoDex
 Purpose: This class is used for reply.
 */

import UIKit

class ReplyCell: UICollectionViewCell {
    //@IBOutlet var replyButton: UIButton!
    
    //@IBAction func reply(_ sender: UIButton) {
    //}
    @IBOutlet var bubble: UIView!
    
    @IBOutlet var label: UILabel!
    
    var imageID:String = ""
}
