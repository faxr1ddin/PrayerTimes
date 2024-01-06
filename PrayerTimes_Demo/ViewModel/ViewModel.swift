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
    
    //calculateTimeUntilPrayer
    func calculateTimeUntilPrayer(completion: @escaping (String, String) -> Void) {
        
        //currentTime
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let currentTime = dateFormatter.string(from: currentDate)
        
        //if all prayer time passed for today
        guard let nextPrayerTime = prayerTimesArray.first(where: { $0 > currentTime }) else {
            completion("Bomdod", "---")
            return
        }
        
        //error
        guard let nextPrayerIndex = prayerTimesArray.firstIndex(of: nextPrayerTime) else {
            completion("Error identifying the next prayer.", "")
            return
        }
        
        let nextPrayer = ["Bomdod", "Peshin", "Asr", "Shom", "Hufton"][nextPrayerIndex]
        
        //format
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        //error
        guard let currentTimeDate = formatter.date(from: currentTime),
              let nextPrayerTimeDate = formatter.date(from: nextPrayerTime) else {
            completion("Error calculating time until the next prayer.", "")
            return
        }
        
        let timeDifference = nextPrayerTimeDate.timeIntervalSince(currentTimeDate)
        
        let hours = Int(timeDifference / 3600)
        let minutes = Int((timeDifference.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(timeDifference.truncatingRemainder(dividingBy: 60))
        
        //format HH:mm or mm:ss
        let timeUntilNextPrayer: String
        if hours > 0 {
            timeUntilNextPrayer = String(format: "%02d soat %02d daqiqa", hours, minutes)
        } else {
            timeUntilNextPrayer = String(format: "%02d daqiqa %02d soniya", minutes, seconds)
        }
        
        completion(nextPrayer, timeUntilNextPrayer)
        
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

