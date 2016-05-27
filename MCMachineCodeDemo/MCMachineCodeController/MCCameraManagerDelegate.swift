//
//  MCCameraManagerDelegate.swift
//  MCMachineCodeDemo
//
//  Created by 马超 on 16/5/26.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//

import UIKit

protocol MCCameraManagerDelegate : NSObjectProtocol {
    
    func deviceConfigurationFailedWithError(error: NSError?)
    func mediaCaptureFailedWithError(error: NSError?)
    func assetLibraryWriteFailedWithError(error: NSError?)
   
}
