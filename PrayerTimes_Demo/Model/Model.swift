//
//  Model.swift
//  PrayerTimes_Demo
//
//  Created by Faxriddin Mo'ydinxonov on 19/06/23.
//

import Foundation
import UIKit

//Model

struct DataList: Decodable {
    let data: TimeList
}

struct TimeList: Codable {
    let timings: PrayerTimes
}

struct PrayerTimes: Codable {
    let Fajr        : String
    let Dhuhr       : String
    let Asr         : String
    let Maghrib     : String
    let Isha        : String
}
