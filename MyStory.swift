/*
 File: MyStoryRollCell
 Author: CoDex
 Purpose: this part is used to control the MyStory
 */

import UIKit
import Parse
class MyStory: UIViewController {
    
    @IBOutlet weak var MyStoryRoll: UICollectionView!
    var images = [UIImage]()
    var photos:[PFObject] = []
    var bigImage: UIImageView?
    var imageWidth: CGFloat?
    var imageHeight: CGFloat?
    var collectionBackgroundView: UIView?
    var bigImageIsShowed = false
    var currentCenterPoint = CGPoint()
    var selectedCell: MyStoryRollCell?
    var currentPosition:Int = 0
    
    func loadPhoto(){
        let query = PFQuery(className:"Story")
        query.whereKey("owner",equalTo: (PFUser.current()?.username)! as String)//***********************
        do{
            photos = try query.findObjects()
            
            if photos.count > 0 {
                for photo in photos {
                    if let pfFile = (photo["photo"] as? PFFile) {
                        pfFile.getDataInBackground(block: { (data, error) in
                            if let imageData = data {
                                let imageToDisplay = UIImage(data: imageData)
                                self.images.append(imageToDisplay!)
                                self.MyStoryRoll.reloadData()
                            }
                        })
                    }
                }
            }
        }
        catch{
            print("error")
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadPhoto()
        MyStoryRoll.dataSource = self
        MyStoryRoll.delegate = self
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}

extension MyStory : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyStoryCell", for: indexPath) as!  MyStoryRollCell
        cell.imageView.image = images[(indexPath as NSIndexPath).row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3, height: collectionView.frame.width / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedCell = collectionView.cellForItem(at: indexPath) as! MyStoryRollCell?
        self.currentPosition = (indexPath as NSIndexPath).row
        let cellContentView = collectionView.cellForItem(at: indexPath)?.contentView
        let rect = cellContentView!.convert(cellContentView!.frame, to: self.view)
        if bigImageIsShowed == false {
            
            collectionView.alpha = 0.5
            
            bigImageIsShowed = true
            currentCenterPoint = CGPoint(x: rect.origin.x + rect.size.width / 2, y: rect.origin.y + rect.size.height / 2)
            
            
            showBigImage()
            
            self.bigImage?.image = images[(indexPath as NSIndexPath).row]
            self.bigImage?.frame.size = CGSize(width: self.MyStoryRoll.frame.width / 3, height: self.MyStoryRoll.frame.width / 3)
            self.bigImage?.center = self.currentCenterPoint
            
            UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.bigImage!.frame.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                self.bigImage!.center = self.view.center
                self.selectedCell?.isHidden = true
                }, completion: nil)
            
        }
    }
    
    func showBigImage() {
        collectionBackgroundView = UIScrollView()
        collectionBackgroundView?.frame = view.frame
        collectionBackgroundView?.backgroundColor = UIColor.clear
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissBigImage))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        collectionBackgroundView?.addGestureRecognizer(swipeDown)
        
        bigImage = UIImageView(frame: CGRect(x: currentCenterPoint.x, y: currentCenterPoint.y, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
        
        view.addSubview(collectionBackgroundView!)
        collectionBackgroundView!.addSubview(bigImage!)
    }
    
    func dismissBigImage() {
        MyStoryRoll.alpha = 1
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.bigImage?.frame.size = CGSize(width: self.MyStoryRoll.frame.width / 3, height: self.MyStoryRoll.frame.width / 3)
            self.bigImage?.center = self.currentCenterPoint
            
            }, completion: { _ in
                self.selectedCell?.isHidden = false
                self.bigImage?.removeFromSuperview()
                self.collectionBackgroundView?.removeFromSuperview()
                self.bigImageIsShowed = false
        })
    }
    
}


