//
//  Player+Extension.swift
//  ZMPlayer
//
//  Created by zsm on 2019/5/22.
//  Copyright © 2019 zsm. All rights reserved.
//

import UIKit
import SnapKit

extension UIColor {
    convenience init(hex string: String) {
        var hex = string.hasPrefix("#") ? String(string.dropFirst()) : string
        guard hex.count == 3 || hex.count == 6 else {
            self.init(white: 1.0, alpha: 0.0)
            return
        }
        if hex.count == 3 {
            for (index, char) in hex.enumerated() {
                hex.insert(char, at: hex.index(hex.startIndex, offsetBy: index * 2))
            }
        }
        
        self.init(red: CGFloat((Int(hex, radix: 16)! >> 16) & 0xFF) / 255.0,
                  green: CGFloat((Int(hex, radix: 16)! >> 8) & 0xFF) / 255.0,
                  blue: CGFloat((Int(hex, radix: 16)!) & 0xFF) / 255.0, alpha: 1.0)
    }
    
    func alpha(_ value: CGFloat) -> UIColor {
        return withAlphaComponent(value)
    }
}

extension UIApplication {
    
    /// 状态栏高度
    var statusBarHeight: CGFloat {
        return statusBarFrame.size.height
    }
    
    /// 获取导航栏 + 状态栏高度
    var navigationBarHeight: CGFloat {
        return statusBarFrame.size.height + 44.0
    }
}

extension UIViewController {
    
    var safeAreaLayoutGuideBottom: ConstraintItem {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.snp.bottom
        } else {
            return view.snp.bottom
        }
    }
}
