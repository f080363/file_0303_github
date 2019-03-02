//
//  ViewController.swift
//  class_5_demo_2
//
//  Created by YU CHONKAO on 2018/1/2.
//  Copyright © 2018年 YU CHONKAO. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    var locationManger: CLLocationManager!
    var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManger = CLLocationManager()
        
        // 設定委任（取得特定資訊更新內容）
        locationManger.delegate = self
        
        // 設定移動多遠才會觸發更新位置的委任 Method
        locationManger.distanceFilter = kCLLocationAccuracyNearestTenMeters
        
        // 設定精準程度
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        
        
        
        mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        
        // 基本屬性設置
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        mapView.userTrackingMode = .follow
        
        // 初始位置設置，Delta 越小會越精準
        let latDelta = 0.05
        let longDelta = 0.05
        let currentLocationSpan: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        // 設置地圖顯示的範圍與中心點座標
        let center:CLLocation = CLLocation(latitude: 25.05, longitude: 121.515)
        let currentRegion:MKCoordinateRegion =
            MKCoordinateRegion(
                center: center.coordinate,
                span: currentLocationSpan)
        mapView.setRegion(currentRegion, animated: true)
        
        view.addSubview(mapView)
        
        // Auto Layout
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        
        // 建立一個地點圖示 (圖示預設為紅色大頭針)
        var objectAnnotation = MKPointAnnotation()
        
        objectAnnotation.coordinate = CLLocation(
            latitude: 25.036798,
            longitude: 121.499962).coordinate
        
        objectAnnotation.title = "艋舺公園"
        objectAnnotation.subtitle =
        "艋舺公園位於龍山寺旁邊，原名為「萬華十二號公園」。"
        
        mapView.addAnnotation(objectAnnotation)
        
        objectAnnotation = MKPointAnnotation()
        
        objectAnnotation.coordinate = CLLocation(
            latitude: 25.063059,
            longitude: 121.533838).coordinate
        objectAnnotation.title = "行天宮"
        objectAnnotation.subtitle =
        "行天宮是北臺灣參訪香客最多的廟宇。"
        mapView.addAnnotation(objectAnnotation)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            
            // 要求取得定位服務授權
            locationManger.requestWhenInUseAuthorization()
            
            // 開始定位自身位置
            locationManger.startUpdatingLocation()
            
        } else if CLLocationManager.authorizationStatus() == .denied {
            
            // 使用者已經拒絕定位自身位置權限
            
            // 提示可至[設定]中開啟權限
            let alertController = UIAlertController(
                title: "未開啟定位權限",
                message:
                "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟",
                preferredStyle: .alert)
            
            
            let okAction = UIAlertAction(
                title: "確認", style: .default, handler:nil)
            alertController.addAction(okAction)
            self.present(alertController,
                         animated: true,
                         completion: nil)
        } else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            // 使用者已經同意定位自身位置權限
            
            // 開始定位自身位置
            locationManger.startUpdatingLocation()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationManger.stopUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // 如果取得的是自己定位的 Pin
        if annotation is MKUserLocation {
            
            // 建立可重複使用的 MKAnnotationView
            var pinView =
                mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
            
            if pinView == nil {
                // 建立一個地圖圖示視圖
                pinView = MKAnnotationView(
                    annotation: annotation,
                    reuseIdentifier: "pin")
                
                // 設置點擊地圖圖示後額外的視圖
                pinView?.canShowCallout = false
                
                // 設置自訂圖示
                pinView?.image = UIImage(named:"user")
                
            } else {
                pinView?.annotation = annotation
            }
            return pinView
        } else {
            
            // 其中一個地點使用預設的圖示
            // 這邊比對到座標時就使用預設樣式 不再額外設置
            if annotation.coordinate.latitude
                == 25.036798 &&
                annotation.coordinate.longitude
                == 121.499962 {
                return nil
            }
            
            // 建立可重複使用的 MKPinAnnotationView
            var pinView =
                mapView.dequeueReusableAnnotationView(withIdentifier: "pin_2") as? MKPinAnnotationView
            if pinView == nil {
                
                // 建立一個大頭針視圖
                pinView = MKPinAnnotationView(
                    annotation: annotation,
                    reuseIdentifier: "pin_2")
                
                // 設置點擊大頭針後額外的視圖
                pinView?.canShowCallout = true
                
                // 會以落下釘在地圖上的方式出現
                pinView?.animatesDrop = true
                
                // 大頭針的顏色
                pinView?.pinTintColor =
                    UIColor.blue
                
                // 這邊將額外視圖的右邊視圖設為一個按鈕
                pinView?.rightCalloutAccessoryView =
                    UIButton(type: .detailDisclosure)
                
            } else {
                pinView?.annotation = annotation
            }
            
            return pinView
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 印出目前所在位置座標
        let currentLocation :CLLocation =
            locations[0] as CLLocation
        print("\(currentLocation.coordinate.latitude)")
        print(", \(currentLocation.coordinate.longitude)")
    }
}

