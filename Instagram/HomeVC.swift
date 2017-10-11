//
//  HomeVC.swift
//  Instagram
//
//  Created by tiger on 2017/10/10.
//  Copyright © 2017年 hulin. All rights reserved.
//

import UIKit
import AVOSCloud

class HomeVC: UICollectionViewController {
    // 刷新控件
    var refresher: UIRefreshControl!
    // 每页载入帖子的数量
    var page: Int = 12
    var puuidArray = [String]()
    var picArray = [AVFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 导航栏中的title设置
        self.navigationItem.title = AVUser.current()?.username?.uppercased()
        
        // 设置refresher控件到集合视图之中
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        loadPosts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func refresh() {
        collectionView?.reloadData()
        refresher.endRefreshing()
    }
    
    func loadPosts() {
        let query = AVQuery(className: "Posts")
        query.whereKey("username", equalTo: AVUser.current()?.username)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        print("puuidArray.count")
        print(puuidArray.count)
        return puuidArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // 获取headerview对象
        let header = self.collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        
        // header相关数据
        header.fullnameLbl.text = (AVUser.current()?.object(forKey: "fullname") as? String)?.uppercased()
        header.webTxt.text = AVUser.current()?.object(forKey: "web") as? String
        header.webTxt.sizeToFit()
        header.bioLbl.text = AVUser.current()?.object(forKey: "bio") as? String
        header.bioLbl.sizeToFit()
        let avaQuery = AVUser.current()?.object(forKey: "ava") as! AVFile
        avaQuery.getDataInBackground { (data: Data?, error: Error?) in
            if data == nil {
                print(error?.localizedDescription)
            } else {
                header.avaImg.image = UIImage(data: data!)
            }
        }
        
        // 帖子总数
        let currentUser: AVUser = (AVUser.current())!
        let postsQuery = AVQuery(className: "Posts")
        postsQuery.whereKey("username", equalTo: currentUser.username)
        postsQuery.countObjectsInBackground( { (count: Int, error: Error?) in
            if error == nil {
                header.posts.text = String(count)
            }
        })
        
        // 关注者总数
        let followersQuery = AVQuery(className: "_Follower")
        followersQuery.whereKey("user", equalTo: currentUser)
        followersQuery.countObjectsInBackground{ (count: Int, error: Error?) in
            if error == nil {
                header.followers.text = String(count)
            }
        }
        
        // 关注数
        let followeesQuery = AVQuery(className: "_Followee")
        followeesQuery.whereKey("user", equalTo: currentUser)
        followeesQuery.countObjectsInBackground{ (count: Int, error: Error?) in
            if error == nil {
                header.followings.text = String(count)
            }
        }
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 从集合视图的可复用队列中获取单元格对象
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PictureCell
        picArray[indexPath.row].getDataInBackground({ (data: Data?, error: Error?) in
            if error == nil {
                cell.picImg.image = UIImage(data: data!)
            } else {
                print(error?.localizedDescription)
            }
        })
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
