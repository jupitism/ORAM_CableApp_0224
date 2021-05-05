//
//  MainViewController.swift
//  chooseHole
//
//  Created by Youko Chen on 2021/1/18.
//  Copyright © 2021 youkochen. All rights reserved.
//
// 0127_json in_build ok


import UIKit

let engArr = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T"]

var offlineData:AllData? //下載後的本機暫存資料
//      --------------------------------------------------
//json結構模擬(解析用)
struct AllData:Decodable {
    var userID:String?
    var userName:String?
    var manHoleID:String?
    var manHoleZone:String?
    var manHoleRd:String?
    
    var viewFront:ViewData?
    var viewRight:ViewData?
    var viewBack:ViewData?
    var viewLeft:ViewData?
}
struct ViewData:Decodable {
    var section:String?
    var row:String?
    var viewImg:[String]?
    
    var holeData:[SingleHoleData]?
}
struct SingleHoleData:Decodable {
    var holeID:String?
    var pipeType:String?
    var pipeCount:String?
    var leadTube:String?
    var audit:String?
}

struct passHoleData {
    var holeID:String
    var holeData:SingleHoleData?
}



//      --------------------------------------------------

var holeTypeDic:[String:UIColor] = [
    "2inch": UIColor.blue,
    "3inch": UIColor.green,
    "4inch": UIColor.orange,
    "5inch": UIColor.red,
    "6inch": UIColor.purple,
    "empty": UIColor.gray,
    "tool": UIColor.clear
]
enum viewName{
    case front
    case right
    case back
    case left
}
enum countName{
    case frontSection
    case frontRow
    case rightSection
    case rightRow
    case backSection
    case backRow
    case leftSection
    case leftRow
}
var countDic:[countName:Int] = [
    countName.frontSection: 6,
    countName.frontRow: 6,
    countName.rightSection: 6,
    countName.rightRow: 6,
    countName.backSection: 6,
    countName.backRow: 6,
    countName.leftSection: 6,
    countName.leftRow: 6
]

//相簿array
var imgArrMore:[UIImage]? = []
//      --------------------------------------------------
//      重要判定變數
var nowPage = 0 //目前視圖
var edited = false //是否被編輯過



//      MainViewController  --------------------------------------------------
//  自訂protocol: HoleDelegate(HoleCollectionViewCell) / AlbumDelegat(AlbumViewController)

class MainViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate,HoleDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDelegate, UITableViewDataSource,AlbumDelegat, reloadDelegate {
    
    
    
    @IBOutlet weak var collectionFrontView: UICollectionView!
    @IBOutlet weak var collectionRightView: UICollectionView!
    @IBOutlet weak var collectionBackView: UICollectionView!
    @IBOutlet weak var collectionLeftView: UICollectionView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    //亮顯點點
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var segmentControl: UISegmentedControl!

    @IBOutlet weak var albumCount: UIButton!
    @IBAction func btnBackToMap(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func btnUpload(_ sender: UIButton) {
        let saveAlert = UIAlertController(title: "是否上傳資料？", message: "如未上傳，更新資料將不會被保留。", preferredStyle: .alert)
        let save = UIAlertAction(title: "上傳", style: .default) {_ in
            print("save")
        }
        let delete = UIAlertAction(title: "不儲存", style: .default) { action in
            self.uploadData(savepage: nil)
        }
        saveAlert.addAction(save)
        saveAlert.addAction(delete)

        present(saveAlert, animated: true, completion: nil)
        print("edited passpage")
    }
    
    

    
    
    
//    --------------------------------------------------
//    tableView
        let titleArray = ["填報人","人孔所在區域","人孔所在路段","人孔編碼序號"]
        // 帶入JSON解析後產生的變數 -> 目前將解析後的值直接覆蓋contentArray
        var contentArray = [offlineData?.userName, offlineData?.manHoleZone, offlineData?.manHoleRd, offlineData?.manHoleID]
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return titleArray.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "pipeInfoCell")
            cell.textLabel?.text = titleArray[indexPath.row]
            cell.detailTextLabel?.text = contentArray[indexPath.row]
            cell.textLabel?.textColor = .white
            cell.detailTextLabel?.textColor = .systemGreen
            cell.backgroundColor = UIColor.clear
            return cell
        }
    
    
    
    
    
    
