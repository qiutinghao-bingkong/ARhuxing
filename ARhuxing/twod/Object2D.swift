//
//  Object2D.swift
//  ARhuxing
//
//  Created by EJU on 2018/8/9.
//  Copyright © 2018年 EJU. All rights reserved.
//

import UIKit
import SceneKit

public class Object2D: UIView
{
    public var points: [GLKVector2] = []
    
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
}
