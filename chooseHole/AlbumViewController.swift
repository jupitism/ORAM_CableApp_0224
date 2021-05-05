//
//  AlbumViewController.swift
//  chooseHole
//
//  Created by Youko Chen on 2021/2/1.
//  Copyright © 2021 youkochen. All rights reserved.
//

import UIKit

//AlbumDelegat(刪除照片後返回會改變相簿顯示數值)
protocol AlbumDelegat{
    func setAlbumCount()
}

// 自訂protocol: imgCellDelegate (AlbumCollectionViewCell)
class AlbumViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,imgCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate {

    
    @IBOutlet weak var collectionAlbum: UICollectionView!
    @IBOutlet weak var imageBig: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var scrollZoom: UIScrollView!
    
    var scrollW:CGFloat?
    var scrollH:CGFloat?
    
    var delegate:AlbumDelegat?
    
    
    
    
    
    @IBAction func btnBack(_ sender: UIButton) {
        //返回
        dismiss(animated: true, completion: nil)
    }
    @IBAction func btnTakePhotoAlbum(_ sender: UIButton) {
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
            setBigImg(image: image)
//            setAlbumCount()
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
        collectionAlbum.reloadData()
        
        
    }
    //    --------------------------------------
    //    設定照片比例
    //設定UIImageView比例同照片
    func setBigImgSize(image:UIImage) -> CGRect{
        let imgSize = image.size
        let imgWidth = imgSize.width
        let imgHeight = imgSize.height
        let imgRatio = imgHeight / imgWidth
        
        var maxWidth:CGFloat = scrollW!
        var maxHeight:CGFloat = scrollH!
        var siteX:CGFloat = 0
        var siteY:CGFloat = 0
        print(imgRatio)
        
        let scrollRatio:CGFloat = scrollH! / scrollW!
        if imgRatio <= scrollRatio{
            print("_")
            //fit
            maxHeight = maxWidth * imgRatio
            siteY = (scrollH! - maxHeight) / 2
            //full
//            maxWidth = maxHeight / imgRatio
//            siteX = (scrollW! - maxWidth) / 2

        }else if imgRatio > scrollRatio{
            print("|")
            //fit
            maxWidth = maxHeight / imgRatio
            siteX = (scrollW! - maxWidth) / 2
            //full
//            maxHeight = maxWidth * imgRatio
//            siteY = (scrollH! - maxHeight) / 2
        }

        return CGRect(x: siteX, y: siteY,width: maxWidth, height: maxHeight)
    }
    //顯示大圖
    func setBigImg(image:UIImage){
        //重置縮放
        self.scrollZoom.zoomScale = 1
        
        let imgSize = setBigImgSize(image: image)
        imageBig.frame = imgSize
        imageBig.image = image
    }
    
    
    
    //    --------------------------------------
    //    圖片縮放
    //誰要被縮放
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageBig
    }
    //縮放中
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        //print("ViewDidZoom")
    }
    //開始縮放：座標設為00
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        //print("BeginZoom")
        if scrollZoom.zoomScale == 1{
            if let imgok = imageBig.image{
                let imgSize = setBigImgSize(image: imgok)
                self.imageBig.frame = CGRect(x: 0, y: 0, width: imgSize.width, height: imgSize.height)
            }
        }
    }
    //結束縮放：縮放比為1時，座標置中
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        //print("EndZoom")
        if scrollZoom.zoomScale == 1{
            if let imgok = imageBig.image{
                let imgSize = setBigImgSize(image: imgok)
                self.imageBig.frame = imgSize
            }
        }
    }
    
    
    //    --------------------------------------
    //    delete photo 從cell透過protocol傳值並執行此func
        func imgDeleteAlert(num:Int){
            if let haveImg = imgArrMore?[num]{
                setBigImg(image: haveImg)
            }
            
            let alertDelete = UIAlertController(title: "確定要移除此照片？", message: nil, preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "取消", style: .cancel) { action in }
            let delete = UIAlertAction(title: "移除", style: .default) { action in
                self.imgDelete(num: num)
            }
            alertDelete.addAction(cancel)
            alertDelete.addAction(delete)
            present(alertDelete, animated: true, completion: nil)
        }
        func imgDelete(num: Int) {
            print("delete num:\(num)")
            imgArrMore?.remove(at: num)
            collectionAlbum.reloadData()
            edited = true
            
            if let imgCount = imgArrMore?.count{
                if imgCount == 0{
                    //完全沒有照片
                    imageBig.image = nil
                }else if num < imgCount{
                    //後面還有照片
                    if let haveImg = imgArrMore?[num]{
                        setBigImg(image: haveImg)
                    }
                }else if  num >= imgCount{
                    //後面沒有照片
                    if let haveImg = imgArrMore?[num - 1]{
                        setBigImg(image: haveImg)
                    }
                }
            }
        }
    
    //    --------------------------------------
    //    size
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
            let size = (collectionAlbum.frame.width - 2) / 3

            return CGSize(width: size, height: size)
        }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 1
        }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 1
        }

    //    --------------------------------------
    //    Collection func
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return imgArrMore?.count ?? 0
        }
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imagesCell", for: indexPath) as! AlbumCollectionViewCell

            //與cell傳值用
            cell.clearBtnShow.tag = indexPath.row
            cell.delegate = self
            
            

            if let count = imgArrMore?.count{
                let num = indexPath.row
                if num + 1 <= count{
                    cell.imageCell.image = imgArrMore?[num]
                    cell.clearBtnShow.isHidden = false
                }else{
                    //indexPath.row會跳動，需設定無圖位置清除
                    cell.imageCell.image = nil
                    cell.clearBtnShow.isHidden = true
                }

            }

            return cell
        }
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            //點擊縮圖顯示大圖
            if let count = imgArrMore?.count{
                let num = indexPath.row
                if num + 1 <= count{
                    if let haveImg = imgArrMore?[num]{
                        setBigImg(image: haveImg)
                    }
                }else{
                    print("no img")
                }
                
            }
            
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch nowPage{
        case 0:
            albumName.text = "前視圖 相簿"
        case 1:
            albumName.text = "右視圖 相簿"
        case 2:
            albumName.text = "後視圖 相簿"
        case 3:
            albumName.text = "左視圖 相簿"
        default:
            albumName.text = "相簿"
        }
        
        
        collectionAlbum.dataSource = self
        collectionAlbum.delegate = self
        
        //get scrollView size
        scrollW = scrollZoom.frame.width
        scrollH = scrollZoom.frame.height
        
        //show bigimage
        if imgArrMore?.count != 0{
            let new = Int(imgArrMore!.count) - 1
            if let haveImg = imgArrMore?[new]{
                setBigImg(image: haveImg)
            }
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        collectionAlbum.reloadData()
        
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func viewWillDisappear(_ animated: Bool) {
        
        print("close album")
        
        self.delegate?.setAlbumCount()
        

    }

}
