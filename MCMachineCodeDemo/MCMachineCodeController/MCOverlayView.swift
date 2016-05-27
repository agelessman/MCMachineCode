//
//  MCOverlayView.swift
//  MCMachineCodeDemo
//
//  Created by 马超 on 16/5/25.
//  Copyright © 2016年 qq 714080794. All rights reserved.
//

import UIKit

enum LineType {
    case None      // none
    case Default   // line color transition
    case LineScan  // line
    case Grid      // grid style
}


enum MoveType {
    case None      // none
    case Default   // up to down
    case UpAndDown  // up and down
}

var w: CGFloat {
    get {
        let max = screenw < screenh ? screenw : screenh
        let margin: CGFloat = 60
        return max - margin * 2
    }
}
let h: CGFloat = w
let screenw: CGFloat = UIScreen.mainScreen().bounds.size.width
let screenh: CGFloat = UIScreen.mainScreen().bounds.size.height
let moveSpeed: CGFloat = 1.0

class MCOverlayView: UIView {
    
    var scanRect: CGRect {
        get {
            return CGRectMake((screenw - w) / 2, (screenw - h) / 2, w, h)
        }
    }
    
    private var lineType: LineType = LineType.Default
    private var moveType: MoveType = MoveType.Default
    private var lineColor: UIColor = UIColor.greenColor()
    private var tempY: CGFloat = 0
    private var lineView: UIView?
    private var displayLink: CADisplayLink?
    private var moveToEdge: Bool = false
    
    //MARK: - init
    init(lineType: LineType , moveType: MoveType, lineColor: UIColor) {
        
        super.init(frame: CGRectZero)
        self.backgroundColor = UIColor.clearColor()
        
        self.lineType = lineType
        self.moveType = moveType
        self.lineColor = lineColor
        
        setupLineView()
        startMoving()
    }

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - public method
    /**
     start to scanning
     */
    func startMoving() {
        
        switch self.lineType {
        case .Default:
            if self.displayLink == nil {
                
                self.displayLink = CADisplayLink(target: self, selector: #selector(MCOverlayView.beginLineAnimation))
                self.displayLink!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
            }
        case .LineScan:
            
            beginLineAnimation()
            
        case .Grid:
            
            beginGridAnimation()
            
        default:
            break
        }
    }
    
    func stopMoving() {
        
        if self.displayLink != nil {
            
            self.displayLink?.invalidate()
            self.displayLink = nil
        }
    }
    
    /**
      begin the line animation
     */
    func beginLineAnimation() {
        
        switch self.lineType {
        case .Default:
            
            var frame = self.lineView!.frame
            self.moveToEdge ? (frame.origin.y -= moveSpeed) : (frame.origin.y += moveSpeed)
            self.lineView!.frame = frame
            
            // scan line shadow
            self.lineView?.layer.shadowColor = self.lineView?.backgroundColor?.CGColor
            self.lineView?.layer.shadowOpacity = 1
            self.lineView?.layer.shadowOffset = CGSizeMake(0, -3)
            
            switch self.moveType {
            case .Default:
                
                // reset lineView frame
                if self.lineView!.frame.origin.y - self.tempY >= h {
                    
                    resetLineViewFrameBack()
                }
             
            case .UpAndDown:
                
                if self.lineView!.frame.origin.y - self.tempY >= h {
                    
                    self.moveToEdge = !self.moveToEdge
                }
                else if self.lineView!.frame.origin.y == self.tempY {
                    
                    self.moveToEdge = !self.moveToEdge
                }
            default:
                break
            }
         
        case .LineScan:
            
            lineViewMovedWithLineType(self.lineType)
            
        case .Grid:
            
            break
            
        default:
            break
        }
    }
    
    func lineViewMovedWithLineType(lineType: LineType) {
        
        UIView.animateWithDuration(2.0, animations: {
            
            var frame = self.lineView!.frame
            frame.origin.y += h - 2
            self.lineView!.frame = frame
            
            }) { (finished) in
                
                if self.moveType == .Default {
                    
                    self.resetLineViewFrameBack()
                    self.lineViewMovedWithLineType(lineType)
                }
                else {
                    
                    UIView.animateWithDuration(2.0, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { 
                        
                            self.resetLineViewFrameBack()
                        
                        }, completion: { (finished) in
                            
                             self.lineViewMovedWithLineType(lineType)
                    })
                }
        }
    }
    /**
     begin the grid animation
     */
    func beginGridAnimation() {
        
        let imageView = self.lineView?.subviews.first as? UIImageView
        if let imageView = imageView {
            
            UIView.animateWithDuration(1.5, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                
                imageView.transform = CGAffineTransformTranslate(imageView.transform, 0, h)
                
                }, completion: { (finished) in
                    
                    imageView.frame = CGRectMake(0, -h, self.lineView!.frame.size.width, self.lineView!.frame.size.height)
                    self.startMoving()
            })
     
        }
    }
    
