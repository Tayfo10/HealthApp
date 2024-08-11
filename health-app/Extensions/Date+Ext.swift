//
//  Date+Ext.swift
//  health-app
//
//  Created by Tayfun Sener on 11.08.2024.
//

import Foundation

extension Date {
    var weekdayInt: Int {
        Calendar.current.component(.weekday, from: self)
    }
}