//    [照相相關]
//    --------------------------------------------------
//    addPhoto
    @IBAction func btnAddPhoto(_ sender: UIButton) {
        if let arrCount = imgArrMore?.count{
            
            var alertController = UIAlertController()
            
            if arrCount == 10{
                alertController = UIAlertController(title: "已達選取上限", message: "最多可選擇4張照片", preferredStyle: .alert)
                
            }else{
                alertController = UIAlertController(title: "選擇拍照或從相簿選取", message: nil, preferredStyle: .alert)

                let shoot = UIAlertAction(title: "拍照", style: .default) { action in self.builtImagePickerView(sourceType: .camera)}
                let album = UIAlertAction(title: "相簿", style: .default) { action in self.builtImagePickerView(sourceType: .savedPhotosAlbum)}

                alertController.addAction(shoot)
                alertController.addAction(album)
                
            }
            let canel = UIAlertAction(title: "取消", style: .cancel) { action in }
            alertController.addAction(canel)
            present(alertController, animated: true, completion: nil)
        }
    }
    //func 生成相機或相簿
    func builtImagePickerView(sourceType:UIImagePickerControllerSourceType){
        func built(){
            let imagePicker = UIImagePickerController() //生成實體
            imagePicker.delegate = self //delegate設定給viewcontroller
            imagePicker.sourceType = sourceType //讀取參數sourceType為顯示形式
            
            present(imagePicker, animated: true, completion: nil)
        }
        if sourceType == .camera && !UIImagePickerController.isSourceTypeAvailable(.camera){
            //開啟為相機 且 相機不可用
            print("no camera") //或設計跳alert告知無法使用相機
        }else{
            built()
        }

    }
    //顯示及儲存照片
    //imagePickerController為內建方法 於didFinishPicking時執行
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{ //從info取得剛剛照的照片（原始）
            
            //加入相簿array & 更新相簿顯示數量
            imgArrMore?.append(image)
            setAlbumCount()
            edited = true
            
            //判斷是否儲存相片（從相簿點選則否）
            if picker.sourceType == .camera{
                print("save pic")
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil) //儲存進相簿
            }else{
                print("no save")
            }
            
        }
        dismiss(animated: true, completion: nil) //移除照相畫面
        let goAlbum = UIStoryboard(name: "HoleView", bundle: nil).instantiateViewController(withIdentifier: "albumView")
        present(goAlbum, animated: true, completion: nil)
        
        
    }
    //func 相簿目前照片數量
    func setAlbumCount(){

        if let num = imgArrMore?.count{
            if num == 0{
                albumCount.setTitle(" 相簿", for: .normal)
            }else{
                albumCount.setTitle(" 相簿(\(num))", for: .normal)
            }
            
        }
    }
    
    
    
    
    
    
//    [換頁相關]
//      --------------------------------------------------
//      scrollView 滑動換頁 亮顯
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        //hightlight segmented
        let newPage = scrollView.contentOffset.x / scrollView.bounds.width
        segmentControl.selectedSegmentIndex = Int(newPage)
//        pageControl.currentPage = Int(page)
        
        //save or load
        let passPage = nowPage
        changePage(passPage: passPage, newPage: Int(newPage))

    }
//      --------------------------------------------------
//      segmentedControl 點擊換頁 滑動
    @IBAction func segmentPage(_ sender: UISegmentedControl) {
        
        let newPage = sender.selectedSegmentIndex
        
        //move scrollview
        let point = CGPoint(x: mainScrollView.bounds.width * CGFloat(newPage), y: 0)
        mainScrollView.setContentOffset(point, animated: true)
        
        //save or load
        let passPage = nowPage
        changePage(passPage: passPage, newPage: Int(newPage))

    }
//      --------------------------------------------------
//      func changePage 換頁判定save or load
    func changePage(passPage:Int,newPage:Int){
        
        //更新現頁紀錄
        nowPage = newPage
        
        //是否儲存上一頁資料
        if edited == true{
            var pageName = "前視圖"
            switch passPage {
            case 0:
                pageName = "前視圖"
            case 1:
                pageName = "右視圖"
            case 2:
                pageName = "後視圖"
            case 3:
                pageName = "左視圖"
            default:
                pageName = ""
            }
            let saveAlert = UIAlertController(title: "是否上傳\(pageName)資料？", message: "如未上傳，更新資料將不會被保留。", preferredStyle: .alert)
            let save = UIAlertAction(title: "上傳", style: .default) { action in
                self.uploadData(savepage: passPage)
            
            }
            let delete = UIAlertAction(title: "不儲存", style: .default) { action in
                self.uploadData(savepage: nil)
            }
            saveAlert.addAction(save)
            saveAlert.addAction(delete)

            present(saveAlert, animated: true, completion: nil)
            print("edited passpage:\(passPage)")
            
        }else if edited == false{
            loadData()
        }
        
    }
    


    
    
    
    
    
    
