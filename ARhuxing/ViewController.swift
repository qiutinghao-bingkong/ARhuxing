//
//  ViewController.swift
//  ARhuxing
//
//  Created by EJU on 2018/7/25.
//  Copyright © 2018年 EJU. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var scene: SCNScene!
    
    // 屏幕尺寸
    var clientWidth:CGFloat = 1
    var clientHeight:CGFloat = 1
    
    // 房间展示ui
    var roomView:RoomView!
    
    // planes
    var planes:[UUID:Plane] = [:]
    // balls
    var balls:[SCNNode] = []
    // lines
    var lines:[SCNNode] = []
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // 获取屏幕尺寸
        clientWidth = UIScreen.main.bounds.size.width
        clientHeight = UIScreen.main.bounds.size.height
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        
        // Create a new scene
        scene = SCNScene()
        sceneView.scene = scene
        
        // touch事件
        
       
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(oneTap(recognizer:)))
        tapGes.delegate = self
        sceneView.addGestureRecognizer(tapGes)
        
        // 添加多边形展示平面图
        let roomViewWidth = clientWidth/2.7
        let roomViewHeight = roomViewWidth
        
        roomView = RoomView(frame: CGRect(x: 10, y: clientHeight - roomViewHeight - 20, width: roomViewWidth, height: roomViewHeight))
        sceneView.addSubview(roomView)
        
        // 按钮宽度
        let buttonWidth = clientWidth/6
        let buttonHeight = clientHeight/16
        
        // 添加撤销按钮
        let undoBtn = createButton("撤销", CGRect(x: clientWidth - buttonWidth*2 - 40, y: clientHeight - buttonHeight - 20, width: buttonWidth, height: buttonHeight))
        undoBtn.addTarget(self, action: #selector(undo), for: .touchDown)
        sceneView.addSubview(undoBtn)
        
        // 添加清空按钮
        let clearBtn = createButton("清空", CGRect(x: clientWidth - buttonWidth - 20, y: clientHeight - buttonHeight - 20, width: buttonWidth, height: buttonHeight))
        clearBtn.addTarget(self, action: #selector(clear), for: .touchDown)
        sceneView.addSubview(clearBtn)
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    
    
    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//        let node = SCNNode()
//
//        return node
//    }
    
    
    
    
    // 添加平面
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)
    {
        if let planeAnchor = anchor as? ARPlaneAnchor
        {
            let plane = Plane(planeAnchor)
            planes[planeAnchor.identifier] = plane

            node.addChildNode(plane)
            
            // 只保留最下面的一个平面
            if planes.count > 1
            {
                var minY:Float = 99999999
                var floor:Plane!
                for (_, value) in planes
                {
                    if let y = value.parent?.position.y
                    {
                        if y <= minY
                        {
                            floor = value
                            minY = y
                        }
                    }
                }
                for (_, value) in planes
                {
                    if value != floor
                    {
                        value.removeFromParentNode()
                        planes.removeValue(forKey: value.id)
                    }
                }
            }
        }
    }
    
    
    
    
    // 更新平面
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor)
    {
        let plane = planes[anchor.identifier]
        if plane != nil
        {
            plane?.update(anchor: anchor as! ARPlaneAnchor)
        }
    }
    
    
    
    
    // 移除平面
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor)
    {
        planes.removeValue(forKey: anchor.identifier)
    }
    
    
    
    
    // 更新
    func update(_ alert:Bool = true)
    {
        // 更新连接线
        updateLine(alert)
        
        // 更新矢量图
        var points:[SCNVector3] = []
        for ball in balls
        {
            points.append(ball.position)
        }
        roomView.update(points: points)
    }
    
    
    
    // 连线
    func updateLine(_ alert:Bool)
    {
        //先把连线清空
        for line in lines
        {
            line.removeFromParentNode()
        }
        lines.removeAll()
        
        if balls.count < 2
        {
            return
        }
        
        //建立连接线
        var ball1:SCNNode
        var ball2:SCNNode
        for i in 0..<balls.count
        {
            if i == balls.count - 1
            {
                break
            }
            
            ball1 = balls[i]
            ball2 = balls[i + 1]
            
            let p1 = SCNVector3ToGLKVector3(ball1.position)
            let p2 = SCNVector3ToGLKVector3(ball2.position)
            // 计算中心点
            var center = GLKVector3Add(p1, p2)
            center = GLKVector3DivideScalar(center, 2.0)
            // 计算距离
            let d = GLKVector3Distance(p1, p2)
            // 计算角度
            let angleVector3 = GLKVector3Normalize(GLKVector3Subtract(p1, p2))
            let yAxis = GLKVector3Make(0, 1, 0)
            // 旋转轴
            let rotateAxis = GLKVector3DivideScalar(GLKVector3Add(angleVector3, yAxis), 2.0)
            
            let lineGeom = SCNCylinder(radius: 0.002, height: CGFloat(d))
            let line = SCNNode(geometry: lineGeom)
            // 旋转
            line.transform = SCNMatrix4MakeRotation(Float(Double.pi), rotateAxis.x, rotateAxis.y, rotateAxis.z)
            // 坐标
            line.position = SCNVector3FromGLKVector3(center)
            scene.rootNode.addChildNode(line)
            
            lines.append(line)
            
            if alert == true && i == balls.count - 2
            {
                let alert = UIAlertController(title: "距离", message: String(Int(d*1000)) + "豪米", preferredStyle: .alert)
                let action = UIAlertAction(title: "确定", style: .default)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    
    
    // 撤销
    @objc func undo()
    {
        if let last = balls.popLast()
        {
            last.removeFromParentNode()
            
            update(false)
        }
    }
    
    
    
    
    // 清空
    @objc func clear()
    {
        for line in lines
        {
            line.removeFromParentNode()
        }
        lines.removeAll()
        
        for ball in balls
        {
            ball.removeFromParentNode()
        }
        balls.removeAll()
        
        // 清空矢量图面板
        roomView.clear()
    }
    
    
    
    // 点击
    @objc func oneTap(recognizer: UITapGestureRecognizer)
    {
        // 点击的坐标点
        let tapPoint = recognizer.location(in: sceneView)
//        let type = planes.count > 1 ? ARHitTestResult.ResultType.existingPlaneUsingExtent : ARHitTestResult.ResultType.existingPlane
        let results = sceneView.hitTest(tapPoint, types: [.existingPlane])
        
        // 在结果中找到最下面的点（y轴最小）
        var minY:Float = 99999999
        var targetResult:ARHitTestResult? = nil
        for result in results
        {
            let y = result.worldTransform.columns.3.y
            if y <= minY
            {
                targetResult = result
                minY = y
            }
        }
        
        if targetResult != nil
        {
            let point = targetResult!.worldTransform.columns.3
            let pos = SCNVector3Make(point.x, point.y, point.z)
            
            let ballGeom = SCNSphere(radius: 0.02)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.red
            material.ambient.contents = UIColor.init(white: 0.1, alpha: 1)
            material.locksAmbientWithDiffuse = false
            material.lightingModel = .lambert
            ballGeom.materials = [material]
            let ball = SCNNode(geometry: ballGeom)
            ball.position = pos
            scene.rootNode.addChildNode(ball)
            
            balls.append(ball)
            
            // 更新
            update()
        }
    }
    
    
    
    
    //创建按钮
    func createButton(_ label:String, _ frame:CGRect)->ColorButton
    {
        let btn = ColorButton(frame)
        btn.setLabel(label)
        
        return btn
    }
}
