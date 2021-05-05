//
//  LocationData.swift
//  chooseHole
//
//  Created by mac on 2021/2/26.
//  Copyright © 2021 youkochen. All rights reserved.
//

import Foundation

var offlineLocationData:LocationData?

struct LocationData:Decodable {
    var area:String?
    var road:String?
    var id:String?
}
