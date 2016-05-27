//
//  MCPreviewView.swift
//  MCMachineCodeDemo
//
//  Created by 马超 on 16/5/25.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//

import UIKit
import AVFoundation

protocol MCPreviewViewDelegate : NSObjectProtocol {
    
    func didDectectionCode(code: String)

    
}

class MCPreviewView: UIView,MCCodeDetectionDelegate {
    
    var codeLayers: NSMutableDictionary!
    weak var delegate: MCPreviewViewDelegate?

    
    private var lineType: LineType = LineType.Grid
    private var moveType: MoveType = MoveType.Default
    
    var session: AVCaptureSession {
        
        set {
            self.previewLayer.session = newValue
        }
        get {
            return self.previewLayer.session
        }
    }
    
    var overlayView: MCOverlayView!
    
    init(lineType: LineType , moveType: MoveType) {
        
        super.init(frame: CGRectZero)
        
        self.lineType = lineType
        self.moveType = moveType
        
        configurePreviewLayer()
        setupOverlayView()
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        
        configurePreviewLayer()
        setupOverlayView()
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        configurePreviewLayer()
        setupOverlayView()
    }
    
    // override return layer
    override class func layerClass() -> AnyClass {
        
        return AVCaptureVideoPreviewLayer.self
    }
    
    // private layer
    private var previewLayer: AVCaptureVideoPreviewLayer  {
        
        get {
            
            return self.layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    //MARK: - private method
    
    func setupOverlayView() {
        
        self.overlayView = MCOverlayView(lineType: self.lineType, moveType: self.moveType, lineColor: UIColor(red: 0/255.0, green: 153/255.0, blue: 204/255.0, alpha: 1.0))
        self.overlayView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.overlayView)
        
        let contraint1 = NSLayoutConstraint(item: self.overlayView,
                                            attribute: NSLayoutAttribute.Left,
                                            relatedBy: NSLayoutRelation.Equal,
                                            toItem: self,
                                            attribute: NSLayoutAttribute.Left,
                                            multiplier: 1.0,
                                            constant: 0.0)
        let contraint2 = NSLayoutConstraint(item: self.overlayView,
                                            attribute: NSLayoutAttribute.Right,
                                            relatedBy: NSLayoutRelation.Equal,
                                            toItem: self,
                                            attribute: NSLayoutAttribute.Right,
                                            multiplier: 1.0,
                                            constant: 0.0)
        let contraint3 = NSLayoutConstraint(item: self.overlayView,
                                            attribute: NSLayoutAttribute.Top,
                                            relatedBy: NSLayoutRelation.Equal,
                                            toItem: self,
                                            attribute: NSLayoutAttribute.Top,
                                            multiplier: 1.0,
                                            constant: 0.0)
        let contraint4 = NSLayoutConstraint(item: self.overlayView,
                                            attribute: NSLayoutAttribute.Bottom,
                                            relatedBy: NSLayoutRelation.Equal,
                                            toItem: self,
                                            attribute: NSLayoutAttribute.Bottom,
                                            multiplier: 1.0,
                                            constant: 0.0)
        self.addConstraints([contraint1,contraint2,contraint3,contraint4])
        
    }
    func configurePreviewLayer() {
        
        self.codeLayers = NSMutableDictionary()
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    }
    
    // Code Detection Delegate
    func didDetectCodes(codes: [AnyObject]) {
        
        let trandformedCodes = transformedCodesFromCodes(codes)
        
//        let lostCodes = NSMutableArray()
        
        for code in trandformedCodes {

            if let code = (code as? AVMetadataMachineReadableCodeObject) {
                
                let path = bezierPathForCorners(code.corners)
                if self.overlayView.scanRect.contains(CGPointMake(path.bounds.origin.x + path.bounds.size.width / 2, path.bounds.origin.y - path.bounds.size.height / 2)) == false {
                
                    break
                }
                let stringValue = code.stringValue
               
                if self.delegate != nil {
                    
                    self.delegate!.didDectectionCode(stringValue)
                }
                
                break
                
//                lostCodes.removeObject(stringValue)
//    
//                var layers = self.codeLayers[stringValue] as? [CAShapeLayer]
//    
//                if layers == nil {
//    
//                    layers = [makeBoundsLayer(),makeCornersLayer()]
//                    self.codeLayers[stringValue] = layers!
//                    self.previewLayer.addSublayer(layers![0])
//                    self.previewLayer.addSublayer(layers![1])
//                }
//    
//                let boundsLayer: CAShapeLayer = layers![0]
//                boundsLayer.path = bezierPathForBounds(code.bounds).CGPath
//    
//                let cornersLayer: CAShapeLayer = layers![1]
//                cornersLayer.path = bezierPathForCorners(code.corners).CGPath
//    
//                print(stringValue)
//    
//                for stringV in lostCodes {
//                    
//                    for layer in self.codeLayers[stringV as! String] as! [CALayer] {
//                        
//                        layer.removeFromSuperlayer()
//                    }
//                    
//                    self.codeLayers.removeObjectForKey(stringV)
//                }

            }
        }
        
    }
    
    // Device coordinates  ->   View coordinates
    func transformedCodesFromCodes(codes: [AnyObject]) -> [AnyObject] {
        
        var transformedCodes: [AnyObject] = Array()
        
        for code in codes as! [AVMetadataObject] {
            
            let transformedCode = self.previewLayer.transformedMetadataObjectForMetadataObject(code)
            transformedCodes.append(transformedCode)
        }
        
        return transformedCodes
    }
    
    func bezierPathForBounds(bounds: CGRect) -> UIBezierPath {
        
        return UIBezierPath(rect: bounds)
    }
    
    func bezierPathForCorners(corners: [AnyObject]) -> UIBezierPath {
        
        let path = UIBezierPath()
        
        for i in 0  ..< corners.count  {
            
            let point = pointForCorner(corners[i] as! NSDictionary)
            if i == 0 {
                
                path.moveToPoint(point)
            }
            else {
                
                path.addLineToPoint(point)
            }
        }
        
        path.closePath()
        return path
    }
    
    func pointForCorner(corner: NSDictionary) -> CGPoint {
        
        var point = CGPointZero
        
        do {
            point =  CGPointMake(corner["X"] as! CGFloat, corner["Y"] as! CGFloat)
        }

        return point
    }
    
    func makeBoundsLayer() -> CAShapeLayer {
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor(red: 0.95, green: 0.75, blue: 0.06, alpha: 1.0).CGColor
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = 4
        return shapeLayer
    }
    
    func makeCornersLayer() -> CAShapeLayer {
        
        let conersLayer = CAShapeLayer()
        conersLayer.strokeColor = UIColor(red: 0.172, green: 0.671, blue: 0.428, alpha: 1.0).CGColor
        conersLayer.fillColor = UIColor(red: 0.190, green: 0.753, blue: 0.489, alpha: 1.0).CGColor
        conersLayer.lineWidth = 2
        return conersLayer
    }
}
