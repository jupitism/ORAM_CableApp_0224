//
//  homeViewController.swift
//  mapLocation
//
//  Created by 陳韻嬛 on 2021/1/21.
//

import UIKit

class homeViewController: UIViewController {

    var infoFromHand: String?
    var infoFromHand2: String?
    var infoFromHand3: String?
    
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var roadLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        regionLabel.text = infoFromHand
        roadLabel.text = infoFromHand2
        numberLabel.text = infoFromHand3
    }
    

    

}
