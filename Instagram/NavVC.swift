//
//  NavVC.swift
//  Instagram
//
//  Created by tiger on 2017/10/22.
//  Copyright © 2017年 hulin. All rights reserved.
//

import UIKit

class NavVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 导航栏中title的颜色设置
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        // 导航栏背景色
        self.navigationBar.barTintColor = UIColor(red: 18.0 / 255.0, green: 86.0 / 255.0, blue: 136.0 / 255.0, alpha: 1)
        // 不允许透明
        self.navigationBar.isTranslucent = false
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
