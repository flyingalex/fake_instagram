//
//  PostVC.swift
//  Instagram
//
//  Created by tiger on 2017/10/22.
//  Copyright © 2017年 hulin. All rights reserved.
//

import UIKit
import  AVOSCloud
var postuuid = [String]()

class PostVC: UITableViewController {
    // 从服务器获取数据后写入到相应的数组中
    var avaArray = [AVFile]()
    var usernameArray = [String]()
    var dateArray = [Date]()
    var picArray = [AVFile]()
    var puuidArray = [String]()
    var titleArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 定义返回的按钮
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        // 向右划动屏幕返回到之前的控制器
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        backSwipe.direction = .right
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(backSwipe)
        
        // 动态单元格高度设置
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 550
        
        let postQuery = AVQuery(className: "Posts")
        postQuery.whereKey("puuid", equalTo: postuuid.last)
        postQuery.findObjectsInBackground({ (objects:[Any]?, error: Error?) in
            //清空数组
            self.avaArray.removeAll(keepingCapacity: false)
            self.usernameArray.removeAll(keepingCapacity: false)
            self.dateArray.removeAll(keepingCapacity: false)
            self.picArray.removeAll(keepingCapacity: false)
            self.puuidArray.removeAll(keepingCapacity: false)
            self.titleArray.removeAll(keepingCapacity: false)
            
            for object in objects! {
                self.avaArray.append((object as AnyObject).value(forKey: "ava") as! AVFile)
                self.usernameArray.append((object as AnyObject).value(forKey: "username") as! String)
                self.dateArray.append((object as AnyObject).createdAt as! Date)
                self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                self.titleArray.append((object as AnyObject).value(forKey: "title") as! String)
            }
            self.tableView.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 从表格视图的可复用队列中获取单元格对象
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        
        // 通过数组信息关联单元格中的UI控件
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: .normal)
        cell.puuidLbl.text = puuidArray[indexPath.row]
        cell.titleLbl.text = titleArray[indexPath.row]
        cell.titleLbl.sizeToFit()
        cell.usernameBtn.sizeToFit()
        
        // 配置用户头像
        avaArray[indexPath.row].getDataInBackground({ (data: Data?, error: Error?) in
            cell.avaImg.image = UIImage(data: data!)
        })
        
        // 配置帖子照片
        picArray[indexPath.row].getDataInBackground({ (data: Data?, error: Error?) in
            cell.picImg.image = UIImage(data: data!)
        })
        
        // 帖子的发布时间和当前时间的间隔差
        let from = dateArray[indexPath.row]
        let now = Date()
        let components: Set<Calendar.Component> = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = Calendar.current.dateComponents(components, from: from, to: now)
        if difference.second! <= 0 {
            cell.dateLbl.text = "现在"
        }
        
        if difference.second! > 0 && difference.minute! <= 0 {
            cell.dateLbl.text = "\(difference.second!)秒."
        }
        
        if difference.minute! > 0 && difference.hour! <= 0 {
            cell.dateLbl.text = "\(difference.minute!)分."
        }
        
        if difference.hour! > 0 && difference.day! <= 0 {
            cell.dateLbl.text = "\(difference.hour!)时."
        }
        
        if difference.day! > 0 && difference.weekOfMonth! <= 0 {
            cell.dateLbl.text = "\(difference.day!)天."
        }
        
        if difference.weekOfMonth! > 0 {
            cell.dateLbl.text = "\(difference.weekOfMonth!)周."
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }

    @objc func back(_ sender: UIBarButtonItem){
        // 退回到之前
        _ = self.navigationController?.popToRootViewController(animated: true)
        
        // 从postuuid数组中移除当前帖子的uuid
        if !postuuid.isEmpty {
            postuuid.removeLast()
        }
    }
}
