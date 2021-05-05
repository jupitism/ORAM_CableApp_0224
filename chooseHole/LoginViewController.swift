//
//  LoginViewController.swift
//  chooseHole
//
//  Created by Youko Chen on 2021/2/24.
//  Copyright © 2021 youkochen. All rights reserved.
//

import UIKit

//全域使用者ID
var universeUserID = ""

class LoginViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var inputID: UITextField!
    @IBOutlet weak var inputPW: UITextField!
    
    let testID:String = "Admin"
    let testPW:String = "Abc1234"
    

    @IBAction func btnLogin(_ sender: UIButton) {
        //測試任意門🚪🔑✨🔜
        //goNext()
        
        if inputID.text == "" || inputID.text == nil{
            alertPOP(message: "請輸入帳號")
        }else{
            if inputPW.text == "" || inputPW.text == nil{
                alertPOP(message: "請輸入密碼")
            }else{
                //帳號密碼都有輸入
                
                //1.先解optional -------------------------
                let id:String = inputID.text!
                let pw:String = inputPW.text!
//                alertPOP(message: "id:\(id)/pw:\(pw)")
                
                
                //2.上傳資料 & 取得正確與否 -> true/false -------------------------
                let pass = sendCheck(id: id, pw: pw)
                
                //3.true/false 動作 -------------------------
                if pass == true{
                    //true -> next page -------------------------
                    
                    universeUserID = id //賦予全域使用者ID 供後續使用
                    
                    inputID.text = "" //清空輸入框
                    inputPW.text = ""
                    
                    goNext() //前往下一頁
                    
                }else if pass == false{
                    //false -> alert -------------------------
                    alertPOP(message: "登入資料有誤")
                }
                
            }
        }
        
        
    }
    
    

    //-------------------------
    //func alert
    func alertPOP(message:String){
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    //func sendCheck
    func sendCheck(id:String,pw:String) -> Bool{
        //1.上傳
        //2.解析取得資訊
        if id == testID && pw == testPW{
            return true
        }else{
            return false
        }
    }
    //func goNext
    func goNext(){
        let goFirst = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
        
        present(goFirst, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    //[關閉鍵盤]
    //-------------------------
    //關閉鍵盤1：服從協定UITextFieldDelegate，可實作鍵盤按return後的動作
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //關閉鍵盤2：點擊空白處
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
