//
/*  File: PublishersCollectionViewController
 Author: CoDex
 Purpose: An implementation of the collectionView to contain each suggested stories.
 */

import UIKit

class PublishersCollectionViewController: UICollectionViewController
{
    
    // data source
    let publishers = Publishers()
    
    fileprivate let leftAndRightPaddings: CGFloat = 32.0
    fileprivate let numberOfItemsPerRow: CGFloat = 3.0
    fileprivate let heigthAdjustment: CGFloat = 30.0
    
    // MARK: - View controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = (collectionView!.frame.width - leftAndRightPaddings) / numberOfItemsPerRow
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width + heigthAdjustment)
        
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return publishers.numberOfPublishers
    }
    
    fileprivate struct Storyboard
    {
        static let CellIdentifier = "PublisherCell"
        static let showWebView = "ShowWebView"
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier, for: indexPath) as! PublisherCollectionViewCell
        
        cell.publisher = publishers.publisherForItemAtIndexPath(indexPath)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let publisher = publishers.publisherForItemAtIndexPath(indexPath)
        self.performSegue(withIdentifier: Storyboard.showWebView, sender: publisher)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.showWebView {
            let webViewController = segue.destination as! WebViewController
            let publisher = sender as! Publisher
            webViewController.publisher = publisher
        }
    }
    
}

























