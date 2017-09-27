/*
 File: FriendTableCell
 Author: CoDex
 Purpose: This class archieve the cell of friend view
 */

import UIKit

class FriendTableCell: UITableViewCell {
    
    
    
    @IBOutlet var chatButton: UIButton!
    @IBOutlet var viewButton: UIButton!
    
    //@IBOutlet var userPhone: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
