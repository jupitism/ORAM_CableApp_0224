//
//  ViewController.swift
//  mapLocation
//
//  Created by 陳韻嬛 on 2021/1/21.
//

import UIKit
import MapKit
import CoreLocation

var locationData: LocationData?

class ViewController: UIViewController ,CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    
    //xy座標label
    @IBOutlet weak var codeX: UILabel!
    @IBOutlet weak var codeY: UILabel!
    
    // 手動定位欄位
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var roadLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!

    @IBAction func maptoHoleView(_ sender: UIButton) {
        gotoHoleView()
    }
    
    //btn 重取定位
    @IBAction func regetLocation(_ sender: UIButton) {
        if CLLocationManager.authorizationStatus()
            == .denied {
            // 提示可至[設定]中開啟權限
            let alertController = UIAlertController(title: "定位權限已關閉", message: "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟", preferredStyle: .alert)
            let okAction = UIAlertAction( title: "確認", style: .default, handler:nil)
            alertController.addAction(okAction)
            self.present( alertController, animated: true, completion: nil)
            print("ask again")
        }
        // 使用者已經同意定位自身位置權限
        else if CLLocationManager.authorizationStatus()
                    == .authorizedWhenInUse {
            getLocation()
            print("have priv")
            alertPOP(message: "已重新定位")
        }
    }
    
    var locationManager = CLLocationManager()
    let returnSite = ["中路地區","中山路一段","TF-450"] //暫時直接填入
    
    //func alert
    func alertPOP(message:String){
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確認", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
//    -----------------------------------
//    取得使用者定位 getLocation
    func getLocation(){
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization() //詢問授權
        
        
        //顯示地圖
        //取得座標
        if let coordinate = locationManager.location?.coordinate{
            //設定放大比
            let xScale:CLLocationDegrees = 0.01
            let yScale:CLLocationDegrees = 0.01
            let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: yScale, longitudeDelta: xScale)
            
            //要顯示的範圍：座標＋放大比
            let region = MKCoordinateRegion(center: coordinate, span: span)
            map.setRegion(region, animated: true)
            
            // 大頭針
            // let annotation = MKPointAnnotation()
            // annotation.coordinate = coordinate
            // map.addAnnotation(annotation)
            
            //取得經緯度
            let latitude = coordinate.latitude
            let longitude = coordinate.longitude
            
            codeY.text = "\(latitude)"
            codeX.text = "\(longitude)"
            
            areaLabel.text = returnSite[0]
            roadLabel.text = returnSite[1]
            idLabel.text = returnSite[2]
            
        }else{
            print("catch false")
        }
    }
    
    
    
//    -----------------------------------
//    用 storyboardID 前往 HoleView.storyboard
    func gotoHoleView() {
        
        let goFirst = UIStoryboard(name: "HoleView", bundle: nil).instantiateViewController(withIdentifier: "mainView")
        
        present(goFirst, animated: true, completion: nil)
        
    }
    
//    -----------------------------------
//    即時追蹤使用者定位（暫不用）
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let userLocation: CLLocation = locations[0]
            // self.myTextField1.text = String(userLocation.coordinate.latitude)
            // self.myTextField2.text = String(userLocation.coordinate.longitude)
            
            print("didUpdateLocations")
            
            //顯示資料
            codeY.text = String(userLocation.coordinate.latitude)
            codeX.text = String(userLocation.coordinate.longitude)
            
            areaLabel.text = returnSite[0]
            roadLabel.text = returnSite[1]
            idLabel.text = returnSite[2]
            
            
            //CLGeocoder地理編碼 經緯度轉換地址位置
            CLGeocoder().reverseGeocodeLocation(userLocation) { (placemark, error) in

                if error != nil {
                    print("")
                } else {
                    if let placemark = placemark?[0] {
                        //print(placemark)
                        var address = ""
                        if placemark.subThoroughfare != nil {
                            address += placemark.subThoroughfare! + " "
                        }
                        if placemark.thoroughfare != nil {

                            address += placemark.thoroughfare! + "\n"
                        }
                        if placemark.subLocality != nil {

                            address += placemark.subLocality! + "\n"
                        }

                        if placemark.subAdministrativeArea != nil {
                            address += placemark.subAdministrativeArea! + "\n"
                        }
                        if placemark.postalCode != nil {

                            address += placemark.postalCode! + "\n"
                        }
                        if placemark.country != nil {

                            address += placemark.country!
                        }
                        // self.myTextField3.text = String(address)
                    }

                }

            }
            
            
            
        }
    
    
        //    @IBAction func changeView(_ sender: UIButton) {
        //        performSegue(withIdentifier: "goToHome", sender: nil)
        //    }
        //
        //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        if segue.identifier == "goToHome"{
        //            if let region1 = segue.destination as? homeViewController{
        //                region1.infoFromHand = myTextField1.text
        //            }
        //            if let road1 = segue.destination as? homeViewController{
        //                road1.infoFromHand2 = myTextField2.text
        //            }
        //            if let number1 = segue.destination as? homeViewController{
        //               number1.infoFromHand3 = myTextField3.text
        //            }
        //
        //        }
        //    }
    
    

    
    
    

    
//    -----------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //最佳精度
//        locationManager.requestWhenInUseAuthorization() //詢問授權
//        locationManager.startUpdatingLocation() //開始update user位置（追蹤用）
        
        map.delegate = self
        map.showsUserLocation = true //顯示位置
//        map.userTrackingMode = .follow //跟隨移動
        
                    
        getLocation()
        
        
        
        if let location = locationData {
            let area = location.area
            let road = location.road
            let id = location.id
        } else {
            print("no data")
        }
        
        
//        // 首次使用 向使用者詢問定位自身位置權限
//            if CLLocationManager.authorizationStatus()
//                == .notDetermined {
//                // 取得定位服務授權
//                locationManager.requestWhenInUseAuthorization()
//                print("first ask")
//
//                
//            }
//            // 使用者已經拒絕定位自身位置權限
//                else if CLLocationManager.authorizationStatus()
//                            == .denied {
//                    // 提示可至[設定]中開啟權限
//                    let alertController = UIAlertController(
//                      title: "定位權限已關閉",
//                      message:
//                      "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟",
//                        preferredStyle: .alert)
//                    let okAction = UIAlertAction(
//                        title: "確認", style: .default, handler:nil)
//                    alertController.addAction(okAction)
//                    self.present(
//                      alertController,
//                      animated: true, completion: nil)
//                    print("ask again")
//                }
//                // 使用者已經同意定位自身位置權限
//                else if CLLocationManager.authorizationStatus()
//                            == .authorizedWhenInUse {
//                    //
//                    getLocation()
//                    print("have priv")
//                }
        
        
        
        
    }
    
    


}

