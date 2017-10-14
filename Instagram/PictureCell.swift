//
//  PictureCell.swift
//  Instagram
//
//  Created by tiger on 2017/10/10.
//  Copyright © 2017年 hulin. All rights reserved.
//

import UIKit

class PictureCell: UICollectionViewCell {
    @IBOutlet weak var picImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let width = UIScreen.main.bounds.width
        // 将单元格中image view 的尺寸同样设置为屏幕宽度的1/3
        picImg.frame = CGRect(x: 0, y: 0, width: width / 3, height: width / 3)
    }

}
