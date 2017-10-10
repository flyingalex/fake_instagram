//
//  SignUpVC.swift
//  Instagram
//
//  Created by tiger on 2017/10/8.
//  Copyright © 2017年 hulin. All rights reserved.
//

import UIKit
import AVOSCloud

class SignUpVC: UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {

    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var repeatPasswordTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var bioTxt: UITextField!
    @IBOutlet weak var webTxt: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    // 根据需要设置滚动视图的高度
    var scrollViewHeight: CGFloat = 0
    // 获取虚拟键盘的大小
    var keyboard: CGRect = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 滚动视图的窗口尺寸
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        scrollView.contentSize.height = self.view.frame.height
        scrollViewHeight = self.view.frame.height
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
    
        // 申明隐藏虚拟键盘的操作
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        let imgTap = UITapGestureRecognizer(target: self, action: #selector(loadImg))
        imgTap.numberOfTapsRequired = 1
        avaImg.isUserInteractionEnabled = true
        avaImg.addGestureRecognizer(imgTap)
        
        // 改变avaimg外观
        avaImg.layer.cornerRadius = avaImg.frame.width / 2
        avaImg.clipsToBounds = true
        
        // UI元素布局
        let viewWidth = self.view.frame.width
        avaImg.frame = CGRect( x: viewWidth / 2 - 40, y: 40, width: 80, height: 80)
        usernameTxt.frame = CGRect( x: 10, y: avaImg.frame.origin.y + 90, width: viewWidth - 20, height: 30)
        passwordTxt.frame = CGRect( x: 10, y: usernameTxt.frame.origin.y + 40, width: viewWidth - 20, height: 30)
        repeatPasswordTxt.frame = CGRect( x: 10, y: passwordTxt.frame.origin.y + 40, width: viewWidth - 20, height: 30)
        emailTxt.frame = CGRect( x: 10, y: repeatPasswordTxt.frame.origin.y + 40, width: viewWidth - 20, height: 30)
        fullnameTxt.frame = CGRect( x: 10, y: emailTxt.frame.origin.y + 40, width: viewWidth - 20, height: 30)
        bioTxt.frame = CGRect( x: 10, y: fullnameTxt.frame.origin.y + 40, width: viewWidth - 20, height: 30)
        webTxt.frame = CGRect( x: 10, y: bioTxt.frame.origin.y + 40, width: viewWidth - 20, height: 30)
        signUpBtn.frame = CGRect( x: 20, y: webTxt.frame.origin.y + 50, width: viewWidth / 4, height: 30)
        cancelBtn.frame = CGRect( x: viewWidth - viewWidth / 4 - 20, y: signUpBtn.frame.origin.y, width: viewWidth / 4, height: 30)
        
        // 设置背景图
        let bg = UIImageView(frame: CGRect( x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        bg.image = UIImage(named: "back.png")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
    }

    @objc func loadImg(recognizer: UITapGestureRecognizer){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    // 关联选择好的图片到image view
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        avaImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    // 用户取消获取器时调用的方法
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboardTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func showKeyboard(notification: Notification) {
        // 定义keyboard的大小
        let rect = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        keyboard = rect.cgRectValue
        
        // 当虚拟键盘出现以后，将滚动视图的实际高度缩小为屏幕高度减去键盘高度
        UIView.animate(withDuration: 0.4) {
            self.scrollView.frame.size.height = self.scrollViewHeight - self.keyboard.size.height
        }
    }
    
    @objc func hideKeyboard(notification: Notification) {
        UIView.animate(withDuration: 0.4) {
            self.scrollView.frame.size.height = self.view.frame.height
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func signUpBtn_clicked(_ sender: UIButton) {
        // 隐藏keyboard
        self.view.endEditing(true)
        if usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty || repeatPasswordTxt.text!.isEmpty || emailTxt.text!.isEmpty || fullnameTxt.text!.isEmpty || bioTxt.text!.isEmpty || webTxt.text!.isEmpty {
            // 弹出提示框
            let alert = UIAlertController(title: "请注意", message: "请填写好所有字段", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if passwordTxt.text != repeatPasswordTxt.text {
            let alert = UIAlertController(title: "请注意", message: "两次输入密码不一致", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // 发送注册数据到服务器相关的代码
        let user = AVUser()
        user.username = usernameTxt.text?.lowercased()
        user.email = emailTxt.text?.lowercased()
        user.password = passwordTxt.text
        user["fullname"] = fullnameTxt.text?.lowercased()
        user["bio"] = bioTxt.text
        user["web"] = webTxt.text?.lowercased()
        user["gender"] = ""
        // 转换头像数据并发送到服务器
        let avaData = UIImageJPEGRepresentation(avaImg.image!, 0.5)
        let avaFile = AVFile( name: "ava.jpg", data: avaData!)
        user["ava"] = avaFile
        user.signUpInBackground { (success: Bool, error: Error?) in
            if success {
                print("用户注册成功!")
                // 记住登录的用户
                UserDefaults.standard.set(user.username, forKey: "username")
                UserDefaults.standard.synchronize()
                // 从AppDelegate类中调用login方法
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            
            } else {
                print(error?.localizedDescription)
                print("用户注册失败!")
            }
        }
        
     
    }
    @IBAction func cancelBtn_clicked(_ sender: UIButton) {
        self.view.endEditing( true)
        self.dismiss(animated: true, completion: nil)
    }
}
