//
//  CycleRefreshHeaderView.swift
//  ZhiHuDaily
//
//  Created by 夏名 on 2017/3/19.
//  Copyright © 2017年 xiabob. All rights reserved.
//

import UIKit


class CycleRefreshHeaderView: UIView {
    //keyPath
    fileprivate let kContentOffsetKeyPath = "contentOffset"
    
    var maxScrollOffset: CGFloat = 60
    var miniRefreshDuration: TimeInterval = 2
    var refreshBlock: (()->())?
    private(set) var currentContentOffset: CGFloat = 0
    private(set) var isAnimationing = false
    weak var scrollView: UIScrollView? {
        didSet {
            if oldValue != nil {
                removeObserver()
            }
            
            if scrollView != nil {
                addObserver()
            }
        }
    }
    fileprivate var beginDate = Date()

    
    fileprivate lazy var backgroundCycleView: UIView = { [unowned self] in
        let view = UIView(frame: self.bounds)
        view.backgroundColor = UIColor.clear
        view.layer.borderColor = UIColor.black.withAlphaComponent(0.25).cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = self.xb_width/2
        view.layer.masksToBounds = true
        return view
    }()
    
    fileprivate lazy var cycleLayer: CAShapeLayer = { [unowned self] in
        let layer = CAShapeLayer()
        let path = UIBezierPath(arcCenter: CGPoint(x: self.xb_width/2, y: self.xb_height/2), radius: self.xb_width/2-0.5, startAngle: CGFloat(M_PI_2), endAngle: CGFloat(M_PI*2 + M_PI_2), clockwise: true)
        layer.path = path.cgPath
        layer.lineWidth = 1
        layer.lineCap = kCALineCapRound
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        layer.strokeEnd = 0
        return layer
    }()
    
    fileprivate lazy var indicatorView: UIActivityIndicatorView = { [unowned self] in
        let view = UIActivityIndicatorView(frame: self.bounds)
        view.activityIndicatorViewStyle = .white
        view.alpha = 0
        return view
    }()
    
    
    //MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        configViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserver()
    }
    
    fileprivate func configViews() {
        addSubview(backgroundCycleView)
        layer.addSublayer(cycleLayer)
        addSubview(indicatorView)
    }
    
    //MARK: - add or remove observer
    fileprivate func addObserver() {
        scrollView?.addObserver(self, forKeyPath: kContentOffsetKeyPath, options: .new, context: nil)
    }
    
    func removeObserver() {
        scrollView?.removeObserver(self, forKeyPath: kContentOffsetKeyPath)
    }
    
    
    //MARK: - handle observeValue
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if isAnimationing {return}
        guard let ch = change else {return}
        if keyPath == kContentOffsetKeyPath {
            guard let value = (ch[.newKey] as AnyObject?)?.cgPointValue else {return}
            currentContentOffset = value.y
            if currentContentOffset < 0 {
                isHidden = false
                backgroundCycleView.alpha = 1
                let progress = min(fabs(currentContentOffset) / maxScrollOffset, 1);
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                cycleLayer.strokeEnd = progress
                CATransaction.commit()
                
                //超出刷新界限并释放刷新
                let isDragging = scrollView?.isDragging ?? false
                if !isDragging && currentContentOffset <= -maxScrollOffset {
                    isAnimationing = true
                    beginRefreshing()
                } else {
                    isAnimationing = false
                }
            } else {
                isHidden = true
            }
        }
    }
    
    
    //MARK: - animation
    
    func beginRefreshing() {
        beginDate = Date()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        cycleLayer.strokeEnd = 0
        CATransaction.commit()
        backgroundCycleView.alpha = 0
        indicatorView.alpha = 1
        indicatorView.startAnimating()
        refreshBlock?()
    }
    
    func endRefreshing() {
        let endDate = Date()
        let offset = miniRefreshDuration - endDate.timeIntervalSince(beginDate)
        if offset > 0 {
            dispatchMain(after: offset, completeBlock: { [weak self] in
                self?.indicatorView.alpha = 0
                self?.indicatorView.stopAnimating()
                self?.isAnimationing = false
            })
        } else {
            indicatorView.alpha = 0
            indicatorView.stopAnimating()
            isAnimationing = false
        }
    }
}
