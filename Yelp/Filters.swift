//
//  Filters.swift
//  ChowHunt
//
//  Created by Jon O'Keefe on 10/23/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import Foundation

class Filters: NSObject {
    var categories = [String: String]()
    var sort = 0
    var distance: Int? = nil
    var deals: Bool? = nil
}
