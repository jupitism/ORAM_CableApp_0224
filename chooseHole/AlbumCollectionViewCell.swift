//
//  AlbumCollectionViewCell.swift
//  chooseHole
//
//  Created by Youko Chen on 2021/2/1.
//  Copyright © 2021 youkochen. All rights reserved.
//

import UIKit

//imgCellDelegate (回傳要刪除哪張照片)
protocol imgCellDelegate {
    func imgDeleteAlert(num:Int)
}

class AlbumCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var clearBtnShow: UIButton!
    var delegate: imgCellDelegate?
    
    @IBAction func btnClear(_ sender: UIButton) {
        let num = clearBtnShow.tag
        self.delegate?.imgDeleteAlert(num: num)
    }
}
