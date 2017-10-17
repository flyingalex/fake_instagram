//
//  EditVC.swift
//  Instagram
//
//  Created by tiger on 2017/10/15.
//  Copyright © 2017年 hulin. All rights reserved.
//

import UIKit

class EditVC: UIViewController,
    UIPickerViewDelegate,
    UIPickerViewDataSource,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    // 获取器方法
    // 设置获取器的组件数量
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // 设置获取器中选项的数量
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    // 设置获取选项的title
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    //从获取器中得到用户选择的item
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTxt.text = genders[row]
        self.view.endEditing(true)
    }

   
    // UI对象部分
    // 滚动视图
    @IBOutlet weak var scrollView: UIScrollView!
    // 个人头像
    @IBOutlet weak var avaImg: UIImageView!
    // 上半部分的信息
    @IBOutlet weak var fullnameTxt: UITextField!
    
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var webTxt: UITextField!
    @IBOutlet weak var bioTxt: UITextView!
    // 私人信息
    @IBOutlet weak var titleLbl: UILabel!
    // 下半部分的信息
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var telTxt: UITextField!
    @IBOutlet weak var genderTxt: UITextField!
    
    // pickerview 和 pickerdata
    var genderPicker: UIPickerView!
    let genders = ["男", "女"]
    var keyboard = CGRect()
    
    @IBAction func cancel_clicked(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func save_clicked(_ sender: UIBarButtonItem) {
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 在视图中创建pickerview
        genderPicker = UIPickerView()
        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderPicker.backgroundColor = UIColor.groupTableViewBackground
        genderPicker.showsSelectionIndicator = true
        genderTxt.inputView = genderPicker
        
        // 检测键盘出现或消失的状态
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        
        // 单击控制器后让键盘消失
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // 点击image view
        let imgTap = UITapGestureRecognizer(target: self, action: #selector(loadImg))
        imgTap.numberOfTapsRequired = 1
        avaImg.isUserInteractionEnabled = true
        avaImg.addGestureRecognizer(imgTap)
        
        // 界面布局
        alignment()
    }

    // 调出照片获取器选择照片
    @objc func loadImg(recognizer: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }

    // 关联选择好的照片图像到image view
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        avaImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    // 隐藏视图中的虚拟键盘
    @objc func hideKeyboardTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    
    @objc func showKeyboard(notification: Notification) {
        
        // 定义keyboard大小
        let rect = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        keyboard = rect.cgRectValue
        
        // 当虚拟键盘出现以后，将滚动视图的内容高度变为控制器视图高度加上键盘高度的一半。
        UIView.animate(withDuration: 0.4) {
            self.scrollView.contentSize.height = self.view.frame.height + self.keyboard.height / 2
        }
    }
    
    @objc func hideKeyboard(notification: Notification) {
        // 当虚拟键盘消失后，将滚动视图的内容高度值改变为0，这样滚动视图会根据实际内容设置大小。
        UIView.animate(withDuration: 0.4) {
            self.scrollView.contentSize.height = 0
        }
    }
    
    func alignment() {
        let width = self.view.frame.width
        let height = self.view.frame.height
        scrollView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        avaImg.frame = CGRect(x: width - 68 - 10, y: 15, width: 68, height: 68)
        avaImg.layer.cornerRadius = avaImg.frame.width / 2
        avaImg.clipsToBounds = true
        fullnameTxt.frame = CGRect(x: 10, y: avaImg.frame.origin.y, width: width - avaImg.frame.width - 30, height: 30)
        usernameTxt.frame = CGRect(x: 10, y: fullnameTxt.frame.origin.y + 40, width: width - avaImg.frame.width - 30, height: 30)
        webTxt.frame = CGRect(x: 10, y: usernameTxt.frame.origin.y + 40, width: width - 20, height: 30)
        bioTxt.frame = CGRect(x: 10, y: webTxt.frame.origin.y + 40, width: width - 20, height: 60)
        // 为bioTxt创建1个点的边线，并设置边线的颜色
        bioTxt.layer.borderWidth = 1
        bioTxt.layer.borderColor = UIColor(red: 230 / 255.0, green: 230 / 255.0, blue: 230 / 255.0, alpha: 1).cgColor
        // 设置bioTxt为圆角
        bioTxt.layer.cornerRadius = bioTxt.frame.width / 50
        bioTxt.clipsToBounds = true
        titleLbl.frame = CGRect(x: 10, y: bioTxt.frame.origin.y + 100, width: width - 20, height: 30)
        emailTxt.frame = CGRect(x: 10, y: titleLbl.frame.origin.y + 40, width: width - 20, height: 30)
        telTxt.frame = CGRect(x: 10, y: emailTxt.frame.origin.y + 40, width: width - 20, height: 30)
        genderTxt.frame = CGRect(x: 10, y: telTxt.frame.origin.y + 40, width: width - 20, height: 30)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
