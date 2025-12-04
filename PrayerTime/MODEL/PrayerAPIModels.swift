//
//  PrayerAPIModels.swift
//  PrayerTime
//
//  Created by asma  on 10/06/1447 AH.
//
import Foundation

struct PrayerAPIResponse: Decodable {
    let data: PrayerData
}

struct PrayerData: Decodable {
    let timings: Timings
}

struct Timings: Decodable {
    let Fajr: String
    let Sunrise: String
    let Dhuhr: String
    let Asr: String
    let Sunset: String
    let Maghrib: String
    let Isha: String
}
