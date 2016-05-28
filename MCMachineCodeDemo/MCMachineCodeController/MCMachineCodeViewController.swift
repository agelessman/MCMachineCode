//
//  MCMachineCodeViewController.swift
//  MCMachineCodeDemo
//
//  Created by 马超 on 16/5/25.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//

import UIKit
import AVFoundation

public class MCMachineCodeViewController: UIViewController,MCPreviewViewDelegate {
    
    
    public var didGetMachineCode: ((code: String) -> Void)?
    
    private var previewView: MCPreviewView!
    private var cameraManager: MCCameraManager!
    private var isGetCode = false
    private var lineType: LineType = LineType.Grid
    private var moveType: MoveType = MoveType.Default
    private var statusBarStyle: UIStatusBarStyle!
    
    init(lineType: LineType , moveType: MoveType) {
     
        super.init(nibName: nil, bundle: nil)
        
        self.lineType = lineType
        self.moveType = moveType
    }
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override public func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        setupNavWithIsHideNav(true)
    }

    override public func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        setupNavWithIsHideNav(false)
        
        self.cameraManager.stopSession()
        self.previewView.overlayView.stopMoving()
    }

    override public func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        self.statusBarStyle = UIApplication.sharedApplication().statusBarStyle
        
        setupPreviewView()
        setupBackView()

        self.cameraManager = MCCameraManager()
        if self.cameraManager.setupSession().0{
            
            self.previewView.session = self.cameraManager.captureSession
            self.cameraManager.codeDelegate = self.previewView
            self.cameraManager.startSession()
        }
        else {
            
            print(self.cameraManager.setupSession().1?.localizedDescription)
        }
        
        let pan = UIPanGestureRecognizer()
        self.view.addGestureRecognizer(pan)
    }
    
    
    //MARK: - setup views
    // set up previewView
    func setupPreviewView() {
        
        previewView = MCPreviewView(lineType: self.lineType, moveType: self.moveType)
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.delegate = self
        self.view.addSubview(previewView)
        
        let contraint1 = NSLayoutConstraint(item: previewView,
                                            attribute: NSLayoutAttribute.Left,
                                            relatedBy: NSLayoutRelation.Equal,
                                            toItem: self.view,
                                            attribute: NSLayoutAttribute.Left,
                                            multiplier: 1.0,
                                            constant: 0.0)
        let contraint2 = NSLayoutConstraint(item: previewView,
                                            attribute: NSLayoutAttribute.Right,
                                            relatedBy: NSLayoutRelation.Equal,
                                            toItem: self.view,
                                            attribute: NSLayoutAttribute.Right,
                                            multiplier: 1.0,
                                            constant: 0.0)
        let contraint3 = NSLayoutConstraint(item: previewView,
                                            attribute: NSLayoutAttribute.Top,
                                            relatedBy: NSLayoutRelation.Equal,
                                            toItem: self.view,
                                            attribute: NSLayoutAttribute.Top,
                                            multiplier: 1.0,
                                            constant: 0.0)
        let contraint4 = NSLayoutConstraint(item: previewView,
                                            attribute: NSLayoutAttribute.Bottom,
                                            relatedBy: NSLayoutRelation.Equal,
                                            toItem: self.view,
                                            attribute: NSLayoutAttribute.Bottom,
                                            multiplier: 1.0,
                                            constant: 0.0)
        self.view.addConstraints([contraint1,contraint2,contraint3,contraint4])
    }
    
    func setupBackView() {
        
        let backButton = UIButton()
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(named: "back"), forState: UIControlState.Normal)
        backButton.addTarget(self, action: #selector(MCMachineCodeViewController.backAction), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(backButton)
        
        let contraint1 = NSLayoutConstraint(item: backButton,
                                            attribute: NSLayoutAttribute.Left,
                                            relatedBy: NSLayoutRelation.Equal,
                                            toItem: self.view,
                                            attribute: NSLayoutAttribute.Left,
                                            multiplier: 1.0,
                                            constant: 10.0)
        let contraint2 = NSLayoutConstraint(item: backButton,
                                            attribute: NSLayoutAttribute.Top,
                                            relatedBy: NSLayoutRelation.Equal,
                                            toItem: self.view,
                                            attribute: NSLayoutAttribute.Top,
                                            multiplier: 1.0,
                                            constant: 20.0)
        let contraint3 = NSLayoutConstraint(item: backButton,
                                            attribute: NSLayoutAttribute.Width,
                                            relatedBy: NSLayoutRelation.Equal,
                                            toItem: nil,
                                            attribute: NSLayoutAttribute.NotAnAttribute,
                                            multiplier: 1.0,
                                            constant: 50.0)
        let contraint4 = NSLayoutConstraint(item: backButton,
                                            attribute: NSLayoutAttribute.Height,
                                            relatedBy: NSLayoutRelation.Equal,
                                            toItem: nil,
                                            attribute: NSLayoutAttribute.NotAnAttribute,
                                            multiplier: 1.0,
                                            constant: 50.0)
        self.view.addConstraints([contraint1,contraint2,contraint3,contraint4])
    }
    
    func backAction() {
        
        if let _ = self.navigationController {
            
            self.navigationController?.popViewControllerAnimated(false)
        }
        else {
            
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    func didDectectionCode(code: String) {

        if self.isGetCode {
            
            return
        }
        
        self.isGetCode = true
        
        self.cameraManager.stopSession()
        
        backAction()
        
        if let _ = self.didGetMachineCode {
            
            self.didGetMachineCode!(code: code)
        }
        // play down sound
        playSound()

    }

    func playSound() {
        
        let path = NSBundle.mainBundle().pathForResource("qrcode_found", ofType: "wav")
        
        if let path = path {
            
            var soundID: SystemSoundID = 0
            let soundURL = NSURL(fileURLWithPath: path)
            AudioServicesCreateSystemSoundID(soundURL, &soundID)
            
            AudioServicesPlayAlertSound(soundID)
        }
    
   
    }
    
    func setupNavWithIsHideNav(hideNav: Bool) {
        
        if let nav = self.navigationController {
            
            nav.navigationBar.hidden = hideNav

            UIApplication.sharedApplication().setStatusBarStyle(hideNav == true ? UIStatusBarStyle.LightContent : self.statusBarStyle, animated: false)
        }
    }
    
    
    deinit
    {
        self.cameraManager.stopSession()
    }
}
