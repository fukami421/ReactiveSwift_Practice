//
//  Home.swift
//  ReactiveSwift_Practice
//
//  Created by 深見龍一 on 2020/02/02.
//  Copyright © 2020 深見龍一. All rights reserved.
//

import ReactiveSwift

class Home: Equatable {

    let trackName: String
    let artistName: String
    let index: Int

    init(dict: Dictionary<String, Any>) {
        self.trackName = dict["trackName"] as! String
        self.artistName = dict["artistName"] as! String
        self.index = 0
    }

    static func == (lhs: Home, rhs: Home) -> Bool {
        if lhs.trackName == rhs.trackName, lhs.artistName == rhs.artistName {
            return true
        } else {
            return false
        }
    }

}
