//
//  GuestVC.swift
//  Instagram
//
//  Created by tiger on 2017/10/12.
//  Copyright © 2017年 hulin. All rights reserved.
//

import UIKit
import AVOSCloud

var guestArray = [AVUser]()
class GuestVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    // 从云端获取数据并存储到数组
    var puuidArray = [String]()
    var picArray = [AVFile]()
    // 界面对象
    var refresher: UIRefreshControl!
    var page: Int = 12    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 允许垂直的拉拽刷新操作
        self.collectionView?.alwaysBounceVertical = true
        // 导航栏的顶部信息
        self.navigationItem.title = guestArray.last?.username
        // 定义导航栏中新的返回按钮
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector( back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        // 实现向右划动返回
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector( back(_:)))
        backSwipe.direction = .right
        self.view.addGestureRecognizer(backSwipe)
        
        // 安装refresh控件
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.collectionView?.addSubview(refresher)
        
        loadPosts()
        
        //设置背景颜色
        self.collectionView?.backgroundColor = .white
    }
    
    
    // 载入访客帖子
    func loadPosts() {
        let query = AVQuery(className: "Posts")
        query.whereKey("username", equalTo: guestArray.last)
        query.limit = page
        query.findObjectsInBackground({ (objects: [Any]?, error: Error?)  in
            // 查询成功
            if error == nil {
                // 清空两个数组
                self.puuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                for object in objects! {
                    self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                    self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                }
                self.refresh()
            } else {
                print(error?.localizedDescription)
            }
        })
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 定义cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PictureCell
        // 从云端载入帖子
        picArray[indexPath.row].getDataInBackground({ (data: Data?, error: Error?) in
            if error == nil {
                cell.picImg.image = UIImage(data: data!)
            } else {
                print(error?.localizedDescription)
            }
        })
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // 获取headerview对象
        let header = self.collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        //第一步，载入访客的基本数据信息
        let infoQuery = AVQuery(className: "_User")
        infoQuery.whereKey("username", equalTo: guestArray.last?.username)
        infoQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?)  in
            if error == nil {
                // 判断是否有用户数据
                guard let objects = objects, objects.count > 0 else { return }
                //找到用户的相关信息
                for object in objects {
                    // header相关数据
                    header.fullnameLbl.text = ((object as AnyObject).object(forKey: "fullname") as? String)?.uppercased()
                    header.webTxt.text = (object as AnyObject).object(forKey: "web") as? String
                    header.webTxt.sizeToFit()
                    header.bioLbl.text = (object as AnyObject).object(forKey: "bio") as? String
                    header.bioLbl.sizeToFit()
                    let avaFile = (object as AnyObject).object(forKey: "ava") as! AVFile
                    avaFile.getDataInBackground { (data: Data?, error: Error?) in
                        header.avaImg.image = UIImage(data: data!)
                    }
                }
            } else {
                print(error?.localizedDescription)
            }
        })
        
        // 第2步. 设置当前用户和访客之间的关注状态
        let followeeQuery = AVUser.current()?.followeeQuery()
        followeeQuery?.whereKey("user", equalTo: AVUser.current())
        followeeQuery?.whereKey("followee", equalTo: guestArray.last)
        followeeQuery?.countObjectsInBackground({ (count: Int, error: Error?) in
            guard error == nil else { print( error?.localizedDescription); return }
            if count == 0 {
                header.button.setTitle("关 注", for: .normal)
                header.button.backgroundColor = .lightGray
                
            } else {
                header.button.setTitle("√已关注", for: .normal)
                header.button.backgroundColor = .green
            }
        })
        
        // 第3步.计算统计数据
        // 访客的帖子数
        let posts = AVQuery(className: "Posts")
        posts.whereKey("username", equalTo: guestArray.last?.username)
        posts.countObjectsInBackground({ (count: Int, error: Error?) in
            if error == nil {
                header.posts.text = "\(count)"
            } else {
                print(error?.localizedDescription) }
        })
        // 访客的关注者数
        let followers = AVUser.followerQuery((guestArray.last?.objectId)!)
        followers.countObjectsInBackground({ (count: Int, error: Error?) in
            if error == nil {
                header.followers.text = "\(count)"
                
            } else {
                print(error?.localizedDescription)
            }
        })
        // 访客的关注数
        let followings = AVUser.followeeQuery((guestArray.last?.objectId)!)
        followings.countObjectsInBackground({ (count: Int, error: Error?) in
            if error == nil {
                header.followings.text = "\(count)"
            } else {
                print(error?.localizedDescription)
            }
        })
        
        // 第四步，实现统计数据的单击手势
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(postsTap(_:)))
        postsTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        //单击关注者数
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(followersTap(_:)))
        followersTap.numberOfTapsRequired = 1
        header.followers.isUserInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        //单击关注数
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(followingsTap(_:)))
        followingsTap.numberOfTapsRequired = 1
        header.followings.isUserInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)
        return header
    }
    
    @objc func postsTap(_ recognizer: UITapGestureRecognizer) {
        if !picArray.isEmpty {
            print("单击帖子数")
            let index = IndexPath(row: 0, section: 0)
            self.collectionView?.scrollToItem(at: index, at: UICollectionViewScrollPosition.top, animated: true)
        }
    }
    
    @objc func followersTap(_ recognizer: UITapGestureRecognizer) {
        // 从故事面板中载入followersVC视图
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        followers.user = guestArray.last!.username!
        followers.show = "关 注 者"
        self.navigationController?.pushViewController(followers, animated: true)
        
    }
    
    @objc func followingsTap(_ recognizer: UITapGestureRecognizer) {
        // 从故事面板中载入followersVC视图
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        followings.user = guestArray.last!.username!
        followings.show = "关 注"
        self.navigationController?.pushViewController(followings, animated: true)
    }
    
    @objc func refresh() {
        self.collectionView?.reloadData()
        self.refresher.endRefreshing()
    }
    
    @objc func back(_: UIBarButtonItem) {
        // 返回到之前的控制器
        self.navigationController?.popViewController(animated: true)
        // 从guestArray中移除最后一个AVUser
        if !guestArray.isEmpty {
            guestArray.removeLast()
        }
    }
}
