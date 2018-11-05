//
//  HuxingView.swift
//  ARhuxing
//
//  Created by EJU on 2018/8/16.
//  Copyright © 2018年 EJU. All rights reserved.
//

import UIKit
import WebKit

public class HuxingView: UIViewController
{
    private var webView:WKWebView!
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    public func open()
    {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.load(URLRequest(url: URL(string: "")!))
        view.addSubview(webView)
    }
    
    
    
    public func close()
    {
        
    }
}
