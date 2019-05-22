//
//  PlayerViewController.swift
//  ZMPlayer
//
//  Created by zsm on 2019/5/22.
//  Copyright © 2019 zsm. All rights reserved.
//

import UIKit
import Player
import AVFoundation
import MediaPlayer

enum PanDirection {
    case unkonw /// 未知
    case horizontal /// 横向移动
    case vertical /// 纵向移动
}

class PlayerViewController: UIViewController {
    
    var close: () -> Void = {}
    
    private var isPlaying: Bool = false
    
    private var isDragged: Bool = false /// 是否正在拖拽
    
    private var isVolume: Bool = false /// 是否在调节音量
    
    private var panDirection: PanDirection = .unkonw
    
    private var sumTime: Double = 0 /// 用来保存快进的总时长
    
    private var volumeViewSlider: UISlider?
    
    private lazy var player: Player = {
        let player = Player()
        player.playerDelegate = self
        player.playbackDelegate = self
        player.playbackFreezesAtEnd = true /// 播放在最后一帧停止
        player.playerView.playerBackgroundColor = .black
        player.view.backgroundColor = UIColor.black
        player.playbackResumesWhenBecameActive = false
        player.playbackResumesWhenEnteringForeground = false
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        singleTap.delegate = self
        singleTap.numberOfTapsRequired = 1
        player.view.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.delegate = self
        doubleTap.numberOfTapsRequired = 2
        player.view.addGestureRecognizer(doubleTap)
        
        /// 解决点击当前view时候响应其他控件事件
        singleTap.delaysTouchesBegan = true
        doubleTap.delaysTouchesBegan = true
        /// 双击失败响应单击事件
        singleTap.require(toFail: doubleTap)
        
        return player
    }()
    
    private lazy var playBtn: UIButton = {
        let playBtn = UIButton()
        playBtn.setImage(UIImage(named: "player"), for: .normal)
        playBtn.addTarget(self, action: #selector(playerBtnClick), for: .touchUpInside)
        return playBtn
    }()
    
    private lazy var playErrorLabel: UILabel = {
        let playErrorLabel = UILabel()
        playErrorLabel.text = "加载失败"
        playErrorLabel.textColor = UIColor.white
        playErrorLabel.font = UIFont.systemFont(ofSize: 13)
        playErrorLabel.textAlignment = .center
        playErrorLabel.isHidden = true
        return playErrorLabel
    }()
    
    private lazy var topView: PlayerTopView = { PlayerTopView() }()
    
    private lazy var bottomView: PlayerBottomView = { PlayerBottomView() }()
    
    var playerUrl: String = "" {
        didSet {
            player.url = URL(string: playerUrl)
        }
    }
    
    private var url: String
    init(url: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        addAction()
        configureVolume()
    }
    
    deinit {
        player.willMove(toParent: nil)
        player.view.removeFromSuperview()
        player.removeFromParent()
        debugPrint("PlayerViewController deinit 👍👍👍")
    }
    
    private func addSubviews() {
        
        view.backgroundColor = UIColor.black
        
        addChild(player)
        view.addSubview(player.view)
        player.didMove(toParent: self)
        
        player.url = URL(string: url)
        
        player.view.addSubview(playBtn)
        view.addSubview(topView)
        player.view.addSubview(bottomView)
        view.addSubview(playErrorLabel)
        
        player.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        playBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 60, height: 60))
        }
        
        topView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(UIApplication.shared.statusBarHeight)
            make.height.equalTo(40)
        }
        
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuideBottom)
            make.height.equalTo(30)
        }
        
        playErrorLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        player.playFromBeginning()
    }
}

extension PlayerViewController {
    /// 配置音量
    private func configureVolume() {
        let volumeView = MPVolumeView()
        volumeViewSlider = nil
        for v in volumeView.subviews {
            if v.classForCoder.description() == "MPVolumeSlider", let slider = v as? UISlider {
                volumeViewSlider = slider
            }
        }
        do {
            /// 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        } catch {}
    }
    
    /// pan垂直移动的方法
    private func verticalMoved(value: CGFloat) {
        isVolume ? (volumeViewSlider?.value -= Float(value / 10000)) : (UIScreen.main.brightness -= value / 10000)
    }
    
    /// pan水平移动的方法
    private func horizontalMoved(value: CGFloat) {
        /// 每次滑动需要叠加时间
        sumTime += Double(value) / 150
        /// 需要限定sumTime的范围
        let totalTime = player.maximumDuration
        if sumTime > totalTime { sumTime = totalTime }
        if sumTime < 0 { sumTime = 0 }
        player.seek(to: CMTime(seconds: sumTime, preferredTimescale: CMTimeScale(1 * NSEC_PER_SEC)))
        
        let time = sumTime / totalTime
        let progress = Float(time)
        bottomView.sliderValue = progress
    }
}

extension PlayerViewController {
    
