/*  File: StoriesCollectionViewController
 Author: CoDex
 Purpose: An implementation of scrollable list of public stories.
 */

import UIKit

class StoriesCollectionViewController: UICollectionViewController
{
    
    // data source
    let publishers = Publishers()
    
    fileprivate let leftAndRightPaddings: CGFloat = 32.0
    fileprivate let numberOfItemsPerRow: CGFloat = 6.0
    fileprivate let heigthAdjustment: CGFloat = 15.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = (collectionView!.frame.width - leftAndRightPaddings) / numberOfItemsPerRow
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width + heigthAdjustment)
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return publishers.numberOfPublishers
    }
    
    fileprivate struct Storyboard
    {
        static let CellIdentifier = "PublisherCell"
        static let showWebView = "StoryShowWebView"
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier, for: indexPath) as! PublisherCollectionViewCell
        
        cell.publisher = publishers.publisherForItemAtIndexPath(indexPath)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let publisher = publishers.publisherForItemAtIndexPath(indexPath)
        self.performSegue(withIdentifier: Storyboard.showWebView, sender: publisher)
    }
    // deliver the data of suggested stories
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.showWebView {
            let StorywebViewController = segue.destination as! WebViewController
            let publisher = sender as! Publisher
            StorywebViewController.publisher = publisher
        }
    }
    
}

























