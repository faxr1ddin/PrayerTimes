//
//  PrayerTimeViewController.swift
//  PrayerTimes_Demo
//
//  Created by Faxriddin Mo'ydinxonov on 13/06/23.
//

import UIKit
import SnapKit
import CoreLocation
import Alamofire

class PrayerTimeViewController: BaseViewController {
    
    //MARK: - ProPorties
    
    let backroundImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named:"backgroundImage")
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Hozirgi vaqt"
        label.font = .monospacedDigitSystemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 55, weight: .heavy)
        label.textColor = .white
        return label
    }()
    
    let countryLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    //Blur
    
    let blurEffect = UIBlurEffect(style: .light)
    
    let blurView: UIVisualEffectView = {
        let view = UIVisualEffectView()
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()
    
    let nextPrayerName: UILabel = {
        let label = UILabel()
        label.text = "Keyingi namoz"
        label.font = .monospacedDigitSystemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        return label
        
    }()
    
    let prayerName: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 32, weight: .heavy)
        label.textColor = .white
        return label
    }()
    
    let prayerTime: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        return label
        
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.layer.cornerRadius = 10
        return tableView
    }()
    
    //variables
    var manager: CLLocationManager?
    var apiResult: TimeList?
    var arrayData = [String]()
    var timer: Timer?
    
    //constants
    let viewModel = PrayerTimesViewModel()
    let tableData = ["Bomdod" , "Peshin" , "Asr" , "Shom" , "Xufton"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //viewSettings
        
        initView()
        updateCurrentTime()
        startTimer()
        
        viewModel.locationSettings {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        //navigation
        
        self.title = "Namoz Vaqtlari"
//        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    //viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //get location
        
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        manager?.requestWhenInUseAuthorization()
        manager?.startUpdatingLocation()
        
    }
    
    //update currentTime and until prayer time
    func startTimer() {
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self , selector: #selector(updateCurrentTime), userInfo: nil , repeats: true)
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
        RunLoop.current.add(timer!, forMode: .default)
        
        updateTimer()
    }
    
    //call calculateTimeUntilNextPrayer
    @objc func updateTimer() {
        
        guard let currentLocation = manager?.location else {
            return
        }
        
        getAddress(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        viewModel.findUserLocation(forLocation: currentLocation) {
            self.viewModel.calculateTimeUntilPrayer { prayerMessage, timeUntilNextPrayer in
                DispatchQueue.main.async {
                    self.prayerName.text = "\(prayerMessage)"
                    self.prayerTime.text = "ga \(timeUntilNextPrayer) qoldi"
                }
            }
            self.tableView.reloadData()
        }
            
    }
    
    //initView
    func initView() {
        
        //backroundImage
        
        view.addSubview(backroundImage)
        backroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        //textLabel
        
        backroundImage.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.snp.centerY).multipliedBy(0.36)
        }
        
        //timeLabel
        
        backroundImage.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(textLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        //countryLabel
        
        backroundImage.addSubview(countryLabel)
        countryLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(timeLabel.snp.bottom).offset(5)
        }
        
        //blurView
        
        backroundImage.addSubview(blurView)
        blurView.effect = blurEffect
        blurView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(countryLabel.snp.bottom).offset(15)
            make.width.equalTo(view.snp.width).multipliedBy(0.86)
            make.height.equalTo(view.snp.height).multipliedBy(0.16)
        }
        
        //nextPrayerName
        
        blurView.contentView.addSubview(nextPrayerName)
        nextPrayerName.snp.makeConstraints { make in
            make.top.equalTo(blurView.snp.top).offset(15)
            make.centerX.equalToSuperview()
        }
        
        //prayerName
        
        blurView.contentView.addSubview(prayerName)
        prayerName.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nextPrayerName.snp.bottom).offset(5)
        }
        
        //prayerTime
        
        blurView.contentView.addSubview(prayerTime)
        prayerTime.snp.makeConstraints { make in
            make.top.equalTo(prayerName.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        //tableView
        
        backroundImage.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(blurView.snp.bottom).offset(25)
            make.width.equalTo(view.snp.width).multipliedBy(0.86)
            make.height.equalTo(view.snp.height).multipliedBy(0.36)
        }
    }
    
    // Get location
    func getAddress(latitude: Double, longitude: Double) {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geoCoder.reverseGeocodeLocation(location) { [self] (placemarks, error) in
            guard let placemark = placemarks?.first else {
                return
            }
            
            // City
            if let country = placemark.country, let city = placemark.administrativeArea {
                countryLabel.text = "\(city), \(country)"
            }
        }
    }
    
    //update currentTime
    @objc func updateCurrentTime() {
        
        //time format
        
        let timeFormater = DateFormatter()
        timeFormater.dateFormat = "HH:mm"
        
        let time = timeFormater.string(from: Date())
        timeLabel.text = time
        
    }
    
}

//TableView

extension PrayerTimeViewController: UITableViewDelegate , UITableViewDataSource {
    
    //UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.prayerTimesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //change cell style
        var cell: UITableViewCell!
        cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        //use textLabel and detailTextLabel
        cell.textLabel?.text = tableData[indexPath.row]
        cell.detailTextLabel?.text = viewModel.prayerTimesArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let headerTitle: String = "Bugungi namoz vaqtlari"
        return headerTitle
    }
    
}

//Get Location

extension PrayerTimeViewController: CLLocationManagerDelegate {
    
    //CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //call getAddress func
        guard let location = locations.first else { return }
        getAddress(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        //request permission
        switch status {
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied or restricted.")
        default:
            break
        }
    }
}
