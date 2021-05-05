//
//  handViewController.swift
//  mapLocation
//
//  Created by 陳韻嬛 on 2021/1/21.
//

import UIKit

class handViewController: UIViewController {

    @IBOutlet weak var areaLabel: UITextField!
    @IBOutlet weak var roadLabel: UITextField!
    @IBOutlet weak var idLabel: UITextField!
    
    @IBAction func selecttoHoleView(_ sender: UIButton) {
        gotoHoleView()
    }
    
    //用 storyboardID 前往 HoleView.storyboard
    func gotoHoleView() {
        
        if let areaLabel = areaLabel.text, let roadLabel = roadLabel.text, let idLabel = idLabel.text {
            if areaLabel == "" || roadLabel == "" || idLabel == "" {
                // 沒選完，跳警告
                let myAlert = UIAlertController(title: "資料不完整", message: "請在輸入框填入資料", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "確認", style: .default, handler: nil)
                myAlert.addAction(okAction)
                present(myAlert, animated: true, completion: nil)
            } else {
                // 換場景
                let goFirst = UIStoryboard(name: "HoleView", bundle: nil).instantiateViewController(withIdentifier: "mainView")
                present(goFirst, animated: true, completion: nil)
                //應該可以使用completion傳值給下一頁（need:userID/manHoleID）
            }
        }
    }
    
    

//    -----------------------------------
//    PickerView
    
    // 第一層
    let region = ["區域-1","區域-2"]
    // 第二層
    let road1 = ["路段-1a","路段-1b"]
    let road2 = ["路段-2a","路段-2b","路段-2c"]
    // 第三層
    let number1a = ["序號-1a1","序號-1a2"]
    let number1b = ["序號-1b1","序號-1b2","序號-1b3"]
    let number2a = ["序號-2a1","序號-2a2"]
    let number2b = ["序號-2b1","序號-2b2","序號-2b3"]
    let number2c = ["序號-2c1","序號-2c2"]
    
    var regionpickerView = UIPickerView()
    var roadpickerView = UIPickerView()
    var numberpickerView = UIPickerView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        areaLabel.inputView = regionpickerView
        roadLabel.inputView = roadpickerView
        idLabel.inputView = numberpickerView
        
        areaLabel.textAlignment = .center
        roadLabel.textAlignment = .center
        idLabel.textAlignment = .center
        
        regionpickerView.delegate = self
        regionpickerView.dataSource = self
        roadpickerView.delegate = self
        roadpickerView.dataSource = self
        numberpickerView.delegate = self
        numberpickerView.dataSource = self
        
        regionpickerView.tag = 1
        roadpickerView.tag = 2
        numberpickerView.tag = 3
    }
}


extension handViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    //有幾列
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // 每列有幾個選項
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return region.count
        case 2:
            switch areaLabel.text {
            case "區域-1":
                return road1.count
            case "區域-2":
                return road2.count
            default:
                return 0
            }
        case 3:
            switch roadLabel.text {
            case "路段-1a":
                return number1a.count
            case "路段-1b":
                return number1b.count
            case "路段-2a":
                return number2a.count
            case "路段-2b":
                return number2b.count
            case "路段-2c":
                return number2c.count
            default:
                return 0
            }
        default:
            return 1
        }
    }
    // 選項文字
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return region[row]
        case 2:
            switch areaLabel.text {
            case "區域-1":
                return road1[row]
            case "區域-2":
                return road2[row]
            default:
                return nil
            }
        case 3:
            switch roadLabel.text {
            case "路段-1a":
                return number1a[row]
            case "路段-1b":
                return number1b[row]
            case "路段-2a":
                return number2a[row]
            case "路段-2b":
                return number2b[row]
            case "路段-2c":
                return number2c[row]
            default:
                return nil
            }
        default:
            return "Data not found."
        }
    }
    
    // 選擇時觸發
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            areaLabel.text = region[row]
            areaLabel.resignFirstResponder()
        case 2:
            switch areaLabel.text {
            case "區域-1":
                roadLabel.resignFirstResponder()
                return roadLabel.text = road1[row]
            case "區域-2":
                roadLabel.resignFirstResponder()
                return roadLabel.text = road2[row]
            default:
                return print("無路段資料")
            }
        case 3:
            switch roadLabel.text {
            case "路段-1a":
                idLabel.resignFirstResponder()
                return idLabel.text = number1a[row]
            case "路段-1b":
                idLabel.resignFirstResponder()
                return idLabel.text = number1b[row]
            case "路段-2a":
                idLabel.resignFirstResponder()
                return idLabel.text = number2a[row]
            case "路段-2b":
                idLabel.resignFirstResponder()
                return idLabel.text = number2b[row]
            case "路段-2c":
                idLabel.resignFirstResponder()
                return idLabel.text = number2c[row]
            default:
                return print("無編號資料")
            }
        default:
            return print("no data")
        }
    }
}
