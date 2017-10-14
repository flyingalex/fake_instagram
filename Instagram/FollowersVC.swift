//
//  FollowersVC.swift
//  Instagram
//
//  Created by tiger on 2017/10/11.
//  Copyright © 2017年 hulin. All rights reserved.
//

import UIKit
import AVOSCloud

class FollowersVC: UITableViewController {
    var show = String()
    var user = String()
    var followerArray = [AVUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = show
        tableView.rowHeight = 80
        if show == "关注者" {
            loadFollowers()
        } else {
            loadFollowings()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return followerArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //通过indexpath获取用户所单击的单元格的用户对象
        let cell = tableView.cellForRow(at: indexPath) as! FollowersCell
        //如果用户单击单元格，或进入HomeVC或者进入GuestVC
        if cell.usernameLbl.text == AVUser.current()?.username {
            let home =  storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestArray.append(followerArray[indexPath.row])
            let guest = storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    func loadFollowers() {
        AVUser.current()?.getFollowers { (followers: [Any]?, error: Error?) in
            if error == nil && followers != nil {
                self.followerArray = followers as! [AVUser]
                // 刷新视图
                print("刷新视图")
                print(self.followerArray.count)
                self.tableView.reloadData()
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    func loadFollowings() {
        AVUser.current()?.getFollowees { (followings: [Any]?, error: Error?) in
            if error == nil && followings != nil {
                self.followerArray = followings as! [AVUser]
                // 刷新视图
                self.tableView.reloadData()
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FollowersCell
        cell.usernameLbl.text = followerArray[indexPath.row].username
        let ava = followerArray[indexPath.row].object(forKey: "ava") as! AVFile
        ava.getDataInBackground({ (data: Data?, error: Error?) in
            if error == nil {
                cell.avaImg.image = UIImage(data: data!)
            } else {
                print(error?.localizedDescription)
            }
        })
        
        // 利用按钮外观区分当前用户关注或未关注状态
        let query = followerArray[indexPath.row].followeeQuery()
        query.whereKey("user", equalTo: AVUser.current())
        query.whereKey("followee", equalTo: followerArray[indexPath.row])
        query.countObjectsInBackground({ (count: Int, error: Error?) in
            // 根据数量设置按钮的风格
            if error == nil {
                if count == 0 {
                    cell.followBtn.setTitle("关注", for: .normal)
                    cell.followBtn.backgroundColor = .lightGray
                } else {
                    cell.followBtn.setTitle("√已关注", for: .normal)
                    cell.followBtn.backgroundColor = .green
                }
            }
        })
        
        // 将关注人对象传递给FollowersCell对象
        cell.user = followerArray[indexPath.row]
        
        // 为当前用户隐藏关注按钮
        if cell.usernameLbl.text == AVUser.current()?.username {
            cell.followBtn.isHidden = true
        }
    
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.width / 4
    }
}
