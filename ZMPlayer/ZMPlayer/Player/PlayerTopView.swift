//
//  PlayerTopView.swift
//  ZMPlayer
//
//  Created by zsm on 2019/5/22.
//  Copyright © 2019 zsm. All rights reserved.
//

import UIKit

class PlayerTopView: UIView {
    
    var didClose: () -> Void = {}
    
    private lazy var closeBtn: UIButton = {
        let closeBtn = UIButton()
        closeBtn.setImage(UIImage(named: "close"), for: .normal)
        closeBtn.setImage(UIImage(named: "close"), for: .highlighted)
        closeBtn.addTarget(self, action: #selector(closeBtnClick), for: .touchUpInside)
        return closeBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(closeBtn)
        closeBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func closeBtnClick() {
        didClose()
    }
}
