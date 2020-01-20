//
//  Circle.swift
//  assignment4
//
//  Created by Farhoud Talebi on 2019-03-30.
//  Copyright © 2019 COMP1601-Farhoud. All rights reserved.
//

import Foundation
import CoreGraphics

struct Circle {
    var centre = CGPoint.zero
    var radius: CGFloat = 69.0
    var velocity = CGPoint.zero
    
    func distanceToPoint(point: CGPoint) -> CGFloat {
        let xDist = centre.x - point.x
        let yDist = centre.y - point.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    func containsPoint(point:CGPoint) -> Bool {
        return distanceToPoint(point: point) <= radius
    }
    
    mutating func advanceInArea(area: CGRect) {
        //  print(#function)
        centre.x = centre.x + velocity.x*0.1;
        velocity.y = velocity.y + gravity*0.1;
        centre.y = centre.y + velocity.y*0.1;
        
    }
}