//    [collectionView]
//    --------------------------------------------------
//      func 重新整理視圖
    func reloadCollection(viewName:viewName){
        // 此階段 mainScrollView.frame.width 非旋轉後寬度
        
        switch viewName {
        case .front:
            collectionFrontView.reloadData()
            print("reloadFront")
        case .right:
            collectionRightView.reloadData()
        case .back:
            collectionBackView.reloadData()
        case .left:
            collectionLeftView.reloadData()
        default:
            collectionFrontView.reloadData()
            collectionRightView.reloadData()
            collectionBackView.reloadData()
            collectionLeftView.reloadData()
        }
    }
//    --------------------------------------------------
//    size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //若畫面有被旋轉，重新定義scrollview寬度
        //只有在此階段 mainScrollView.frame.width 才為正確旋轉後寬度
        if isRotate == true{
            //scrollView contentSize寬度設定
            let scrollWidth = (mainScrollView.frame.width) * 4
            mainScrollView.contentSize = CGSize(width: scrollWidth, height: 0)
            
            //調整視圖定位符合當前segment
            let newPage = segmentControl.selectedSegmentIndex
            print("SafeArea new:\(newPage)")
            //move scrollview
            let point = CGPoint(x: mainScrollView.frame.width * CGFloat(newPage), y: 0)
            mainScrollView.setContentOffset(point, animated: true)
            
            //因應旋轉的調整結束
            isRotate = false
        }

        var countR = CGFloat(countDic[.frontRow]!)
        var width = (collectionFrontView.frame.width - ((countR - 1) * 2)) / countR
        print("scrollWidth-collection:\(collectionFrontView.frame.width)")
        switch collectionView.tag {
        case 0:
            // (1)set right row count (2)width choose right collectionview.frame
            countR = CGFloat(countDic[.frontRow]!)
            width = (collectionFrontView.frame.width - ((countR - 1) * 2)) / countR
            return CGSize(width: width, height: width)
        case 1:
            countR = CGFloat(countDic[.rightRow]!)
            width = (collectionRightView.frame.width - ((countR - 1) * 2)) / countR
            return CGSize(width: width, height: width)
        case 2:
            countR = CGFloat(countDic[.backRow]!)
            width = (collectionBackView.frame.width - ((countR - 1) * 2)) / countR
            return CGSize(width: width, height: width)
        case 3:
            countR = CGFloat(countDic[.leftRow]!)
            width = (collectionLeftView.frame.width - ((countR - 1) * 2)) / countR
            return CGSize(width: width, height: width)
        default:
            
            return CGSize(width: width, height: width)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
//    --------------------------------------------------
//    collectionView normal set
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch collectionView.tag {
        case 0:
            return countDic[.frontSection]!
        case 1:
            return countDic[.rightSection]!
        case 2:
            return countDic[.backSection]!
        case 3:
            return countDic[.leftSection]!
        default:
            return countDic[.frontSection]!
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 0:
            return countDic[.frontRow]!
        case 1:
            return countDic[.rightRow]!
        case 2:
            return countDic[.backRow]!
        case 3:
            return countDic[.leftRow]!
        default:
            return countDic[.frontRow]!
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 0:
            let cellA = collectionFrontView.dequeueReusableCell(withReuseIdentifier: "frontCell", for: indexPath) as! HoleCollectionViewCell
            let labelA = cellA.frontCount!
            return HoleView(viewName: .front, viewSection: .frontSection, viewRow: .frontRow,label: labelA , cellA, indexPath)
        case 1:
            let cellB = collectionRightView.dequeueReusableCell(withReuseIdentifier: "rightCell", for: indexPath) as! HoleCollectionViewCell
            let labelB = cellB.rightCount!
            return HoleView(viewName: .right, viewSection: .rightSection, viewRow: .rightRow,label: labelB , cellB, indexPath)
        case 2:
            let cellC = collectionBackView.dequeueReusableCell(withReuseIdentifier: "backCell", for: indexPath) as! HoleCollectionViewCell
            let labelC = cellC.backCount!
            return HoleView(viewName: .back, viewSection: .backSection, viewRow: .backRow, label: labelC, cellC, indexPath)
        case 3:
            let cellD = collectionLeftView.dequeueReusableCell(withReuseIdentifier: "leftCell", for: indexPath) as! HoleCollectionViewCell
            let labelD = cellD.leftCount!
            return HoleView(viewName: .left, viewSection: .leftSection, viewRow: .leftRow, label: labelD, cellD, indexPath)
        default:
            let cell = collectionFrontView.dequeueReusableCell(withReuseIdentifier: "frontCell", for: indexPath) as! HoleCollectionViewCell
            let label = cell.frontCount!
            return HoleView(viewName: .front, viewSection: .frontSection, viewRow: .frontRow,label: label, cell, indexPath)
        }
    }
