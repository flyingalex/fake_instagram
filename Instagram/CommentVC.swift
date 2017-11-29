//
//  CommentVC.swift
//  Instagram
//
//  Created by tiger on 2017/11/20.
//  Copyright © 2017年 hulin. All rights reserved.
//

import UIKit
import AVOSCloud

var commentuuid = [String]()
var commentowner = [String]()

class CommentVC: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTxt: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    
    var refresher = UIRefreshControl()
    
    // 重置UI的默认值
    var tableViewHeight: CGFloat = 0
    var commentY: CGFloat = 0
    var commentHeight: CGFloat = 0
    
    // 储存keyboard大小的变量
    var keyboard = CGRect()
    
    // 将从云端获取的数据写进数组
    var usernameArray = [String]()
    var avaArray = [AVFile]()
    var commentArray = [String]()
    var dateArray = [Date]()
    
    // page size
    var page: Int = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "评论"
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        // 在开始的时候，静止sendBtn按钮
        self.sendBtn.isEnabled = false
        
        // 如果键盘出现或消失，捕获这两个消息
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        backSwipe.direction = .right
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(backSwipe)
        
        aligment()
        loadComments()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CommentCell
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: .normal)
        cell.usernameBtn.sizeToFit()
        cell.commentLbl.text = commentArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackground{(data:  Data?, error: Error?) in
            cell.avaImg.image = UIImage(data: data!)
        }
        
        // 计算时间
        let from = dateArray[indexPath.row]
        let now = Date()
        let components : Set<Calendar.Component> = [.second, .minute, .hour, .day, .weekOfMonth]
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

    @objc func keyboardWillShow(_ notification: Notification) {
        // 获取到键盘的大小
        let rect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey]!) as! NSValue
        keyboard = rect.cgRectValue
        
        UIView.animate(withDuration: 0.4, animations: {() -> Void in
            self.tableView.frame.size.height = self.tableViewHeight - self.keyboard.height
            self.commentTxt.frame.origin.y = self.commentY - self.keyboard.height
            self.sendBtn.frame.origin.y = self.commentTxt.frame.origin.y
            
        })
    }
    
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.4, animations: {() -> Void in
            self.tableView.frame.size.height = self.tableViewHeight
            
            self.commentTxt.frame.origin.y = self.commentY
            
            self.sendBtn.frame.origin.y = self.commentY
            
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        // 隐藏底部标签栏
        self.tabBarController?.tabBar.isHidden = true
        
        // 调出键盘
        self.commentTxt.becomeFirstResponder()
    }
    
    // 当控制器从屏幕消失时
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // 如果没有输入信息就禁止按钮
        let spacing = CharacterSet.whitespacesAndNewlines
        if !textView.text.trimmingCharacters(in: spacing).isEmpty {
            sendBtn.isEnabled = true
        } else {
            sendBtn.isEnabled = false
        }
        
        if textView.contentSize.height > textView.frame.height &&
            textView.frame.height < 130 {
            let difference = textView.contentSize.height -
                textView.frame.height
            textView.frame.origin.y = textView.frame.origin.y - difference
            textView.frame.size.height = textView.contentSize.height
            
            // 上移tableView
            if textView.contentSize.height + keyboard.height + commentY >= tableView.frame.height {
                tableView.frame.size.height =
                tableView.frame.size.height - difference
            }
        } else if textView.contentSize.height < textView.frame.height {
            let difference = textView.frame.height - textView.contentSize.height
            textView.frame.origin.y = textView.frame.origin.y + difference
            textView.frame.size.height = textView.contentSize.height
            
            // 上移tableView
            if textView.contentSize.height + keyboard.height + commentY > tableView.frame.height {
                tableView.frame.size.height = tableView.frame.size.height + difference
            }
        }
    }
    
    @objc func back(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
        // 从数组中清除评论的uuid
        if !commentuuid.isEmpty {
            commentuuid.removeLast()
        }
        // 从数组中清除评论所有者
        if !commentowner.isEmpty {
            commentowner.removeLast()
        }
        
    }
    
    // 对齐ui控件
    func aligment() {
        let width = self.view.frame.width
        let height = self.view.frame.height
        tableView.frame = CGRect(x: 0, y: 0, width: width, height: height / 1.096 - self.navigationController!.navigationBar.frame.height - 20)
        
        tableView.estimatedRowHeight = width / 5.33
        tableView.rowHeight = UITableViewAutomaticDimension
        
        commentTxt.frame = CGRect(x: 10, y: tableView.frame.height + height / 56.8, width: width / 1.306, height: 33)
        
        commentTxt.layer.cornerRadius = commentTxt.frame.width / 50
        
        commentTxt.frame = CGRect(x: 10, y: tableView.frame.height + height / 56.8, width: width / 1.306, height: 33)
        
        sendBtn.frame = CGRect(x: commentTxt.frame.origin.x + commentTxt.frame.width + width / 32, y: commentTxt.frame.origin.y, width: width - (commentTxt.frame.origin.x + commentTxt.frame.width) - width / 32 * 2, height: commentTxt.frame.height)
        
        // 记录三个初始值
        tableViewHeight = tableView.frame.height
        commentHeight = commentTxt.frame.height
        commentY = commentTxt.frame.origin.y
        
        commentTxt.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func loadComments() {
        // STEP 1. 合计出所有的评论的数量
        let countQuery = AVQuery(className: "Comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackground({ (count: Int, error: Error?) in
            if self.page < count {
                self.refresher.addTarget(self, action: #selector(self.loadMore), for: .valueChanged)
                self.tableView.addSubview(self.refresher)
            }
            
            // STEP 2. 获取最新的self.page数量的评论
            let query = AVQuery(className: "Comments")
            query.whereKey("to", equalTo: commentuuid.last!)
            query.skip = count - self.page
            query.addAscendingOrder("createdAt")
            query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if error == nil {
                    // 清空数组
                    self.usernameArray.removeAll(keepingCapacity: false)
                    self.commentArray.removeAll(keepingCapacity: false)
                    self.avaArray.removeAll(keepingCapacity: false)
                    self.dateArray.removeAll(keepingCapacity: false)
                    
                    for object in objects! {
                        self.usernameArray.append((object as AnyObject).object(forKey: "username") as! String)
                        self.avaArray.append((object as AnyObject).object(forKey: "ava") as! AVFile)
                        self.commentArray.append((object as AnyObject).object(forKey: "comment") as! String)
                        self.dateArray.append((object as AnyObject).createdAt as! Date)
                        
                        self.tableView.reloadData()
                        
                        self.tableView.scrollToRow(at: IndexPath(row: self.commentArray.count - 1, section: 0)  , at: .bottom, animated: false)
                    }
                }else {
                    print(error?.localizedDescription)
                }
            })
        })
    }
    
    @objc func loadMore() {
        // STEP 1. 合计出所有的评论的数量
        let countQuery = AVQuery(className: "Comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackground({ (count:Int, error:Error?) in
            // 让refresh停止刷新动画
            self.refresher.endRefreshing()
            
            if self.page >= count {
                self.refresher.removeFromSuperview()
            }
            
            // STEP 2. 载入更多的评论
            if self.page < count {
                self.page = self.page + 15
                
                // 从云端查询page个记录
                let query = AVQuery(className: "Comments")
                query.whereKey("to", equalTo: commentuuid.last!)
                query.skip = count - self.page
                query.addAscendingOrder("createdAt")
                query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                    if error == nil {
                        // 清空数组
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.commentArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        self.dateArray.removeAll(keepingCapacity: false)
                        
                        for object in objects! {
                            self.usernameArray.append((object as AnyObject).object(forKey: "username") as! String)
                            self.avaArray.append((object as AnyObject).object(forKey: "ava") as! AVFile)
                            self.commentArray.append((object as AnyObject).object(forKey: "comment") as! String)
                            self.dateArray.append((object as AnyObject).createdAt as! Date)
                        }
                        self.tableView.reloadData()
                    }else {
                        print(error?.localizedDescription)
                    }
                })
            }
        })
    }
}

