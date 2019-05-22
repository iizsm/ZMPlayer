//
//  PlayerControl.swift
//  ZMPlayer
//
//  Created by zsm on 2019/5/22.
//  Copyright © 2019 zsm. All rights reserved.
//

import UIKit

class PlayerControl: UIView {
    
    private var player: PlayerViewController?
    
    private var url: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public class func show(url: String) {
        let playerView = PlayerControl()
        playerView.url = url
        playerView.addSubviews()
        playerView.show()
    }
    
    private func show() {
        let animation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform")
        animation.duration = 0.25
        animation.isRemovedOnCompletion = true
        animation.fillMode = CAMediaTimingFillMode.forwards
        var value = [Any]()
        value.append(NSValue(caTransform3D: CATransform3DMakeScale(0.6, 0.6, 1.0)))
        value.append(NSValue(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0)))
        animation.values = value
        layer.add(animation, forKey: nil)
    }
    
    private func hide() {
        UIApplication.shared.keyWindow?.windowLevel = .normal
        UIView.animate(withDuration: 0.25, animations: {
            self.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            self.alpha = 0
        }) { _ in
            self.player = nil
            self.removeFromSuperview()
        }
    }
    
    private func addSubviews() {
        UIApplication.shared.keyWindow?.windowLevel = .alert
        UIApplication.shared.keyWindow?.addSubview(self)
        let player = PlayerViewController(url: url)
        player.view.frame = bounds
        addSubview(player.view)
        self.player = player
        
        player.close = { [weak self] in
            guard let `self` = self else { return }
            self.hide()
        }
    }
}
