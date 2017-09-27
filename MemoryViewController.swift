/*
 File: MemoryViewController
 Author: CoDex
 Purpose: This class is used to control the memory view.
 */

import UIKit
import Parse
//for memory

class MemoryViewController: UIViewController{// , UIScrollViewDelegate{
    
    @IBAction func deleteMemory(_ sender: UIButton) {
        
    }
    @IBOutlet var cameraRoll: UICollectionView!
    
    //@IBOutlet weak var scrollView: UIScrollView!
    
   // @IBAction func segmentedControl(_ sender: UISegmentedControl) {
   //     let x = scrollView.frame.size.width * CGFloat(sender.selectedSegmentIndex)
   //     scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    //}
    
    //@IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var imageID = [String]()
    var images = [UIImage]()
    var photos:[PFObject] = []
    var bigImage: UIImageView?
    var imageWidth: CGFloat?
    var imageHeight: CGFloat?
    var collectionBackgroundView: UIView?
    var bigImageIsShowed = false
    var currentCenterPoint = CGPoint()
    var selectedCell: CameraRollCell?
    var currentPosition:Int = 0
    
    func loadPhoto(){
        self.images = [UIImage]()
        imageID = [String]()
        let query = PFQuery(className:"Memory")
        query.whereKey("owner",equalTo: (PFUser.current()?.username)! as String)//sdjflksdjlfjlsd
        do{
            photos = try query.findObjects()
            
            if photos.count > 0 {
                for photo in photos {
                    if let pfFile = (photo["photo"] as? PFFile) {
                        pfFile.getDataInBackground(block: { (data, error) in
                            if let imageData = data {
                                let imageToDisplay = UIImage(data: imageData)
                                self.images.append(imageToDisplay!)
                                self.cameraRoll.reloadData()
                            }
                        })
                        self.imageID.append(photo.objectId!)
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
        //scrollView.delegate = self
        //images = ["1", "2", "3"].map { UIImage(named: $0)! }
        self.loadPhoto()
        cameraRoll.dataSource = self
        cameraRoll.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Scrollview Delegate
    //func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //    let w = scrollView.frame.size.width
    //    let page = scrollView.contentOffset.x / w
    //    segmentedControl.selectedSegmentIndex = Int(round(page))
    //
    //}
    
}

extension MemoryViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cameraCell", for: indexPath) as!  CameraRollCell
        cell.imageView.image = images[(indexPath as NSIndexPath).row]
        cell.Id = imageID[(indexPath as NSIndexPath).row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3, height: collectionView.frame.width / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedCell = collectionView.cellForItem(at: indexPath) as! CameraRollCell?
        self.currentPosition = (indexPath as NSIndexPath).row
        let cellContentView = collectionView.cellForItem(at: indexPath)?.contentView
        let rect = cellContentView!.convert(cellContentView!.frame, to: self.view)
        if bigImageIsShowed == false {
            
            collectionView.alpha = 0.5
            
            bigImageIsShowed = true
            currentCenterPoint = CGPoint(x: rect.origin.x + rect.size.width / 2, y: rect.origin.y + rect.size.height / 2)
            
            showBigImage()
            
            self.bigImage?.image = images[(indexPath as NSIndexPath).row]
            self.bigImage?.frame.size = CGSize(width: self.cameraRoll.frame.width / 3, height: self.cameraRoll.frame.width / 3)
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
        var deleteButton = UIButton()
        deleteButton.frame = CGRect(x: 0, y: 500, width: 100 , height: 50)
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(UIColor.blue, for: .normal)
        deleteButton.addTarget(self, action: #selector(handledelete(_:)), for: .touchUpInside)
        //bigImage?.addSubview(deleteButton)
        view.addSubview(collectionBackgroundView!)
        view.addSubview(deleteButton)
        collectionBackgroundView!.addSubview(bigImage!)

    }
    
    func dismissBigImage() {
        cameraRoll.alpha = 1
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.bigImage?.frame.size = CGSize(width: self.view.frame.width / 3, height: self.view.frame.width / 3)
            self.bigImage?.center = self.currentCenterPoint
            
            }, completion: { _ in
                self.selectedCell?.isHidden = false
                self.bigImage?.removeFromSuperview()
                self.collectionBackgroundView?.removeFromSuperview()
                self.bigImageIsShowed = false
        })
    }
    
    func handledelete(_ sender: UIButton) {
        print("..............press button")
        print(selectedCell!.Id)
        let query = PFQuery(className:"Memory")
        query.whereKey("objectId",equalTo: (selectedCell!.Id))
        
        do{
            photos = try query.findObjects()
            
            photos[0].deleteInBackground()
            
        }
        catch{
            print("error")
        }
        dismissBigImage()
        
        self.loadPhoto()
        
        
        
    }
    
}

