//
//  DateFormatter+Deuce.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 5/10/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

extension DateFormatter {
    static var deuceFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"//2017-03-05T05:03:12.5622336
        formatter.timeZone = TimeZone(abbreviation: "UTC")//NSTimeZone.local

        return formatter
    }
}
