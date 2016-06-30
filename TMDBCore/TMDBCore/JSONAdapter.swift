//
//  JSONAdapter.swift
//  TMDBCore
//
//  Created by Guilherme Rambo on 20/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol JSONAdaptable {
    init?(json: JSON)
}

class JSONAdapter<M where M:JSONAdaptable> {
    
    class func adapt(json: JSON) -> M? {
        return M(json: json)
    }
    
}