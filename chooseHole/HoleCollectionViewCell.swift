//
//  frontCollectionViewCell.swift
//  chooseHole
//
//  Created by Youko Chen on 2021/1/18.
//  Copyright © 2021 youkochen. All rights reserved.
//

import UIKit

//孔洞cell
//HoleDelegate(以btn確認點擊孔洞及回傳ID)
protocol HoleDelegate{
//    func callForm(holeID:String)
    func callForm(cellData:passHoleData)
    
}

class HoleCollectionViewCell: UICollectionViewCell {


    @IBOutlet weak var frontCount: UILabel!
    @IBOutlet weak var rightCount: UILabel!
    @IBOutlet weak var backCount: UILabel!
    @IBOutlet weak var leftCount: UILabel!
    
    var delegate:HoleDelegate?
    
    var holeData:passHoleData?
    @IBOutlet weak var frontBtnShow: UIButton!
    @IBAction func frontBtnCall(_ sender: UIButton) {
        getid(view: .front)
    }
    
    @IBOutlet weak var rightBtnShow: UIButton!
    @IBAction func rightBtnCall(_ sender: UIButton) {
        getid(view: .right)
    }
    
    @IBOutlet weak var backBtnShow: UIButton!
    @IBAction func backBtnCall(_ sender: UIButton) {
        getid(view: .back)
    }
    
    @IBOutlet weak var leftBtnShow: UIButton!
    @IBAction func leftBtnCall(_ sender: UIButton) {
        getid(view: .left)
    }
    
    //從btn title得到id
    func getid(view:viewName){
        print("in get")
        
        if let okData = holeData{
            self.delegate?.callForm(cellData:okData)
        }
        

        
//        switch view {
//        case .front:
//
//        case .right:
//            if let holeID:String = rightBtnShow.currentTitle{
//                self.delegate?.callForm(holeID:holeID)
//            }
//        case .back:
//            if let holeID:String = backBtnShow.currentTitle{
//                self.delegate?.callForm(holeID:holeID)
//            }
//        case .left:
//            if let holeID:String = leftBtnShow.currentTitle{
//                self.delegate?.callForm(holeID:holeID)
//            }
//        default:
//            break
//        }
        
    }
    
    
    

}
