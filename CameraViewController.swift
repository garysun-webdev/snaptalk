/*
 File:CameraViewController
 Author: CoDex
 Purpose:This calss is used to control the CameraView
 
 */
import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
	
    
    var receiver:String = ""
    
    override func viewDidLoad() {
		super.viewDidLoad()

		previewView.session = session
		
		
			//Setup the capture session.
			
 
		sessionQueue.async { [unowned self] in
			self.configureSession()
        }
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		sessionQueue.async {
			switch self.setupResult {
                case .success:
				    // Only setup observers and start the session running if setup succeeded.
                    self.addObservers()
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
				
                case .notAuthorized:
                    DispatchQueue.main.async { [unowned self] in
                        let message = NSLocalizedString("AVCam doesn't have permission to use the camera, please change privacy settings", comment: "Alert message when the user has denied access to the camera")
                        let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                        alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .`default`, handler: { action in
                            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                        }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
				
                case .configurationFailed:
                    DispatchQueue.main.async { [unowned self] in
                        let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
                        let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
			}
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		sessionQueue.async { [unowned self] in
			if self.setupResult == .success {
				self.session.stopRunning()
				self.isSessionRunning = self.session.isRunning
				self.removeObservers()
			}
		}
		
		super.viewWillDisappear(animated)
	}
	
    override var shouldAutorotate: Bool {
		// Disable autorotation of the interface when recording is in progress.
		if let movieFileOutput = movieFileOutput {
			return !movieFileOutput.isRecording
		}
		return true
	}
	
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .all
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		if let videoPreviewLayerConnection = previewView.videoPreviewLayer.connection {
			let deviceOrientation = UIDevice.current.orientation
			guard let newVideoOrientation = deviceOrientation.videoOrientation, deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
				return
			}
			
			videoPreviewLayerConnection.videoOrientation = newVideoOrientation
		}
	}

	// Session Management
	
	private enum SessionSetupResult {
		case success
		case notAuthorized
		case configurationFailed
	}
	
	private let session = AVCaptureSession()
	
	private var isSessionRunning = false
	
	private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], target: nil) // Communicate with the session and other session objects on this queue.
	
	private var setupResult: SessionSetupResult = .success
	
	var videoDeviceInput: AVCaptureDeviceInput!
	
	@IBOutlet private weak var previewView: PreviewView!
    
	// Call this on the session queue.
	private func configureSession() {
		if setupResult != .success {
			return
		}
		session.beginConfiguration()
		
		//session.sessionPreset = AVCaptureSessionPresetPhoto
        self.session.sessionPreset = AVCaptureSessionPresetHigh
		// Add video input.
		do {
			var defaultVideoDevice: AVCaptureDevice?
			// Choose the back dual camera if available, otherwise default to a wide angle camera.
			if let dualCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInDuoCamera, mediaType: AVMediaTypeVideo, position: .back) {
				defaultVideoDevice = dualCameraDevice
			}
			else if let backCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back) {
				// If the back dual camera is not available, default to the back wide angle camera.
				defaultVideoDevice = backCameraDevice
			}
			else if let frontCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front) {
				// In some cases where users break their phones, the back wide angle camera is not available. In this case, we should default to the front wide angle camera.
				defaultVideoDevice = frontCameraDevice
			}
			
			let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice)
			
			if session.canAddInput(videoDeviceInput) {
				session.addInput(videoDeviceInput)
				self.videoDeviceInput = videoDeviceInput
			}
			else {
				print("Could not add video device input to the session")
				setupResult = .configurationFailed
				session.commitConfiguration()
				return
			}
		}
		catch {
			print("Could not create video device input: \(error)")
			setupResult = .configurationFailed
			session.commitConfiguration()
			return
		}
		
		// Add audio input.
		do {
            let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
			let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
			
			if session.canAddInput(audioDeviceInput) {
				session.addInput(audioDeviceInput)
			}
			else {
				print("Could not add audio device input to the session")
			}
		}
		catch {
			print("Could not create audio device input: \(error)")
		}
		
		// Add photo output.
		if session.canAddOutput(photoOutput)
		{
			session.addOutput(photoOutput)
			
			photoOutput.isHighResolutionCaptureEnabled = true
			photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
			livePhotoMode = photoOutput.isLivePhotoCaptureSupported ? .on : .off
		}
		else {
			print("Could not add photo output to the session")
			setupResult = .configurationFailed
			session.commitConfiguration()
			return
		}
        
        // add movie output
        let movieFileOutput = AVCaptureMovieFileOutput()
        if self.session.canAddOutput(movieFileOutput) {
            //self.session.beginConfiguration()
            self.session.addOutput(movieFileOutput)
            //self.session.sessionPreset = AVCaptureSessionPresetHigh
            if let connection = movieFileOutput.connection(withMediaType: AVMediaTypeVideo) {
                if connection.isVideoStabilizationSupported {
                    connection.preferredVideoStabilizationMode = .auto
                }
            }
            self.movieFileOutput = movieFileOutput
        }
		
		session.commitConfiguration()
	}
	
	// MARK: Device Configuration
	
	@IBOutlet private weak var cameraButton: UIButton!
	
	private let videoDeviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDuoCamera], mediaType: AVMediaTypeVideo, position: .unspecified)!
	
	@IBAction private func changeCamera(_ cameraButton: UIButton) {
		cameraButton.isEnabled = false
		recordButton.isEnabled = false
		
		
		sessionQueue.async { [unowned self] in
			let currentVideoDevice = self.videoDeviceInput.device
			let currentPosition = currentVideoDevice!.position
			
			let preferredPosition: AVCaptureDevicePosition
			let preferredDeviceType: AVCaptureDeviceType
			
			//switch currentPosition {
			//	case .unspecified, .front:
			//						case .back:
			//}
        if currentPosition == AVCaptureDevicePosition.back{
            preferredPosition = .front
            preferredDeviceType = .builtInWideAngleCamera
            self.isFlashOn = false
            self.FlashButton.isEnabled = false
        }else{
            preferredPosition = .back
            preferredDeviceType = .builtInDuoCamera
            self.isFlashOn = true
            self.FlashButton.isEnabled = true
        }
        
			
			let devices = self.videoDeviceDiscoverySession.devices!
			var newVideoDevice: AVCaptureDevice? = nil
			
			// First, look for a device with both the preferred position and device type. Otherwise, look for a device with only the preferred position.
			if let device = devices.filter({ $0.position == preferredPosition && $0.deviceType == preferredDeviceType }).first {
				newVideoDevice = device
			}
			else if let device = devices.filter({ $0.position == preferredPosition }).first {
				newVideoDevice = device
			}

            if let videoDevice = newVideoDevice {
                do {
					let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
					
					self.session.beginConfiguration()
					
					// Remove the existing device input first, since using the front and back camera simultaneously is not supported.
					self.session.removeInput(self.videoDeviceInput)
					
					if self.session.canAddInput(videoDeviceInput) {
						NotificationCenter.default.removeObserver(self, name: Notification.Name("AVCaptureDeviceSubjectAreaDidChangeNotification"), object: currentVideoDevice!)
						
						NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: Notification.Name("AVCaptureDeviceSubjectAreaDidChangeNotification"), object: videoDeviceInput.device)
						
						self.session.addInput(videoDeviceInput)
						self.videoDeviceInput = videoDeviceInput
					}
					else {
						self.session.addInput(self.videoDeviceInput);
					}
					
					if let connection = self.movieFileOutput?.connection(withMediaType: AVMediaTypeVideo) {
						if connection.isVideoStabilizationSupported {
							connection.preferredVideoStabilizationMode = .auto
						}
					}
					/*
						Set Live Photo capture enabled if it is supported. When changing cameras, the
						`isLivePhotoCaptureEnabled` property of the AVCapturePhotoOutput gets set to NO when
						a video device is disconnected from the session. After the new video device is
						added to the session, re-enable Live Photo capture on the AVCapturePhotoOutput if it is supported.
					*/
					self.photoOutput.isLivePhotoCaptureEnabled = self.photoOutput.isLivePhotoCaptureSupported;
					
					self.session.commitConfiguration()
				}
				catch {
					print("Error occured while creating video device input: \(error)")
				}
			}
			
			//DispatchQueue.main.async { [unowned self] in
				self.cameraButton.isEnabled = true
				self.recordButton.isEnabled = self.movieFileOutput != nil
				self.photoButton.isEnabled = true
                //self.FlashButton.isEnabled = false
			//}
		}
	}
	
	@IBAction private func focusAndExposeTap(_ gestureRecognizer: UITapGestureRecognizer) {
		let devicePoint = self.previewView.videoPreviewLayer.captureDevicePointOfInterest(for: gestureRecognizer.location(in: gestureRecognizer.view))
		focus(with: .autoFocus, exposureMode: .autoExpose, at: devicePoint, monitorSubjectAreaChange: true)
	}
	
	private func focus(with focusMode: AVCaptureFocusMode, exposureMode: AVCaptureExposureMode, at devicePoint: CGPoint, monitorSubjectAreaChange: Bool) {
		sessionQueue.async { [unowned self] in
			if let device = self.videoDeviceInput.device {
				do {
					try device.lockForConfiguration()
					
					/*
						Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
						Call set(Focus/Exposure)Mode() to apply the new point of interest.
					*/
					if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
						device.focusPointOfInterest = devicePoint
						device.focusMode = focusMode
					}
					
					if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
						device.exposurePointOfInterest = devicePoint
						device.exposureMode = exposureMode
					}
					
					device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
					device.unlockForConfiguration()
				}
				catch {
					print("Could not lock device for configuration: \(error)")
				}
			}
		}
	}
	
	// MARK: Capturing Photos

	private let photoOutput = AVCapturePhotoOutput()
	
	private var inProgressPhotoCaptureDelegates = [Int64 : PhotoCaptureDelegate]()
	
	@IBOutlet private weak var photoButton: UIButton!
    
    var imageCaptured:UIImage!
	
    
    //@IBOutlet weak var cancelButton: UIButton!
    
    
   // @IBAction func cancel(_ sender: AnyObject) {
    //    session.startRunning()
   //     self.cancelButton.isHidden = true
   // }
    
	@IBAction private func capturePhoto(_ photoButton: UIButton) {
		/*
			Retrieve the video preview layer's video orientation on the main queue before
			entering the session queue. We do this to ensure UI elements are accessed on
			the main thread and session configuration is done on the session queue.
		*/
		let videoPreviewLayerOrientation = previewView.videoPreviewLayer.connection.videoOrientation
		
		sessionQueue.async {
    
			// Update the photo output's connection to match the video orientation of the video preview layer.
			if let photoOutputConnection = self.photoOutput.connection(withMediaType: AVMediaTypeVideo) {
				photoOutputConnection.videoOrientation = videoPreviewLayerOrientation
			}
			
			// Capture a JPEG photo with flash set to auto and high resolution photo enabled.
			let photoSettings = AVCapturePhotoSettings()
            if self.isFlashOn {
                photoSettings.flashMode = .auto
            }else{
                photoSettings.flashMode = .off
            }
			photoSettings.isHighResolutionPhotoEnabled = true
			if photoSettings.availablePreviewPhotoPixelFormatTypes.count > 0 {
				photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String : photoSettings.availablePreviewPhotoPixelFormatTypes.first!]
			}
			if self.livePhotoMode == .on && self.photoOutput.isLivePhotoCaptureSupported { // Live Photo capture is not supported in movie mode.
				let livePhotoMovieFileName = NSUUID().uuidString
				let livePhotoMovieFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((livePhotoMovieFileName as NSString).appendingPathExtension("mov")!)
				photoSettings.livePhotoMovieFileURL = URL(fileURLWithPath: livePhotoMovieFilePath)
			}
			
            
            // Use a separate object for the photo capture delegate to isolate each capture life cycle.
            if self.isFlashOn {
                photoSettings.flashMode = .auto
            }else{
                photoSettings.flashMode = .off
            }
            photoSettings.isHighResolutionPhotoEnabled = true
            if photoSettings.availablePreviewPhotoPixelFormatTypes.count > 0 {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String : photoSettings.availablePreviewPhotoPixelFormatTypes.first!]
            }
            if self.livePhotoMode == .on && self.photoOutput.isLivePhotoCaptureSupported { // Live Photo capture is not supported in movie mode.
                let livePhotoMovieFileName = NSUUID().uuidString
                let livePhotoMovieFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((livePhotoMovieFileName as NSString).appendingPathExtension("mov")!)
                photoSettings.livePhotoMovieFileURL = URL(fileURLWithPath: livePhotoMovieFilePath)
            }
            
            // Use a separate object for the photo capture delegate to isolate each capture life cycle.
            let photoCaptureDelegate = PhotoCaptureDelegate(with: photoSettings,willCapturePhotoAnimation: {
                //DispatchQueue.main.async { [unowned self] in
                    self.previewView.videoPreviewLayer.opacity = 0
                    UIView.animate(withDuration: 0.25) { [unowned self] in
                        self.previewView.videoPreviewLayer.opacity = 1
                    }
                //}
                }, capturingLivePhoto: { capturing in
                    /*
                     Because Live Photo captures can overlap, we need to keep track of the
                     number of in progress Live Photo captures to ensure that the
                     Live Photo label stays visible during these captures.
                     */
                    self.sessionQueue.async { [unowned self] in
                        if capturing {
                            self.inProgressLivePhotoCapturesCount += 1
                        }
                        else {
                            self.inProgressLivePhotoCapturesCount -= 1
                        }
                    }
                }, completed: { [unowned self] photoCaptureDelegate in
                    // When the capture is complete, remove a reference to the photo capture delegate so it can be deallocated.
                    self.sessionQueue.async { [unowned self] in
                        self.inProgressPhotoCaptureDelegates[photoCaptureDelegate.requestedPhotoSettings.uniqueID] = nil
                    
                        
                        print(photoCaptureDelegate.photoData)
                        self.session.stopRunning()
                        //self.cancelButton.isHidden = false
                        let dataProvider = CGDataProvider(data: photoCaptureDelegate.photoData as! CFData)
                        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
                        self.imageCaptured = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                        self.performSegue(withIdentifier: "edit", sender: self)
                    }
                }
            )
            
			/*
				The Photo Output keeps a weak reference to the photo capture delegate so
				we store it in an array to maintain a strong reference to this object
				until the capture is completed.
			*/
			self.inProgressPhotoCaptureDelegates[photoCaptureDelegate.requestedPhotoSettings.uniqueID] = photoCaptureDelegate
			self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureDelegate)
        
            //session.stopRunning()
        
        
            //let dataProvider = CGDataProvider(data: photoCaptureDelegate.photoData as! CFData)
            //let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            //self.imageCaptured = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)

        
            //let dataProvider = CGDataProvider(data: photoCaptureDelegate.photoData as! CFData)
            //let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            //self.imageCaptured = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
            //if self.imageCaptured != nil {
            //    print("transfer successfully!")
            //}
		}
        //self.session.stopRunning()
        //self.cancelButton.isHidden = false
	}
	
	private enum LivePhotoMode {
		case on
		case off
	}
	
	private var livePhotoMode: LivePhotoMode = .on
	
	private var inProgressLivePhotoCapturesCount = 0
	
	// MARK: Recording Movies
	
	private var movieFileOutput: AVCaptureMovieFileOutput? = nil
	
	private var backgroundRecordingID: UIBackgroundTaskIdentifier? = nil
	
	@IBOutlet private weak var recordButton: UIButton!
	
    @IBOutlet weak var playerView: UIView!
	//@IBOutlet private weak var resumeButton: UIButton!
	
	@IBAction private func toggleMovieRecording(_ recordButton: UIButton) {
		guard let movieFileOutput = self.movieFileOutput else {
			return
		}
		
		/*
			Disable the Camera button until recording finishes, and disable
			the Record button until recording starts or finishes.
		
			See the AVCaptureFileOutputRecordingDelegate methods.
		*/
		cameraButton.isEnabled = false
		recordButton.isEnabled = false
		
		/*
			Retrieve the video preview layer's video orientation on the main queue
			before entering the session queue. We do this to ensure UI elements are
			accessed on the main thread and session configuration is done on the session queue.
		*/
		let videoPreviewLayerOrientation = previewView.videoPreviewLayer.connection.videoOrientation
		
		sessionQueue.async { [unowned self] in
			if !movieFileOutput.isRecording {
				if UIDevice.current.isMultitaskingSupported {
					/*
						Setup background task.
						This is needed because the `capture(_:, didFinishRecordingToOutputFileAt:, fromConnections:, error:)`
						callback is not received until AVCam returns to the foreground unless you request background execution time.
						This also ensures that there will be time to write the file to the photo library when AVCam is backgrounded.
						To conclude this background execution, endBackgroundTask(_:) is called in
						`capture(_:, didFinishRecordingToOutputFileAt:, fromConnections:, error:)` after the recorded file has been saved.
					*/
					self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
				}
				
				// Update the orientation on the movie file output video connection before starting recording.
				let movieFileOutputConnection = self.movieFileOutput?.connection(withMediaType: AVMediaTypeVideo)
				movieFileOutputConnection?.videoOrientation = videoPreviewLayerOrientation
				
				// Start recording to a temporary file.
				let outputFileName = NSUUID().uuidString
				let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
				movieFileOutput.startRecording(toOutputFileURL: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
			}
			else {
				movieFileOutput.stopRecording()
			}
		}
	}
	
	func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
		// Enable the Record button to let the user stop the recording.
		DispatchQueue.main.async { [unowned self] in
			self.recordButton.isEnabled = true
			self.recordButton.setTitle(NSLocalizedString("Stop", comment: "Recording button stop title"), for: [])
		}
	}
	
    var outputURL = URL(string: "")
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
		/*
			Note that currentBackgroundRecordingID is used to end the background task
			associated with this recording. This allows a new recording to be started,
			associated with a new UIBackgroundTaskIdentifier, once the movie file output's
			`isRecording` property is back to false — which happens sometime after this method
			returns.
		
			Note: Since we use a unique file path for each recording, a new recording will
			not overwrite a recording currently being saved.
		*/
		func cleanup() {
			let path = outputFileURL.path
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                }
                catch {
                    print("Could not remove file at url: \(outputFileURL)")
                }
            }
			
			if let currentBackgroundRecordingID = backgroundRecordingID {
				backgroundRecordingID = UIBackgroundTaskInvalid
				
				if currentBackgroundRecordingID != UIBackgroundTaskInvalid {
					UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
				}
			}
		}
		
		var success = true
		
		if error != nil {
			print("Movie file finishing error: \(error)")
			success = (((error as NSError).userInfo[AVErrorRecordingSuccessfullyFinishedKey] as AnyObject).boolValue)!
		}
		
		if success {
			// Check authorization status.
			PHPhotoLibrary.requestAuthorization { status in
				if status == .authorized {
					// Save the movie file to the photo library and cleanup.
					PHPhotoLibrary.shared().performChanges({
							let options = PHAssetResourceCreationOptions()
							options.shouldMoveFile = true
							let creationRequest = PHAssetCreationRequest.forAsset()
                        ///////avplayer
                            print(outputFileURL)
                            self.outputURL = outputFileURL
                            self.session.stopRunning()
                            self.performSegue(withIdentifier: "video", sender: self)
							creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
						}, completionHandler: { success, error in
							if !success {
								print("Could not save movie to photo library: \(error)")
							}
							cleanup()
						}
					)
				}
				else {
					cleanup()
				}
			}
		}
		else {
			cleanup()
		}
		
		// Enable the Camera and Record buttons to let the user switch camera and start another recording.
		DispatchQueue.main.async { [unowned self] in
			// Only enable the ability to change camera if the device has more than one camera.
			self.cameraButton.isEnabled = self.videoDeviceDiscoverySession.uniqueDevicePositionsCount() > 1
			self.recordButton.isEnabled = true
			self.recordButton.setTitle(NSLocalizedString("Record", comment: "Recording button record title"), for: [])
		}
	}
    
    private var isFlashOn = true
    
    @IBOutlet weak var FlashButton: UIButton!
    
    @IBAction func switchFlash(_ sender: UIButton) {
        if self.isFlashOn {
            self.isFlashOn = false
            self.FlashButton.titleLabel?.text = "flash:off"
        }else{
            self.isFlashOn = true
            self.FlashButton.titleLabel?.text = "flash:auto"
        }
    }
	
	// MARK: KVO and Notifications
	
	private var sessionRunningObserveContext = 0
	
	private func addObservers() {
		session.addObserver(self, forKeyPath: "running", options: .new, context: &sessionRunningObserveContext)
		
		NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaDidChange), name: Notification.Name("AVCaptureDeviceSubjectAreaDidChangeNotification"), object: videoDeviceInput.device)
	}
	
	private func removeObservers() {
		NotificationCenter.default.removeObserver(self)
		session.removeObserver(self, forKeyPath: "running", context: &sessionRunningObserveContext)
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if context == &sessionRunningObserveContext {
			let newValue = change?[.newKey] as AnyObject?
			guard let isSessionRunning = newValue?.boolValue else { return }
			
			DispatchQueue.main.async { [unowned self] in
				// Only enable the ability to change camera if the device has more than one camera.
				self.cameraButton.isEnabled = isSessionRunning && self.videoDeviceDiscoverySession.uniqueDevicePositionsCount() > 1
				self.recordButton.isEnabled = isSessionRunning && self.movieFileOutput != nil
				self.photoButton.isEnabled = isSessionRunning
			}
		}
		else {
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
		}
	}
	
	func subjectAreaDidChange(notification: NSNotification) {
		let devicePoint = CGPoint(x: 0.5, y: 0.5)
		focus(with: .autoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
	}
    
    //segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier{
            if id == "edit"{
                let vc = segue.destination as! ProcessViewController
                vc.processImage = imageCaptured
                vc.receiver = self.receiver
            }
            if id == "video"{
                let vc = segue.destination as! VideoViewController
                vc.url = self.outputURL
            }
        }
    }
}


extension UIDeviceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
            case .portrait: return .portrait
            case .portraitUpsideDown: return .portraitUpsideDown
            case .landscapeLeft: return .landscapeRight
            case .landscapeRight: return .landscapeLeft
            default: return nil
        }
    }
}

extension AVCaptureDeviceDiscoverySession {
	func uniqueDevicePositionsCount() -> Int {
		var uniqueDevicePositions = [AVCaptureDevicePosition]()
		
		for device in devices {
			if !uniqueDevicePositions.contains(device.position) {
				uniqueDevicePositions.append(device.position)
			}
		}
		return uniqueDevicePositions.count
	}
}
