/*
 File: PhotoCaptureDelegate
 Author: CoDex
 Purpose: This file is used for review video recorded.
 */

import UIKit
import AVFoundation

class VideoViewController: UIViewController {
    
    var url = URL(string: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let player = AVPlayer(url: self.url!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        player.play()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