//    --------------------------------------------------
//    func生成cell畫面
    func HoleView(viewName view:viewName,viewSection:countName,viewRow:countName,label: UILabel, _ cell:HoleCollectionViewCell,_ indexPath:IndexPath)-> HoleCollectionViewCell {
        
        var engRow = engArr[indexPath.row]
        var id = "\(engRow)\(indexPath.section)"
        
        
        if indexPath.section < (countDic[viewSection]! - 1) && indexPath.row < (countDic[viewRow]! - 1) &&
            indexPath.section > 0 && indexPath.row > 0{
            
            //生成中心孔洞樣式normal
            //取得ID
            engRow = engArr[indexPath.row - 1]
            id = "\(engRow)\(indexPath.section)"
            
            var allHoleData = offlineData?.viewFront?.holeData
            cell.delegate = self
            label.text = id
            label.backgroundColor = holeTypeDic["empty"]
            
            switch view {
            case .front:
                id = "front" + id
                cell.frontBtnShow.isHidden = false
                cell.frontBtnShow.setTitle(id, for: .normal)
                allHoleData = offlineData?.viewFront?.holeData
            case .right:
                id = "right" + id
                cell.rightBtnShow.isHidden = false
                cell.rightBtnShow.setTitle(id, for: .normal)
                allHoleData = offlineData?.viewRight?.holeData
            case .back:
                id = "back" + id
                cell.backBtnShow.isHidden = false
                cell.backBtnShow.setTitle(id, for: .normal)
                allHoleData = offlineData?.viewBack?.holeData
            case .left:
                id = "left" + id
                cell.leftBtnShow.isHidden = false
                cell.leftBtnShow.setTitle(id, for: .normal)
                allHoleData = offlineData?.viewLeft?.holeData
            default:
                break
            }
            
            if let haveData = checkHoleData(id: id, view: view, allHoleData: allHoleData){
                //有資料則更改樣式
                label.text = haveData.pipeCount
                label.backgroundColor = holeTypeDic[haveData.pipeType ?? "empty"]
                cell.holeData = passHoleData(holeID: id, holeData: haveData)
                
            }else{

                cell.holeData = passHoleData(holeID: id, holeData: nil)
            }
            
            
            
            
            
        }else{
            switch view {
            case .front:
                cell.frontBtnShow.isHidden = true
                cell.frontBtnShow.setTitle("", for: .normal)
            case .right:
                cell.rightBtnShow.isHidden = true
                cell.rightBtnShow.setTitle("", for: .normal)
            case .back:
                cell.backBtnShow.isHidden = true
                cell.backBtnShow.setTitle("", for: .normal)
            case .left:
                cell.leftBtnShow.isHidden = true
                cell.leftBtnShow.setTitle("", for: .normal)
            default:
                break
            }
            
            if indexPath.section == 0 && indexPath.row == (countDic[viewRow]! - 1){
                //右上 增加欄
                label.text = "+"
            }else if indexPath.section == (countDic[viewSection]! - 1) && indexPath.row == 0{
                //左下 增加列
                label.text = "+"
            }else if indexPath.section == 0 && indexPath.row != 0{
                //title 列（英文）
                label.text = engArr[indexPath.row - 1]
            }else if indexPath.section != 0 && indexPath.row == 0{
                //title 欄（數字）
                label.text = String(indexPath.section)
            }else if indexPath.section == (countDic[viewSection]! - 1) && indexPath.row == (countDic[viewRow]! - 1){
                // - 欄列
                engRow = engArr[indexPath.row - 1]
                label.text = "-"
            }else{
                label.text = ""
            }
            label.backgroundColor = holeTypeDic["tool"]
        }
        label.layer.cornerRadius = label.frame.height / 2
        label.clipsToBounds = true
        
        return cell

    }
    
    
    
    
    
