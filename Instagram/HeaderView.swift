//
//  HeaderView.swift
//  Instagram
//
//  Created by tiger on 2017/10/10.
//  Copyright © 2017年 hulin. All rights reserved.
//

import UIKit
import AVOSCloud

class HeaderView: UICollectionReusableView {
    @IBOutlet weak var avaImg: UIImageView! // 用户头像
    @IBOutlet weak var fullnameLbl: UILabel! // 用户名称
    @IBOutlet weak var webTxt: UITextView! // 个人主页地址
    @IBOutlet weak var bioLbl: UILabel! // 个人简介
    @IBOutlet weak var posts: UILabel! // 帖子数
    @IBOutlet weak var followers: UILabel! // 关注者数
    @IBOutlet weak var followings: UILabel! // 关注数
    @IBOutlet weak var postTitle: UILabel! // 帖子的Label
    @IBOutlet weak var followersTitle: UILabel! // 关注者的Label
    @IBOutlet weak var followingsTitle: UILabel! // 关注的Label
    @IBOutlet weak var button: UIButton! // 编辑个人主页按钮

    @IBAction func followBtn_clicked(_ sender: Any) {
        let title = button.title(for: .normal)
        // 获取当前访客对象
        print("获取当前访客对象")
        let user = guestArray.last
        if title == "关 注" {
            guard let user = user else { return }
            AVUser.current()?.follow(user.objectId!, andCallback: { (success: Bool, error: Error?) in
                if success {
                    self.button.setTitle("√已关注", for: .normal)
                    self.button.backgroundColor = .green
                } else {
                    print(error?.localizedDescription)
                }
            })
        } else {
            guard let user = user else { return }
            AVUser.current()?.unfollow(user.objectId!, andCallback: { (success: Bool, error: Error?) in
                if success {
                    self.button.setTitle("关 注", for: .normal)
                    self.button.backgroundColor = .lightGray
                } else {
                    print(error?.localizedDescription)
                }
            })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 对齐
        let width = UIScreen.main.bounds.width
        // 对头像进行布局
        avaImg.frame = CGRect(x: width / 16, y: width / 16, width: width / 4, height: width / 4)
        // 对三个统计数据进行布局
        posts.frame = CGRect(x: width / 2.5, y: avaImg.frame.origin.y, width: 50, height: 30)
        followers.frame = CGRect(x: width / 1.6, y: avaImg.frame.origin.y, width: 50, height: 30)
        followings.frame = CGRect(x: width / 1.2, y: avaImg.frame.origin.y, width: 50, height: 30)
        
        // 设置三个统计数据Title的布局
        postTitle.center = CGPoint(x: posts.center.x, y: posts.center.y + 20)
        followersTitle.center = CGPoint(x: followers.center.x, y: followers.center.y + 20)
        followingsTitle.center = CGPoint(x: followings.center.x, y: followings.center.y + 20)
        // 设置按钮的布局
        button.frame = CGRect(x: postTitle.frame.origin.x, y: postTitle.center.y + 20, width: width - postTitle.frame.origin.x - 10, height: 30)
        fullnameLbl.frame = CGRect(x: avaImg.frame.origin.x, y: avaImg.frame.origin.y + avaImg.frame.height, width: width - 30, height: 30)
        webTxt.frame = CGRect(x: avaImg.frame.origin.x - 5, y: fullnameLbl.frame.origin.y + 30, width: width - 30, height: 30)
        bioLbl.frame = CGRect(x: avaImg.frame.origin.x, y: webTxt.frame.origin.y + 30, width: width - 30, height: 30)
    }
}
