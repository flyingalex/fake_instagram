//
//  UploadVC.swift
//  Instagram
//
//  Created by tiger on 2017/10/19.
//  Copyright © 2017年 hulin. All rights reserved.
//

import UIKit
import AVOSCloud

class UploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // UI objects
    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var titleTxt: UITextView!
    @IBOutlet weak var publishBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    
    @IBAction func removeBtn_clicked(_ sender: Any) {
        self.viewDidLoad()
    }
    @IBAction func publishBtn_clicked(_ sender: Any) {
        // 隐藏键盘
        self.view.endEditing(true)
        
        let object = AVObject(className: "Posts")
        object["username"] = AVUser.current()?.username
        object["ava"] = AVUser.current()?.value(forKey: "ava") as! AVFile
        object["puuid"] = "\(AVUser.current()?.username!) \(NSUUID().uuidString)"
        
        //titleTxt 是否为空
        if titleTxt.text.isEmpty {
            object["title"] = ""
        } else {
            object["title"] = titleTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        // 生成照片数据
        let imageData = UIImageJPEGRepresentation(picImg.image!, 0.5)
        let imageFile = AVFile(name: "post.jpg", data: imageData!)
        object["pic"] = imageFile
        
        // 将最终数据存储到LeanCloud云端
        object.saveInBackground({ (success: Bool, error: Error? ) in
            if error == nil {
                // 发送upload通知
                NotificationCenter.default.post(name: Notification.Name(rawValue: "uploaded"), object: nil)
                //将TabBar控制器中索引值为0的子控制器，显示在手机屏幕上。
                self.tabBarController!.selectedIndex = 0
                
                // reset一切
                self.viewDidLoad()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 默认情况下禁用 publishbtn 按钮
        publishBtn.isEnabled = false
        publishBtn.backgroundColor = .lightGray
        // 隐藏移除按钮
        removeBtn.isHidden = true
        
        // 单击image view
        let picTap = UITapGestureRecognizer(target: self, action: #selector(selectImg))
        picTap.numberOfTapsRequired = 1
        self.picImg.isUserInteractionEnabled = true
        self.picImg.addGestureRecognizer(picTap)
        
        // 让UI控件回到初始状态
        picImg.image = UIImage(named: "pbg.jpg")
        titleTxt.text = ""
        
        alignment()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // 显示移除按钮
        removeBtn.isHidden = false
        
        picImg.image = info[UIImagePickerControllerEditedImage] as! UIImage
        self.dismiss(animated: true, completion: nil)
        // 允许 publish btn
        publishBtn.isEnabled = true
        publishBtn.backgroundColor = UIColor(red: 52.0 / 255.0, green: 169.0 / 255.0, blue: 255.0 / 255.0, alpha: 1)
        
        // 实现第二次点击放大图片
        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(zoomImg))
        zoomTap.numberOfTapsRequired = 1
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(zoomTap)
    }
    
    // 放大或缩小照片
    @objc func zoomImg() {
        // 放大后Image View 的位置
        let zoomed = CGRect(x: 0, y: self.view.center.y, width: self.view.center.x, height: self.view.frame.width)
        
        //imgae view 还原到原始的位置
        let unzoomed = CGRect(x: 15, y: self.navigationController!.navigationBar.frame.height + 35, width: self.view.frame.width / 4.5, height: self.view.frame.width / 4.5)
        
        // 如果img是初始大小
        if picImg.frame == unzoomed {
            UIView.animate(withDuration: 0.3, animations: {
                self.picImg.frame = zoomed
                self.view.backgroundColor = .black
                self.titleTxt.alpha = 0
                self.publishBtn.alpha = 0
            })
        // 如果是放大后的状态
        }else {
            UIView.animate(withDuration: 0.3, animations: {
                self.picImg.frame = unzoomed
                self.view.backgroundColor = .white
                self.titleTxt.alpha = 1
                self.publishBtn.alpha = 1
            })
        }
    }
    
    @objc func selectImg() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    // 界面元素对齐
    func alignment() {
        let width = self.view.frame.width
        
        picImg.frame = CGRect(x: 15, y: self.navigationController!.navigationBar.frame.height + 35, width: width / 4.5, height: width / 4.5)
        
        titleTxt.frame = CGRect(x: picImg.frame.width + 25, y: picImg.frame.origin.y, width: width - titleTxt.frame.origin.x - 10, height: picImg.frame.height)
        
        publishBtn.frame = CGRect(x: 0, y: self.tabBarController!.tabBar.frame.origin.y - width / 8, width: width, height: width / 8)
        
        removeBtn.frame = CGRect(x: picImg.frame.origin.x, y: picImg.frame.origin.y + picImg.frame.height, width: picImg.frame.width, height: 30)
    }
 
}