//    --------------------------------------------------
//    點擊cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView.tag {
        case 0:
            HoleBtn(viewName: .front,viewSection: .frontSection, viewRow: .frontRow, indexPath)
        case 1:
            HoleBtn(viewName: .right,viewSection: .rightSection, viewRow: .rightRow, indexPath)
        case 2:
            HoleBtn(viewName: .back,viewSection: .backSection, viewRow: .backRow, indexPath)
        case 3:
            HoleBtn(viewName: .left,viewSection: .leftSection, viewRow: .leftRow, indexPath)
        default:
            break
        }
    }
    // func add/delete cell action
    func HoleBtn(viewName: viewName, viewSection:countName,viewRow:countName,_ indexPath:IndexPath){
        //cell func 新增 刪除 -------------------------
        //func 刪除欄列
        func cellDelete(){
            if indexPath.row < 3 || indexPath.section < 3{
                cellLimitAlert(str: "欄位不可刪除")
            }else{
                let newValR = countDic[viewRow]! - 1
                countDic.updateValue(newValR, forKey: viewRow)
                let newValS = countDic[viewSection]! - 1
                countDic.updateValue(newValS, forKey: viewSection)
                reloadCollection(viewName: viewName)
            }
        }
        //func 增加欄列
        func cellAdd(){
            if indexPath.row > 20 || indexPath.section > 20{
                cellLimitAlert(str: "已達欄位上限！")
            }else{
                let newValR = countDic[viewRow]! + 1
                countDic.updateValue(newValR, forKey: viewRow)
                let newValS = countDic[viewSection]! + 1
                countDic.updateValue(newValS, forKey: viewSection)
                reloadCollection(viewName: viewName)
            }
        }
        
        
        //cell btn -------------------------
        if indexPath.section == 0 && indexPath.row == (countDic[viewRow]! - 1){
            //增加欄
            cellAdd()
        }else if indexPath.section == (countDic[viewSection]! - 1) && indexPath.row == 0{
            //增加列
            cellAdd()
        }else if indexPath.section == (countDic[viewSection]! - 1) && indexPath.row == (countDic[viewRow]! - 1){
            //刪除欄列
            //判斷欄列有無資料
            let idSecNum = indexPath.section - 1
            let idRowNum = indexPath.row - 1
            
            var lastHoldData = true
            for i in 1...idRowNum{
                let idSecEng = engArr[i - 1]
                var idSec:String = idSecEng + "\(idSecNum)"
                let idRowEng = engArr[idRowNum - 1]
                var idRow:String = idRowEng + "\(i)"
                
                var allHoleData:[SingleHoleData]?
                switch viewName {
                case .front:
                    idSec = "front" + idSec
                    idRow = "front" + idRow
                    allHoleData = offlineData?.viewFront?.holeData
                case .right:
                    idSec = "right" + idSec
                    idRow = "right" + idRow
                    allHoleData = offlineData?.viewRight?.holeData
                case .back:
                    idSec = "back" + idSec
                    idRow = "back" + idRow
                    allHoleData = offlineData?.viewBack?.holeData
                case .left:
                    idSec = "left" + idSec
                    idRow = "left" + idRow
                    allHoleData = offlineData?.viewLeft?.holeData
                default:
                    break
                }
                
                if checkHoleData(id: idSec, view: viewName, allHoleData: allHoleData) != nil{
                    cellLimitAlert(str: "有資料不可刪除欄列")
                    break
                }
                if checkHoleData(id: idRow, view: viewName, allHoleData: allHoleData) != nil{
                    cellLimitAlert(str: "有資料不可刪除欄列")
                    break
                }else if i == idRowNum{
                    //將被刪除的最後一個欄位也無值時
                    lastHoldData = false
                }
            }
            if lastHoldData == false {
                cellDelete()
            }
            
        }else{
            
        }

    }
    //cell limit alert
    func cellLimitAlert(str:String){
        let cellAlert = UIAlertController(title: "\(str)", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .cancel) { action in }
        cellAlert.addAction(cancel)
        present(cellAlert, animated: true, completion: nil)
        
    }
    

    
    
    
    
    
    
    
