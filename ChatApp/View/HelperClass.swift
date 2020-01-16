//
//  HelperClass.swift
//  ChatApp
//
//

import Foundation
import UIKit

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
    }
    
    static func primaryColour() -> UIColor {
        return UIColor(red:0.96, green:0.25, blue:0.41, alpha:1.0)
    }
    
    static func fadeOut() -> UIColor {
        return UIColor(red:0.96, green:0.25, blue:0.41, alpha:0.8)
    }
}
