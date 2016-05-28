//
//  MCBaseCameraManager.swift
//  MCMachineCodeDemo
//
//  Created by 马超 on 16/5/26.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//

import UIKit
import AVFoundation

let MCCameraErrorDomain = "com.MACHAO.MCCameraErrorDomain"
let MCThumbnailCreatedNotification = "MCThumbnailCreated"

enum MCCameraErrorCode : Int {
    case FailedToAddInput = 98
    case FailedToAddOutput
}

public class MCBaseCameraManager: NSObject {
    
    var captureSession: AVCaptureSession!
    weak var delegate: MCCameraManagerDelegate?


    //MARK: - interface method
    
    // set up session
    func setupSession() -> (success: Bool , error: NSError?) {
        
        self.captureSession = AVCaptureSession()
        self.captureSession.sessionPreset = sessionPreset()

        let inputResult = setupSessionInputs()
        if inputResult.0 == false {
            return (false,inputResult.1)
        }
        
        let outputResult = setupSessionOutputs()
        if outputResult.0 == false {
            return (false,outputResult.1)
        }
        
        self.videoQueue = dispatch_queue_create("com.MC.VideoQueue", DISPATCH_QUEUE_SERIAL)
        
        return (true,inputResult.1 != nil ? inputResult.1 : outputResult.1)
    }
    
    // start session
    func startSession() {
        
        if !self.captureSession.running {
            
            dispatch_async(self.videoQueue!, {
                
                self.captureSession.startRunning()
            })
        }
    }
    
    // stop session
    func stopSession() {
        
        if self.captureSession.running {
            
            dispatch_async(self.videoQueue!, {
                
                self.captureSession.stopRunning()
            })
        }
    }
    
    //MARK: - private parameter
    
    private var activeVideoInput: AVCaptureDeviceInput?
    private var imageOutput: AVCaptureStillImageOutput?
    private var videoQueue: dispatch_queue_t?
    
    //MARK: - private method
    
    // get session preset
    func sessionPreset() -> String {
        
        return AVCaptureSessionPresetHigh
    }
    
    // set up input
    func setupSessionInputs() -> (success: Bool , error: NSError?) {
        
        var inputError: NSError?
        var videoInput: AVCaptureDeviceInput?
        // set up default camera device
        let videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
            
            videoInput = try AVCaptureDeviceInput(device: videoDevice)
        }
        catch  let exception as NSError {
            inputError = exception
        }
        
        if let input = videoInput {
           
            /**
             *  add input
             *
             *  Before you add, you need to determine whether to add
             */
            if self.captureSession.canAddInput(input) {
                
                self.captureSession.addInput(input)
                self.activeVideoInput = input
            }
            else {
                
                inputError = NSError(domain: MCCameraErrorDomain,
                                     code:MCCameraErrorCode.FailedToAddInput.rawValue ,
                                     userInfo: [NSLocalizedDescriptionKey:"Failed to add video input."])
                return (false,inputError)
            }
        }
        else {
            
            return (false,inputError)
        }
        
        return (true,inputError)
    }
    
    // set up output
    func setupSessionOutputs() -> (success: Bool , error: NSError?) {
        
        var inputError: NSError?

        // set up default camera device
        self.imageOutput = AVCaptureStillImageOutput()

        /**
         *  add output
         *
         *  Before you add, you need to determine whether to add
         */
        if self.captureSession.canAddOutput(self.imageOutput!) {
            
            self.captureSession.addOutput(self.imageOutput!)
            
        }
        else {
            
            inputError = NSError(domain: MCCameraErrorDomain,
                                 code:MCCameraErrorCode.FailedToAddOutput.rawValue ,
                                 userInfo: [NSLocalizedDescriptionKey:"Failed to still image output."])
            return (false,inputError)
        }
 
        return (true,inputError)
    }
    
    //MARK: - device configure
    
    // get device by position
    func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        
        for device in devices as! [AVCaptureDevice] {
            
            if device.position == position {
                
                return device
            }
        }
        
        return nil
    }
    
    // get current camera
    func activeCamera() -> AVCaptureDevice {
        
        return self.activeVideoInput!.device
    }
    
    // get not curent camera
    func inactiveCamera() -> AVCaptureDevice? {
        
        var device: AVCaptureDevice?
        
        if cameraCount() > 1 {
            
            if activeCamera().position == AVCaptureDevicePosition.Back {
                
                device = cameraWithPosition(AVCaptureDevicePosition.Front)
            }
            else {
                
                device = cameraWithPosition(AVCaptureDevicePosition.Back)
            }
        }
        
        return device
    }
    
    // get camera count
    func cameraCount() -> Int {
        
        return AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).count
    }
    
    // is can switch camera
    func canSwitchCamera() -> Bool {
        
        return cameraCount() > 1 ? true : false
    }
    
    // switch camera
    func switchCamera() -> Bool {
        
        if !canSwitchCamera() { return false }
        
        var videoInput: AVCaptureDeviceInput?
        
        var error: NSError?
        
        let videoDevice = activeCamera()
        do {
            
            videoInput = try AVCaptureDeviceInput(device: videoDevice)
        }
        catch let ex as NSError {
            
            error = ex
        }
        
        if let input = videoInput {
            
            self.captureSession.beginConfiguration()
            
            self.captureSession.removeInput(self.activeVideoInput!)
            
            if self.captureSession.canAddInput(input) {
                
                self.captureSession.addInput(input)
                self.activeVideoInput = input
            }
            else {
                
                self.captureSession.addInput(self.activeVideoInput!)
            }
            
            self.captureSession.commitConfiguration()
            
        }
        else {
            
            if let _ = self.delegate {
                
                self.delegate!.deviceConfigurationFailedWithError(error)
            }
           return false
        }
        
        return true
    }
    
}