//    --------------------------------------------------
//    segue傳值
    func callForm(cellData:passHoleData){
        //孔洞被點擊觸發開啟from
        performSegue(withIdentifier: "frontBtnCall", sender: cellData)
        
        let goAlbum = UIStoryboard(name: "From", bundle: nil).instantiateViewController(withIdentifier: "formPage")
        present(goAlbum, animated: true, completion: nil)
        
        //暫時：有點開form即算有編輯
        edited = true
        
        //測試append or edit data
//        let nowAllData = offlineData?.viewFront?.holeData
//        let thisHole = checkHoleData(id: holeID, view: .front, allHoleData: nowAllData)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // btn to form
        if segue.identifier == "frontBtnCall"{
            if let formView = segue.destination as? FormViewController{
                formView.delegate = self
                if #available(iOS 13.0, *) {
                    formView.isModalInPresentation = true
                } else {
                    // Fallback on earlier versions
                }
                
                if let cellData = sender as? passHoleData{
                    
                    let id = cellData.holeID
                    let holedata = cellData.holeData
                    
                    formView.idtoFrom = id
                    formView.objtoFrom = holedata
                }
                
            }
        }
        // btn to album
        if segue.identifier == "gotoAlbum"{
            if let albumView = segue.destination as? AlbumViewController{
                albumView.delegate = self
                
            }
            
        }
    }
    
    //    --------------------------------------------------
    // func 以 holeID 搜尋目前是否有data -> 回傳單筆資料 or nil
    func checkHoleData(id:String,view:viewName,allHoleData:[SingleHoleData]?) -> SingleHoleData?{
        
        if let okData = allHoleData{
            if okData.count != 0{
                //for迴圈跑每一筆孔洞資料
                for i in 0...(okData.count - 1){
  
                    //尋找所需ID
                    if okData[i].holeID != id{
                        if i == (okData.count - 1){
                            return nil
                        }
                    }else if okData[i].holeID == id{
                        
                        return okData[i]
                        break
                    }
                }
            }else{
                return nil
            }
        }else{
            return nil
        }
        return nil
        
    }
    
    

    
    
    
    
    


    
//      --------------------------------------------------
//      func uploadData 上傳資料至後台
    func uploadData(savepage:Int?){
        print("upload page:\(savepage)")
        
        //save
//        switch savepage {
//        case 0:
//            returnData0 = getData
//
//        case 1:
//            returnData1 = getData
//
//        case 2:
//            returnData2 = getData
//
//        case 3:
//            returnData3 = getData
//
//        default:
//            getData = []
//        }
        
        //loading
        loadData()
        edited = false
    }
    
