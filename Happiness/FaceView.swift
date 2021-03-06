//
//  FaceVIew.swift
//  Happiness
//
//  Created by 刘述清 on 16/2/16.
//  Copyright © 2016年 刘述清. All rights reserved.
//

import UIKit

protocol FaceViewDataSource:class{
    func smilinessForDaceView(sender:FaceView)->Double?
}

@IBDesignable
class FaceView: UIView {
    
    @IBInspectable
    var lineWidth:CGFloat=3{
        didSet{
            setNeedsDisplay()
        }
    }
    @IBInspectable
    var scale:CGFloat=0.9{
        didSet{
            setNeedsDisplay()
        }
    }

    @IBInspectable
    var color:UIColor=UIColor.blueColor(){
        didSet{
           setNeedsDisplay()
        }
    }
    
    private struct Scaling {
        static let FaceRadiusToEyeRadiusRatio: CGFloat = 10
        static let FaceRadiusToEyeOffsetRatio: CGFloat = 3
        static let FaceRadiusToEyeSeparationRatio: CGFloat = 1.5
        static let FaceRadiusToMouthWidthRatio: CGFloat = 1
        static let FaceRadiusToMouthHeightRatio: CGFloat = 3
        static let FaceRadiusToMouthOffsetRatio: CGFloat = 3
    }
    
    private enum Eye { case Left, Right }
    
    private func bezierPathForEye(whichEye: Eye) -> UIBezierPath
    {
        let eyeRadius = faceRadius / Scaling.FaceRadiusToEyeRadiusRatio
        let eyeVerticalOffset = faceRadius / Scaling.FaceRadiusToEyeOffsetRatio
        let eyeHorizontalSeparation = faceRadius / Scaling.FaceRadiusToEyeSeparationRatio
        
        var eyeCenter = faceCenter
        eyeCenter.y -= eyeVerticalOffset
        switch whichEye {
        case .Left: eyeCenter.x -= eyeHorizontalSeparation / 2
        case .Right: eyeCenter.x += eyeHorizontalSeparation / 2
        }
        
        let path = UIBezierPath(
            arcCenter: eyeCenter,
            radius: eyeRadius,
            startAngle: 0,
            endAngle: CGFloat(2*M_PI),
            clockwise: true
        )
        path.lineWidth = lineWidth
        return path
    }
    
    private func bezierPathForSmile(fractionOfMaxSmile: Double) -> UIBezierPath
    {
        let mouthWidth = faceRadius / Scaling.FaceRadiusToMouthWidthRatio
        let mouthHeight = faceRadius / Scaling.FaceRadiusToMouthHeightRatio
        let mouthVerticalOffset = faceRadius / Scaling.FaceRadiusToMouthOffsetRatio
        
        let smileHeight = CGFloat(max(min(fractionOfMaxSmile, 1), -1)) * mouthHeight
        
        let start = CGPoint(x: faceCenter.x - mouthWidth / 2, y: faceCenter.y + mouthVerticalOffset)
        let end = CGPoint(x: start.x + mouthWidth, y: start.y)
        let cp1 = CGPoint(x: start.x + mouthWidth / 3, y: start.y + smileHeight)
        let cp2 = CGPoint(x: end.x - mouthWidth / 3, y: cp1.y)
        
        let path = UIBezierPath()
        path.moveToPoint(start)
        path.addCurveToPoint(end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth
        return path
    }
    
    var faceCenter:CGPoint{
        return convertPoint(center, fromView: superview)
    }
    
    var faceRadius:CGFloat{
        return min(bounds.size.width,bounds.size.height)/2*scale
    }
    
    // gesture handler for pinching
    // non-private so that Controllers can create a recognizer for pinch
    // and then add it to us if they want us to support pinching
    func scale(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1
        }
    }
    
    override func drawRect(rect: CGRect) {
        //圆脸的路径
        let facePath = UIBezierPath(
            arcCenter: faceCenter,
            radius: faceRadius,
            startAngle: 0,
            endAngle: CGFloat(2*M_PI),
            clockwise: true
        )
        //设置线条的宽度
        facePath.lineWidth = lineWidth
        //设置画笔颜色
        color.set()
        //开始画脸
        facePath.stroke()
        //改变画笔颜色
        UIColor.blueColor().set()
        bezierPathForEye(.Left).stroke()
        bezierPathForEye(.Right).stroke()
        //如果dataSource?.smilinessForDaceView(self) 整个为nil，那么smiliness就是0.5
        let smiliness = dataSource?.smilinessForDaceView(self) ?? 0.5
        let smilePath = bezierPathForSmile(smiliness)
        
        smilePath.stroke()
    }
    //我们的数据代理
    weak var dataSource:FaceViewDataSource?

}
