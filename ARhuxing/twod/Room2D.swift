//
//  Room2D.swift
//  ARhuxing
//
//  Created by EJU on 2018/8/9.
//  Copyright © 2018年 EJU. All rights reserved.
//

import UIKit
import SceneKit

public class Room2D: Object2D
{
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
    }
    
    
    public func update(points: [GLKVector2])
    {
        self.points = points
        self.setNeedsDisplay()
    }
    
    
    override public func draw(_ rect: CGRect)
    {
        if points.count <= 1
        {
            return
        }
        
        var p:GLKVector2
        
        // 自身尺寸
        let ww:CGFloat = self.frame.width
        let hh:CGFloat = self.frame.height
        
        // 自身中心点
        let canvasCenter = GLKVector2Make(Float(ww)/2, Float(hh)/2)
        
        // 找到最长的一条线，计算缩放比
        // 计算bounds
        var left:Float = 999999999
        var top:Float = 999999999
        var right:Float = -999999999
        var bottom:Float = -999999999
        var maxLength:Float = 0
        for i in 0..<points.count
        {
            p = points[i]
            if p.x < left
            {
                left = p.x
            }
            if p.x > right
            {
                right = p.x
            }
            if p.y < top
            {
                top = p.y
            }
            if p.y > bottom
            {
                bottom = p.y
            }
        }
        maxLength = max(Float(abs(right - left)), Float(abs(bottom - top)))
        let scale = Float(ww) / maxLength / 1.5
        let bounds = CGRect(x:CGFloat(left*scale), y:CGFloat(top*scale), width:CGFloat(abs(right - left)*scale), height:CGFloat(abs(bottom - top)*scale))
        let boundsCenter = GLKVector2Make(Float(bounds.midX), Float(bounds.midY))
        
        // 计算offset
        let offset:GLKVector2 = GLKVector2Subtract(canvasCenter, boundsCenter)
        
        // 线条路径
        let path = UIBezierPath()
        for i in 0..<points.count
        {
            p = points[i]
            var finalPoint = GLKVector2MultiplyScalar(p, scale)
            finalPoint = GLKVector2Add(finalPoint, offset)
            if i == 0
            {
                path.move(to: CGPoint(x: CGFloat(finalPoint.x), y: CGFloat(finalPoint.y)))
            }
            else
            {
                path.addLine(to: CGPoint(x: CGFloat(finalPoint.x), y: CGFloat(finalPoint.y)))
            }
        }
        
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(2)
        context?.closePath()
        context?.addPath(path.cgPath)
        
//        UIColor.black.setStroke()
        context?.drawPath(using: .stroke)
    }
}
