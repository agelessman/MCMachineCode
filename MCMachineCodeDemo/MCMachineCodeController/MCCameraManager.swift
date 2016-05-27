//
//  MCCameraManager.swift
//  MCMachineCodeDemo
//
//  Created by 马超 on 16/5/27.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//

import UIKit
import AVFoundation


protocol MCCodeDetectionDelegate: NSObjectProtocol {
    
    func didDetectCodes(codes: [AnyObject])
}

class MCCameraManager: MCBaseCameraManager,AVCaptureMetadataOutputObjectsDelegate {
    
    var metadataOutput: AVCaptureMetadataOutput!
    weak var codeDelegate: MCCodeDetectionDelegate?

    override func sessionPreset() -> String {
        
        return AVCaptureSessionPresetHigh
    }
    
    override func setupSessionInputs() -> (success: Bool, error: NSError?) {
        
        var er: NSError?
        
        let success: Bool = super.setupSessionInputs().0
        
        if success {
            
            // can support auto focus
            if self.activeCamera().autoFocusRangeRestrictionSupported {
                
                do {
                    
                   try self.activeCamera().lockForConfiguration()
                }
                catch let ex as NSError {
                    
                    er = ex
                }
                
                if let _ = er {
                    
                    self.activeCamera().autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestriction.Near
                    
                    self.activeCamera().unlockForConfiguration()
                }
            }
        }
        
        return (success,er)
    }
    
    override func setupSessionOutputs() -> (success: Bool, error: NSError?) {
        
        var outputError: NSError?
        
        self.metadataOutput = AVCaptureMetadataOutput()
        
        if self.captureSession.canAddOutput(self.metadataOutput) {
            
            self.captureSession.addOutput(self.metadataOutput)
            
            let mainQueue = dispatch_get_main_queue()
            
            self.metadataOutput.setMetadataObjectsDelegate(self, queue: mainQueue)
            
            let types = [AVMetadataObjectTypeQRCode,
                         AVMetadataObjectTypeFace,
                         AVMetadataObjectTypeEAN8Code,
                         AVMetadataObjectTypeUPCECode,
                         AVMetadataObjectTypeAztecCode,
                         AVMetadataObjectTypeEAN13Code,
                         AVMetadataObjectTypeITF14Code,
                         AVMetadataObjectTypeCode39Code,
                         AVMetadataObjectTypeCode93Code,
                         AVMetadataObjectTypePDF417Code,
                         AVMetadataObjectTypeCode128Code,
                         AVMetadataObjectTypeInterleaved2of5Code,AVMetadataObjectTypeDataMatrixCode,AVMetadataObjectTypeCode39Mod43Code]
            
            self.metadataOutput.metadataObjectTypes = types
        }
        else {
            
            outputError = NSError(domain: MCCameraErrorDomain,
                                 code:MCCameraErrorCode.FailedToAddOutput.rawValue ,
                                 userInfo: [NSLocalizedDescriptionKey:"Failed to still image output."])
            return (false,outputError)
        }
        
        return (true,outputError)
    }
    
    // metadata obj delegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        if let _ = self.codeDelegate {
            
            self.codeDelegate!.didDetectCodes(metadataObjects)
        }
        
    }
}
