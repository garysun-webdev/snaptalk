/*  File: WebViewController
  Author: CoDex
  Purpose: For loading the specific web pages of discovery.
*/

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate
{
    
    var publisher: Publisher!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet fileprivate weak var webView: UIWebView!
    
    fileprivate var hasFinishLoading = false
    override func viewDidLoad() {
        super.viewDidLoad()
        title = publisher.title
        webView.delegate = self
        webView.stopLoading()
        let pageURL = URL(string: publisher.url)!
        let request = URLRequest(url: pageURL)
        webView.loadRequest(request)
    }
    
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        hasFinishLoading = false
        updateProgress()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            [weak self] in
            if let _self = self {
                _self.hasFinishLoading = true
            }
        }
    }
    
    deinit {
        webView.stopLoading()
        webView.delegate = nil
    }
    
    func updateProgress() {
        if progressView.progress >= 1 {
            progressView.isHidden = true
        } else {
            
            if hasFinishLoading {
                progressView.progress += 0.002
            } else {
                if progressView.progress <= 0.3 {
                    progressView.progress += 0.004
                } else if progressView.progress <= 0.6 {
                    progressView.progress += 0.002
                } else if progressView.progress <= 0.9 {
                    progressView.progress += 0.001
                } else if progressView.progress <= 0.94 {
                    progressView.progress += 0.0001
                } else {
                    progressView.progress = 0.9401
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.008 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                [weak self] in
                if let _self = self {
                    _self.updateProgress()
                }
            }
        }
    }
    
    
}
