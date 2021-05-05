//
//  FormViewController.swift
//  ORAMapp
//
//  Created by mac on 2021/1/11.
//  Copyright © 2021 mac. All rights reserved.
//

import UIKit

protocol reloadDelegate {
    func reloadCollection(viewName: viewName)
}

class FormViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var delegate: reloadDelegate?

    // 傳進來的資料
    var idtoFrom:String = "none" //洞ID：基本上一定會給洞ID
    var objtoFrom:SingleHoleData? //洞資料：洞可能已有資料或沒資料nil

    // pickerview
    @IBOutlet weak var viewIdLabel: UILabel!
    @IBOutlet weak var sizePickerText: UITextField!
    @IBOutlet weak var amountPickerText: UITextField!
    @IBOutlet weak var lengthTextField: UITextField!
    @IBOutlet weak var auditLabel: UILabel!
    
    let sizeArray = ["無","2inch","3inch","4inch","5inch","6inch"]
    let amountArray = ["0", "1", "2", "3", "4", "5"]
    
    var sizePickerView = UIPickerView()
    var amountPickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sizePickerText.inputView = sizePickerView
        amountPickerText.inputView = amountPickerView
        
        sizePickerView.delegate = self
        amountPickerView.delegate = self
        
        sizePickerView.tag = 1
        amountPickerView.tag = 2
        
        // 傳進來的資料
        let holeID = idtoFrom
        // print("from got id: \(holeID)")
        viewIdLabel.text = holeID
        
        if let haveData = objtoFrom {
            let pipeType = haveData.pipeType!
            let pipeCount = haveData.pipeCount!
            let leadTube = haveData.leadTube!
            let audit = haveData.audit!
            // print("hole data: \(pipeType) / \(pipeCount) / \(leadTube)")
            sizePickerText.text = pipeType
            amountPickerText.text = pipeCount
            lengthTextField.text = leadTube
            auditLabel.text = audit
        } else {
            print("\(holeID) this hole is empty")
        }
        
    }
    
//    有幾列
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView.tag {
        case 1:
            return 1
        case 2:
            if sizePickerText.text == "4inch" {
                return 4
            } else {
                return 1
            }
        default:
            return 1
        }
    }
    
//    每列有幾個選項
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return sizeArray.count
        case 2:
            if sizePickerText.text == "4inch" {
                if component == 0 || component == 2 {
                    return 1
                } else if component == 1 {
                    return 2
                } else {
                    return 4
                }
            } else {
                return amountArray.count
            }
        default:
            return 1
        }
    }
    
//    選項文字
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return sizeArray[row]
        case 2:
            if sizePickerText.text == "4inch" {
                if component == 0 {
                    return "D34"
                } else if component == 2 {
                    return "D40"
                } else {
                    return amountArray[row]
                }
            } else {
                return amountArray[row]
            }
        default:
            return "無資料"
        }
    }
    
//    選擇時觸發
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            sizePickerText.text = sizeArray[row]
            sizePickerText.resignFirstResponder()
        case 2:
            if sizePickerText.text == "4inch" {
                let selectedD34 = pickerView.selectedRow(inComponent: 1)
                let selectedD40 = pickerView.selectedRow(inComponent: 3)
                amountPickerText.text = "\(selectedD34) + \(selectedD40)"
            } else {
                amountPickerText.text = amountArray[row]
                amountPickerText.resignFirstResponder()
            }
        default:
            return
        }
    }
    


    
    @IBAction func closeBtn(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func sendBtn(_ sender: UIButton) {
        if let pipeType = sizePickerText.text, let pipeCount = amountPickerText.text, let leadTube = lengthTextField.text, let holeID = viewIdLabel.text, let audit = auditLabel.text {
            if pipeType == "" || pipeCount == "" || leadTube == "" {
                // 沒點選，跳警告
                let myAlert = UIAlertController(title: "資料不完整", message: "請在輸入框填入資料", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "確認", style: .default, handler: nil)
                myAlert.addAction(okAction)
                present(myAlert, animated: true, completion: nil)
            } else {
                // 換場景，傳資料，MVC reload
                print("form:\(pipeType)")
                
                let pass = SingleHoleData(holeID: holeID, pipeType: pipeType, pipeCount: pipeCount, leadTube: leadTube, audit: audit)
                
                
                
                offlineData?.viewFront?.holeData?.append(pass)
        
                self.delegate?.reloadCollection(viewName: .front)
                
                dismiss(animated: true, completion: {
                    print("send \(pass)")
                })
            }
        }
    }
    
    
    
    @IBOutlet weak var sendBtnChanged: UIButton!
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
}
