//
//  PlayerBottomView.swift
//  ZMPlayer
//
//  Created by zsm on 2019/5/22.
//  Copyright © 2019 zsm. All rights reserved.
//

import SnapKit

enum SliderTouch {
    case down /// 按下
    case up /// 松开
}

class PlayerBottomView: UIView {
    
    /// 点击暂停/播放按钮
    var playerHandler: () -> Void = {}
    
    /// 拖动进度条
    var sliderValueDidChange: (Double) -> Void = { _ in }
    
    /// 进度条按下/松开状态
    var sliderTouch: (SliderTouch) -> Void = { _ in }
    
    /// 是否在播放
    var isPlaying: Bool = false {
        didSet {
            playBtn.isSelected = isPlaying
        }
    }
    
    var hid: Bool = false {
        didSet {
            bgView.isHidden = hid
            bottomProgressView.isHidden = !hid
            backgroundColor = hid ? UIColor.clear : UIColor.black.alpha(0.5)
        }
    }
    
    /// 缓冲进度条进度值
    var progressValue: Float = 0 {
        didSet {
            progressView.progress = progressValue
        }
    }
    
    /// 进度条进度值
    var sliderValue: Float = 0 {
        didSet {
            slider.setValue(sliderValue, animated: true)
            bottomProgressView.setProgress(sliderValue, animated: true)
        }
    }
    
    /// 当前播放的时间
    var currentTime: Double = 0 {
        didSet {
            playingTimeLabel.text = currentTime.formatTime
        }
    }
    
    /// 最大时间
    var maxTime: Double = 0 {
        didSet {
            maxTimeLabel.text = maxTime.formatTime
        }
    }
    
    private lazy var bgView: UIView = { UIView() }()
    
    private lazy var playBtn: UIButton = {
        let playBtn = UIButton()
        playBtn.setImage(UIImage(named: "paused"), for: .normal)
        playBtn.setImage(UIImage(named: "playing"), for: .selected)
        playBtn.addTarget(self, action: #selector(playerBtnClick), for: .touchUpInside)
        return playBtn
    }()
    
    private lazy var playingTimeLabel: UILabel = {
        let playingTimeLabel = UILabel()
        playingTimeLabel.text = "00:00"
        playingTimeLabel.textColor = UIColor.white
        playingTimeLabel.font = UIFont.systemFont(ofSize: 12)
        playingTimeLabel.textAlignment = .center
        return playingTimeLabel
    }()
    
    private lazy var maxTimeLabel: UILabel = {
        let maxTimeLabel = UILabel()
        maxTimeLabel.text = "00:00"
        maxTimeLabel.textColor = UIColor.white
        maxTimeLabel.font = UIFont.systemFont(ofSize: 12)
        maxTimeLabel.textAlignment = .center
        return maxTimeLabel
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.trackTintColor = UIColor.white
        progressView.progressTintColor = UIColor(hex: "#989897")
        progressView.layer.cornerRadius = 1
        progressView.layer.masksToBounds = true
        return progressView
    }()
    
    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.minimumTrackTintColor = UIColor(hex: "#F83244")
        slider.maximumTrackTintColor = UIColor.clear
        slider.setThumbImage(UIImage(named: "progress"), for: .normal)
        slider.addTarget(self, action: #selector(sliderValueChange), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderTouchUpInside), for: .touchUpInside)
        return slider
    }()
    
    private lazy var bottomProgressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.trackTintColor = UIColor(hex: "#989897")
        progressView.progressTintColor = UIColor(hex: "#F83244")
        //        progressView.progressViewStyle = .bar
        progressView.isHidden = true
        return progressView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.black.alpha(0.5)
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        
        addSubview(bgView)
        bgView.addSubview(playBtn)
        bgView.addSubview(playingTimeLabel)
        bgView.addSubview(maxTimeLabel)
        bgView.addSubview(progressView)
        bgView.addSubview(slider)
        addSubview(bottomProgressView)
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        playBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        playingTimeLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(playBtn.snp.right)
            make.width.equalTo(50)
        }
        
        maxTimeLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(50)
        }
        
        progressView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(0.5)
            make.left.equalTo(playingTimeLabel.snp.right).offset(10)
            make.right.equalTo(maxTimeLabel.snp.left).offset(-10)
            make.height.equalTo(2)
        }
        
        slider.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(playingTimeLabel.snp.right).offset(10)
            make.right.equalTo(maxTimeLabel.snp.left).offset(-10)
        }
        
        bottomProgressView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(2)
        }
    }
    
}

extension PlayerBottomView {
    
    @objc private func playerBtnClick() {
        playerHandler()
    }
    
    @objc private func sliderValueChange() {
        let value = slider.value
        sliderValueDidChange(Double(value))
    }
    
    @objc private func sliderTouchDown() {
        sliderTouch(.down)
    }
    
    @objc private func sliderTouchUpInside() {
        sliderTouch(.up)
    }
}

extension Double {
    var formatTime: String {
        let seconds = Int(self)
        
        let hour = seconds / 3600
        let minute = (seconds % 3600) / 60
        let second = seconds % 60
        
        var date = "00:00"
        if hour <= 0 {
            date = String(format: "%02ld:%02ld", minute, second)
        } else {
            date = String(format: "%02ld:%02ld:%02ld", hour, minute, second)
        }
        
        return date
    }
}