    private func addAction() {
        
        topView.didClose = { [weak self] in
            guard let `self` = self else { return }
            self.close()
        }
        
        bottomView.playerHandler = { [weak self] in
            guard let `self` = self else { return }
            self.playerBtnClick()
        }
        
        bottomView.sliderValueDidChange = { [weak self] value in
            guard let `self` = self else { return }
            let sliderTime = value * self.player.maximumDuration
            self.player.seek(to: CMTime(seconds: sliderTime, preferredTimescale: CMTimeScale(1 * NSEC_PER_SEC)))
        }
        
        bottomView.sliderTouch = { [weak self] status in
            guard let `self` = self else { return }
            if status == .down {
                self.isPlaying = self.player.playbackState == .playing
                self.isDragged = true
                self.player.pause()
            }
            if status == .up {
                if self.isPlaying {
                    self.player.playFromCurrentTime()
                    self.isPlaying = false
                }
                self.isDragged = false
            }
        }
    }
    
    @objc private func playerBtnClick() {
        switch player.playbackState {
        case .stopped:
            player.playFromBeginning()
        case .playing:
            player.pause()
        case .paused:
            player.playFromCurrentTime()
        default:
            player.playFromBeginning()
        }
    }
    
    @objc private func handleSingleTap() {
        bottomView.hid = !bottomView.hid
    }
    
    @objc private func handleDoubleTap() {
        switch player.playbackState {
        case .stopped:
            player.playFromBeginning()
        case .paused:
            player.playFromCurrentTime()
        case .playing:
            player.pause()
        case .failed:
            player.pause()
        }
    }
    
    @objc private func panDirection(_ pan: UIPanGestureRecognizer) {
        
        /// 根据在view上Pan的位置，确定是调音量还是亮度
        let locationPoint = pan.location(in: player.view)
        /// 我们要响应水平移动和垂直移动
        /// 根据上次和本次移动的位置，算出一个速率的point
        let veloctyPoint = pan.velocity(in: player.view)
        
        /// 判断是垂直移动还是水平移动
        switch pan.state {
        case .began:
            /// 使用绝对值来判断移动的方向
            let x = abs(veloctyPoint.x)
            let y = abs(veloctyPoint.y)
            if x > y { /// 水平移动
                panDirection = .horizontal
                sumTime = player.currentTime
                isPlaying = player.playbackState == .playing
                player.pause()
                isDragged = true
            } else {
                panDirection = .vertical
                /// 开始滑动的时候,状态改为正在控制音量
                if (locationPoint.x > player.view.bounds.size.width / 2) {
                    self.isVolume = true;
                } else { /// 状态改为显示亮度调节
                    self.isVolume = false;
                }
            }
        case .changed:
            switch panDirection {
            case .horizontal:
                horizontalMoved(value: veloctyPoint.x)
            case .vertical:
                verticalMoved(value: veloctyPoint.y) /// 垂直移动方法只要y方向的值
            default:
                break
            }
        case .ended:
            switch panDirection {
            case .horizontal:
                if isPlaying {
                    player.playFromCurrentTime()
                    isPlaying = false
                }
                isDragged = false
                sumTime = 0
            case .vertical:
                /// 垂直移动结束后，把状态改为不再控制音量
                isVolume = false
            default:
                break
            }
        default:
            break
        }
    }
}

extension PlayerViewController: PlayerDelegate, PlayerPlaybackDelegate {
    func playerReady(_ player: Player) {
        bottomView.maxTime = player.maximumDuration
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panDirection(_:)))
        panRecognizer.delegate = self
        panRecognizer.maximumNumberOfTouches = 1
        panRecognizer.delaysTouchesBegan = true
        panRecognizer.delaysTouchesEnded = true
        panRecognizer.cancelsTouchesInView = true
        player.view.addGestureRecognizer(panRecognizer)
    }
    
    /// 播放状态
    func playerPlaybackStateDidChange(_ player: Player) {
        
        playErrorLabel.isHidden = true
        switch player.playbackState {
        case .playing:
            bottomView.isPlaying = true
            playBtn.isHidden = true
        default:
            bottomView.isPlaying = false
            playBtn.isHidden = false
        }
    }
    
    /// 缓冲状态
    func playerBufferingStateDidChange(_ player: Player) {
    }
    
    /// 缓冲进度
    func playerBufferTimeDidChange(_ bufferTime: Double) {
        let time = bufferTime / player.maximumDuration
        let progress = Float(time)
        bottomView.progressValue = progress > 1 ? 1 : progress
    }
    
    func player(_ player: Player, didFailWithError error: Error?) {
        playErrorLabel.isHidden = false
    }
    
    /// 播放进度
    func playerCurrentTimeDidChange(_ player: Player) {
        bottomView.currentTime = player.currentTime
        /// 拖拽的时候不设置，防止进度条跳动
        if !isDragged {
            let time = player.currentTime / player.maximumDuration
            let progress = Float(time)
            bottomView.sliderValue = Float(progress)
        }
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) {
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
    }
    
    func playerPlaybackWillLoop(_ player: Player) {
    }
}

extension PlayerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let v = touch.view else { return false }
        if v.isKind(of: UISlider.self) {
            return false
        }
        if v.isKind(of: UIButton.self) {
            return false
        }
        return true
    }
}
