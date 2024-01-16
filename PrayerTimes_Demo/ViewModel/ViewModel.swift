//
//  ViewModel.swift
//  PrayerTimes_Demo
//
//  Created by Faxriddin Mo'ydinxonov on 29/12/23.
//

import Foundation
import Alamofire
import CoreLocation

class PrayerTimesViewModel: NSObject {
    
    //MARK: - Proporties
    
    //variables
    var prayerTimesArray: [String] = []
    
    //constants
    let locationManager = CLLocationManager()
    
    //locationManager settings
    func locationSettings(completion: @escaping () -> Void) {
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //findUserLocation
    func findUserLocation(forLocation location: CLLocation, completion: @escaping () -> Void) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard let placemark = placemarks?.first else {
                return
            }
            
            if let city = placemark.administrativeArea {
                print("City: \(city)")
                self.makeAPIRequest(withCity: city) {
                    completion()
                }
            } else {
                print("City information not available.")
                completion()
            }
        }
    }
    
    func calculateTimeUntilPrayer(completion: @escaping (String, String) -> Void) {
        
        //currentTime
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let currentTimeString = formatter.string(from: currentDate)
        
        //if all prayer times have passed
        guard let nextPrayerTime = prayerTimesArray.first(where: { $0 > currentTimeString }) else {
            completion("Bomdod", "---")
            return
        }
        
        //error
        guard let nextPrayerIndex = prayerTimesArray.firstIndex(of: nextPrayerTime),
              let nextPrayerTimeDate = formatter.date(from: nextPrayerTime),
              let currentTimeDate = formatter.date(from: currentTimeString) else {
            completion("Error calculating time until the next prayer.", "")
            return
        }
        
        var countdown = Int(nextPrayerTimeDate.timeIntervalSince(currentTimeDate))
        
        //untilPrayerTime
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            countdown -= 1  // Decrease time difference every second
            
            let hours = countdown / 3600
            let minutes = (countdown % 3600) / 60
            let seconds = countdown % 60
            
            let timeUntilNextPrayer: String
            if hours > 0 {
                timeUntilNextPrayer = String(format: "%02d soat %02d daqiqa", hours, minutes)
            } else {
                timeUntilNextPrayer = String(format: "%02d daqiqa %02d soniya", minutes, seconds)
            }
            
            //untilPrayerName
            let nextPrayer = ["Bomdod", "Peshin", "Asr", "Shom", "Hufton"][nextPrayerIndex]
            
            completion(nextPrayer, timeUntilNextPrayer)
            
            // stop time when reaches 0
            if countdown <= 0 {
                timer.invalidate()
            }
        }
        
        //
        RunLoop.main.add(timer, forMode: .common)
    }
    
    
    //fetch api
    func makeAPIRequest(withCity city: String, completion: @escaping () -> Void) {
        
        //time
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let formattedDate = dateFormatter.string(from: currentDate)
        
        //my api
        let apiURL = "https://api.aladhan.com/v1/timingsByAddress/\(formattedDate)?address=\(city)"
        
        //using Alamofire
        AF.request(apiURL)
            .validate()
            .responseDecodable(of: DataList.self) { response in
                switch response.result {
                case .success(let data):
                    self.prayerTimesArray = [
                        data.data.timings.Fajr,
                        data.data.timings.Dhuhr,
                        data.data.timings.Asr,
                        data.data.timings.Maghrib,
                        data.data.timings.Isha
                    ]
                    completion()
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
    }
}

//Location
extension PrayerTimesViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        manager.stopUpdatingLocation()
        findUserLocation(forLocation: location) {
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
}