    /**
     reset lineView frame back
     */
    func resetLineViewFrameBack() {
        
        var frame = self.lineView!.frame
        frame.origin.y = tempY
        self.lineView!.frame = frame
    }
    //MARK: - setup view
    func setupLineView() {
        
        if self.moveType == .None { return }
        
        self.lineView = UIView(frame: CGRectMake((screenw - w) * 0.5, screenh / 3.5, w, 2))
        self.addSubview(self.lineView!)
        
        if self.lineType == .Default {
            
            self.lineView!.backgroundColor = self.lineColor
            self.tempY = self.lineView!.frame.origin.y
        }
        
        if self.lineType == .LineScan {
            
            self.lineView?.backgroundColor = UIColor.clearColor()
            self.tempY = self.lineView!.frame.origin.y
            
            let imageView = UIImageView(image: UIImage(named: "line@2x"))
            imageView.frame = CGRectMake(0, 0, self.lineView!.frame.size.width, self.lineView!.frame.size.height)
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            self.lineView!.addSubview(imageView)
        }
        
        if self.lineType == .Grid {
            
            self.lineView!.clipsToBounds = true
            
            // reset height
            var frame = self.lineView!.frame
            frame.size.height = h
            self.lineView!.frame = frame
            
            let imageView = UIImageView(image: UIImage(named: "scan_net@2x"))
            imageView.frame = CGRectMake(0, -h, self.lineView!.frame.size.width, self.lineView!.frame.size.height)
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            self.lineView!.addSubview(imageView)
        }
        
        
        
    }
    
    //MARK: - override drawRect method
    override func drawRect(rect: CGRect) {
       
        let originx: CGFloat = (rect.size.width - w ) / 2
        let originy: CGFloat = rect.size.height / 3.5
        let maggin: CGFloat = 15
        
        let cornerColor: UIColor = UIColor(red: 0/255.0, green: 153/255.0, blue: 204/255.0, alpha: 1.0)
        let frameColor: UIColor = UIColor.whiteColor()
        
        let ctx = UIGraphicsGetCurrentContext()
        
        CGContextSetRGBFillColor(ctx, 40/255.0, 40/255.0, 40/255.0, 0.5);
        CGContextFillRect(ctx, rect);
        
        // framePath
        let framePath: UIBezierPath = UIBezierPath(rect: CGRectMake(originx, originy, w, h))
        CGContextAddPath(ctx, framePath.CGPath)
        CGContextSetStrokeColorWithColor(ctx, frameColor.CGColor)
        CGContextSetLineWidth(ctx, 0.6)
        CGContextStrokePath(ctx)
        
        // set scan rect
        CGContextClearRect(ctx, CGRectMake(originx, originy, w, h))
        
        
        
        // left top corner
        let leftTopPath = UIBezierPath()
        leftTopPath.moveToPoint(CGPointMake(originx, originy + maggin))
        leftTopPath.addLineToPoint(CGPointMake(originx, originy))
        leftTopPath.addLineToPoint(CGPointMake(originx + maggin, originy))
        CGContextAddPath(ctx, leftTopPath.CGPath)
        CGContextSetStrokeColorWithColor(ctx, cornerColor.CGColor)
        CGContextSetLineWidth(ctx, 1.6)
        CGContextStrokePath(ctx)
        
        // right top corner
        let rightTopPath = UIBezierPath()
        rightTopPath.moveToPoint(CGPointMake(originx + w - maggin, originy))
        rightTopPath.addLineToPoint(CGPointMake(originx + w, originy))
        rightTopPath.addLineToPoint(CGPointMake(originx + w, originy + maggin))
        CGContextAddPath(ctx, rightTopPath.CGPath)
        CGContextSetStrokeColorWithColor(ctx, cornerColor.CGColor)
        CGContextSetLineWidth(ctx, 1.6)
        CGContextStrokePath(ctx)
        
        // left bottom corner
        let leftBottomPath = UIBezierPath()
        leftBottomPath.moveToPoint(CGPointMake(originx, originy + h - maggin))
        leftBottomPath.addLineToPoint(CGPointMake(originx , originy + h))
        leftBottomPath.addLineToPoint(CGPointMake(originx + maggin, originy + h))
        CGContextAddPath(ctx, leftBottomPath.CGPath)
        CGContextSetStrokeColorWithColor(ctx, cornerColor.CGColor)
        CGContextSetLineWidth(ctx, 1.6)
        CGContextStrokePath(ctx)
        
        // right bottom corner
        let rightBottomPath = UIBezierPath()
        rightBottomPath.moveToPoint(CGPointMake(originx + w , originy + h - maggin))
        rightBottomPath.addLineToPoint(CGPointMake(originx + w, originy + h))
        rightBottomPath.addLineToPoint(CGPointMake(originx + w - maggin, originy + h))
        CGContextAddPath(ctx, rightBottomPath.CGPath)
        CGContextSetStrokeColorWithColor(ctx, cornerColor.CGColor)
        CGContextSetLineWidth(ctx, 1.6)
        CGContextStrokePath(ctx)
        
        // draw title
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Center
        
        let attr = [NSParagraphStyleAttributeName: paragraphStyle ,
                    NSFontAttributeName: UIFont.systemFontOfSize(12.0) ,
                    NSForegroundColorAttributeName: UIColor.whiteColor()]
        let title = "将二维码/条码放入框内, 即可自动扫描"
            
        let size = (title as NSString).sizeWithAttributes(attr)
        
        let r = CGRectMake(0, originy + h + 15, rect.size.width, size.height)
        (title as NSString).drawInRect(r, withAttributes: attr)
        
        

    }
}
