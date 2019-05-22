//
//  ViewController.swift
//  ZMPlayer
//
//  Created by zsm on 2019/5/22.
//  Copyright © 2019 zsm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let playerBtn = UIButton()
        playerBtn.backgroundColor = UIColor.green
        playerBtn.setTitle("播放", for: .normal)
        playerBtn.addTarget(self, action: #selector(playerBtnClick), for: .touchUpInside)
        view.addSubview(playerBtn)
        
        playerBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 100, height: 100))
        }
    }

    @objc private func playerBtnClick() {
        PlayerControl.show(url: "https://aweme.snssdk.com/aweme/v1/playwm/?video_id=v0300f340000bjc2oktlt63hktg7oi6g&line=0")
    }

}

