//
//  ViewController.swift
//  MapApp1
//
//  Created by Raphael on 2020/11/01.
//  Copyright © 2020 Raphael. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    //※グローバル宣言でないとダメ（ローカルだと認証アラートがすぐ消える）
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        searchBar.delegate = self

        setupLocationManager()
        
        //pointToTokyoStation()
        
    }
//MARK:-サーチバー
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // キーボードを閉じる
        view.endEditing(true)
        // 入力された値がnilでなければif文のブロック内の処理を実行
        if let word = searchBar.text {
            // デバッグエリアに出力
            print(word)
            geocodeing(address: word)
            
        }
    }
//MARK:-現在位置からスタート
    func setupLocationManager() {

        locationManager = CLLocationManager()
        guard locationManager != nil else { return }
        locationManager.requestWhenInUseAuthorization()

        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            locationManager.delegate = self
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
        }
    }
    //現在位置を取得
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let latitude = locations.first?.coordinate.latitude
        let longitude = locations.first?.coordinate.longitude
        
        // 緯度・軽度を設定
        let location = CLLocationCoordinate2DMake(latitude!, longitude!)
        // マップビューに緯度・軽度を設定
        mapView.setCenter(location, animated:true)

        // 縮尺を設定
        var region = mapView.region
        region.center = location
        region.span.latitudeDelta = 0.02
        region.span.longitudeDelta = 0.02
        // マップビューに縮尺を設定
        mapView.setRegion(region, animated:true)
        
        //現在地ピンを立てる
        currentLocation(targetCoordinate: location)
        
        //座標から住所を割り出す
        reverseGeocoding(latitude: latitude!, longitude: longitude!)
    }

//MARK:-東京駅を指す
    func pointToTokyoStation(){
        // 東京駅の位置情報を設定（緯度: 35.681236 経度: 139.767125）
        let latitude = 35.681236
        let longitude = 139.767125
        // 緯度・軽度を設定
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        // マップビューに緯度・軽度を設定
        mapView.setCenter(location, animated:true)

        // 縮尺を設定
        var region = mapView.region
        region.center = location
        region.span.latitudeDelta = 0.02
        region.span.longitudeDelta = 0.02
        // マップビューに縮尺を設定
        mapView.setRegion(region, animated:true)
    }
    
//MARK:-ジオコーディング（住所→座標）
    func geocodeing(address:String){
        
        CLGeocoder().geocodeAddressString(address) { placemarks, error in
            
            if let placemarks = placemarks{
                let lat = placemarks.first?.location?.coordinate.latitude
                print("緯度 : \(lat!)")
                let latitude = lat!
            
                let log = placemarks.first?.location?.coordinate.longitude
                print("経度 : \(log!)")
                let longitude = log!
                
                self.addressLabel.text = "緯度：\(latitude)\n経度：\(longitude)"
                
                //makeAPin()へ
                let targetCoordinate = placemarks.first?.location?.coordinate
                self.makeAPin(targetCoordinate: targetCoordinate!, searchKey: address)
            }
        }
    }
    
//MARK:-逆ジオコーディング（座標→住所）
    func reverseGeocoding(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        
        var addressString = ""
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            
            guard let placemark = placemarks?.first, error == nil else { return }
            
                //placemarkの都道府県がnilじゃなく、またはplacemarkの市区町村がnilじゃなかったら
                if placemark.administrativeArea != nil || placemark.locality != nil{
                    //pmの名前+pmの都道府県+pmの市区町村をaddressStringとする
                    addressString = placemark.administrativeArea! + placemark.locality! + placemark.name!
                    
                //placemarkの都道府県またはpmの市区町村がnilだったら
                }else{
                    //placemarkの名前をaddressStringとする
                    addressString = placemark.name!
                }
                //アドレスラベルに住所を表示する
                self.addressLabel.text = addressString

        }
    }
//MARK:-マップ上にピンを置く
    func makeAPin(targetCoordinate:CLLocationCoordinate2D,searchKey:String){
        
        //MKPointAnnotationインスタンスを取得し、ピンを生成
         let pin = MKPointAnnotation()

        //ピンの置く場所に緯度経度を設定
         pin.coordinate = targetCoordinate

        //ピンのタイトルを設定
         pin.title = searchKey

        //ピンを地図に置く
         self.mapView.addAnnotation(pin)

        //検索地点の緯度経度を中心に半径500mの範囲を表示
         self.mapView.region = MKCoordinateRegion(center: targetCoordinate, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
    }
//MARK:-マップ上にピンを置く（現在地）
    func currentLocation(targetCoordinate:CLLocationCoordinate2D){
        
        //MKPointAnnotationインスタンスを取得し、ピンを生成
         let pin = MKPointAnnotation()

        //ピンの置く場所に緯度経度を設定
         pin.coordinate = targetCoordinate

        //ピンのタイトルを設定
         pin.title = "現在地"

        //ピンを地図に置く
         self.mapView.addAnnotation(pin)

        //検索地点の緯度経度を中心に半径500mの範囲を表示
         self.mapView.region = MKCoordinateRegion(center: targetCoordinate, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
    }

}

