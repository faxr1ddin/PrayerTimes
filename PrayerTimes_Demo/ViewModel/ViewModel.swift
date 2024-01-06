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
    
    var prayerTimesArray: [String] = []
    let locationManager = CLLocationManager()
    
    func fetchData(completion: @escaping () -> Void) {
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func fetchPrayerTimes(forLocation location: CLLocation, completion: @escaping () -> Void) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard let placemark = placemarks?.first else {
                print("Error retrieving placemark: \(error?.localizedDescription ?? "")")
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
    
    func calculateTimeUntilNextPrayer(completion: @escaping (String, String) -> Void) {
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let currentTime = dateFormatter.string(from: currentDate)
        
        guard let nextPrayerTime = prayerTimesArray.first(where: { $0 > currentTime }) else {
            completion("All prayer times have passed for today.", "")
            return
        }
        
        guard let nextPrayerIndex = prayerTimesArray.firstIndex(of: nextPrayerTime) else {
            completion("Error identifying the next prayer.", "")
            return
        }
        
        let nextPrayer = ["Bomdod", "Peshin", "Asr", "Shom", "Hufton"][nextPrayerIndex]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let currentTimeDate = formatter.date(from: currentTime),
              let nextPrayerTimeDate = formatter.date(from: nextPrayerTime) else {
            completion("Error calculating time until the next prayer.", "")
            return
        }
        
        let timeDifference = nextPrayerTimeDate.timeIntervalSince(currentTimeDate)
        
        let hours = Int(timeDifference / 3600)
        let minutes = Int((timeDifference.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(timeDifference.truncatingRemainder(dividingBy: 60))
        
        let timeUntilNextPrayer: String
        if hours > 0 {
            timeUntilNextPrayer = String(format: "%02d soat %02d daqiqa", hours, minutes)
        } else {
            timeUntilNextPrayer = String(format: "%02d daqiqa %02d soniya", minutes, seconds)
        }
        
        completion(nextPrayer, timeUntilNextPrayer)
        
    }
    
    func makeAPIRequest(withCity city: String, completion: @escaping () -> Void) {
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let formattedDate = dateFormatter.string(from: currentDate)
        
        let apiURL = "https://api.aladhan.com/v1/timingsByAddress/\(formattedDate)?address=\(city)"
        
        print(apiURL)
        
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
                    print(self.prayerTimesArray)
                    
                    self.calculateTimeUntilNextPrayer { prayerMessage, timeUntilNextPrayer in
                        print(prayerMessage, timeUntilNextPrayer)
                    }
                    
                    completion()
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
    }
}

extension PrayerTimesViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        manager.stopUpdatingLocation()
        fetchPrayerTimes(forLocation: location) {
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
}