//      --------------------------------------------------
//      func loadData 下載後台資料：下載資料與json解析
    var apiAddress = "http://220.128.156.191:8160/js/holeDataFront.json"
    var urlSession = URLSession(configuration: .default) //用來下載資料的urlsession(共時佇列)
    
    func loadData(){
        print("download page:\(nowPage)")
        imgArrMore = []
        
        switch nowPage {
        case 0:
            apiAddress = "http://220.128.156.191:8160/js/holeDataFront.json"
            
        case 1:
            apiAddress = "http://220.128.156.191:8160/js/holeDataRight.json"
            
        case 2:
            apiAddress = "http://220.128.156.191:8160/js/holeDataBack.json"
            
        case 3:
            apiAddress = "http://220.128.156.191:8160/js/holeDataLeft.json"
            
        default:
            print("nowPage count wrong")
        }
        
        downloadInfo(withAddress: apiAddress)
        edited = false
        
    }
    //      --------------------------------------------------
    //下載資料與json解析

        func downloadInfo(withAddress webAddress:String){
            if let url = URL(string: webAddress){ //產生url實體
                //以此URL及clouser建立下載任務
                let task = urlSession.dataTask(with: url, completionHandler: {
                    (data, response, error) in
                    
                    //error 先判斷有無錯誤，有則取得代碼
                    if error != nil{
                        let errorCode = (error! as NSError).code
                        if errorCode == -1009{
                            //以主佇列執行alert
                            DispatchQueue.main.async {
                                self.popAlert(withTitle: "沒有網路")
                            }
                        }else{
                            DispatchQueue.main.async {
                                self.popAlert(withTitle: "download has error")
                                
                            }
                        }
                        return
                    }
                    //data 如果成功下載資料
                    if let loadedData = data{
                        do{
                            let okData = try JSONDecoder().decode(AllData.self, from: loadedData)
                            offlineData = okData
                            
                            //顯示tableView資料
                            if offlineData != nil{
                                let userName = offlineData!.userName!
                                let manHoleZone = offlineData!.manHoleZone!
                                let manHoleRd = offlineData!.manHoleRd!
                                let manHoleID = offlineData!.manHoleID!
                                self.contentArray = [userName,manHoleZone,manHoleRd,manHoleID]
                            }
                            
                            
                            //更新行列數
                            if offlineData?.viewFront?.section != nil{
                                    print("in view front")
                                    countDic[.frontSection] = Int(offlineData?.viewFront?.section ?? "6")!
                                    countDic[.frontRow] = Int(offlineData?.viewFront?.row ?? "6")!
                            }else if offlineData?.viewRight?.section != nil{
                                print("in view right")
                                countDic[.rightSection] = Int(offlineData?.viewRight?.section ?? "6")!
                                countDic[.rightRow] = Int(offlineData?.viewRight?.row ?? "6")!
                            }else if offlineData?.viewBack?.section != nil{
                                print("in view back")
                                countDic[.backSection] = Int(offlineData?.viewBack?.section ?? "6")!
                                countDic[.backRow] = Int(offlineData?.viewBack?.row ?? "6")!
                            }else if offlineData?.viewLeft?.section != nil{
                                print("in view left")
                                countDic[.leftSection] = Int(offlineData?.viewLeft?.section ?? "6")!
                                countDic[.leftRow] = Int(offlineData?.viewLeft?.row ?? "6")!
                            }
    
                            
                            //成功下載資料後，重新產生畫面
                            DispatchQueue.main.async {
                            switch nowPage {
                            case 0:
                                self.reloadCollection(viewName: .front)
                                
                            case 1:
                                self.reloadCollection(viewName: .right)
                                
                            case 2:
                                self.reloadCollection(viewName: .back)
                                
                            case 3:
                                self.reloadCollection(viewName: .left)
                                
                            default:
                                print("nowPage count wrong")
                            }
                                //重設相簿數量
                                self.setAlbumCount()
                            }
                        }catch{
                            DispatchQueue.main.async {
                                self.popAlert(withTitle: "data can't decode")
                            }
                        }
                        
                    }
                })
                task.resume() //執行下載任務
            }
        }
        func popAlert(withTitle title:String){
            let alert = UIAlertController(title: title, message: "please try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    
    
    
    
    
    
    
    

//    --------------------------------------------------
//    datasource setting
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nowPage = 0
        loadData()
        
        collectionFrontView.dataSource = self
        collectionFrontView.delegate = self
        collectionRightView.dataSource = self
        collectionRightView.delegate = self
        collectionBackView.dataSource = self
        collectionBackView.delegate = self
        collectionLeftView.dataSource = self
        collectionLeftView.delegate = self
        
        
        // Do any additional setup after loading the view.
        
        
        

    }

    
    override func viewDidAppear(_ animated: Bool) {
        
        
        //scrollView contentSize寬度設定
        let scrollWidth = (mainScrollView.frame.width) * 4
        mainScrollView.contentSize = CGSize(width: scrollWidth, height: 0)
        print("viewDidAppear")
        setAlbumCount()
        
    }
    
    var isRotate = false //判斷螢幕是否被旋轉
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        // 此func不使用
        // 這裡的變數 size 為superview(not save area)
        // 於此階段執行 reloadCollection 會得到錯誤寬度（非旋轉後寬度）
        
    }
    override func viewSafeAreaInsetsDidChange() {
        
        // 此階段 mainScrollView.frame.width 非旋轉後寬度
        // 於此階段執行 reloadCollection 可得到正確寬度
        isRotate = true
        reloadCollection(viewName: .front)
        reloadCollection(viewName: .right)
        reloadCollection(viewName: .back)
        reloadCollection(viewName: .left)
        

    }

}

