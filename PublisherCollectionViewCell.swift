/*  File: PublisherCollectionViewCell
 Author: CoDex
 Purpose: An implementation of the collectionView which is used to contain each suggested stories.
 */

import UIKit

class PublisherCollectionViewCell: UICollectionViewCell
{
    
    @IBOutlet weak var publisherImageView: UIImageView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var publisherTitleLabel: UILabel!
    
    var publisher: Publisher? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI()
    {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 3.0
        publisherImageView.image = publisher?.image
        publisherTitleLabel.text = publisher?.title
    }
    
    
}































