//
//  FYShareView.swift
//  FYShareView
//
//  Created by 武飞跃 on 2017/10/18.
//  Copyright © 2017年 wufeiyue.com. All rights reserved.
//

import UIKit

public typealias FYShareItemButtonAction = (_ sender: FYShareItemButton) -> Void

public struct FYShareStyle {
    var offsetY: CGFloat = 0.0          //相对于顶部的偏移量 默认为0
    var insetHorizontal: CGFloat = 5.0  //水平向中间方向缩进量 默认为5
    var itemCount: Int = 4              //每一页显示的itemView个数
    var isPagingEnabled: Bool = true    //是否显示分页
    var contentHeight: CGFloat = 200    //scrollView的高度
    var cancelHeight: CGFloat = 38      //取消按钮的高度
    var cancelMarginTop: CGFloat = 8    //取消按钮与scrollView之间浅灰色分割线高度
    var titleMarginTop: CGFloat = 7     //itemView 标题与icon之间的距离
    var pageControlMarginBottom: CGFloat = 10   //pageControl距离分割线的高度
}

public struct FYShareItemModel {
    var normalImage: UIImage?
    var highlightedImage: UIImage?
    var title: String
    var identifier: String = ""
    
    public init(title:String, normal: String, highlighted: String, id: String) {
        self.highlightedImage = UIImage(named: highlighted)
        self.normalImage = UIImage(named: normal)
        self.title = title
        self.identifier = id
    }
    
}

public protocol FYShareViewDelegate: class {
    func shareView(itemDidTapped identifier: String)
}

public final class FYShareView: UIView {
    
    public var style = FYShareStyle()
    public let items: Array<FYShareItemModel>
    public weak var delegate: FYShareViewDelegate?
    
    private lazy var bgView: UIView = { [unowned self] in
        let view = UIView(frame: self.bounds)
        view.backgroundColor = .black
        let tap = UITapGestureRecognizer(target: self, action: #selector(FYShareView.hide))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private lazy var containerView: FYShareContainerView = { [unowned self] in
        $0.backgroundColor = UIColor.groupTableViewBackground
        $0.style = self.style
        $0.itemView = self.items
        $0.itemAction = { [weak self] btn in
            self?.delegate?.shareView(itemDidTapped: btn.identifier)
        }
        $0.cancelAction = { [weak self] in
            self?.hide()
        }
        return $0
        }(FYShareContainerView())
    
    public init(frame: CGRect, items: Array<FYShareItemModel>) {
        self.items = items
        super.init(frame: frame)
        isHidden = true
    }
    
    public func show() {
        addSubviews()
        guard containerView.alpha == 0 else { return }
        containerView.transform = CGAffineTransform(translationX: 0, y: 40)
        UIView.animate(withDuration: 0.3) {
            self.containerView.alpha = 1
            self.containerView.transform = CGAffineTransform(translationX: 0, y: 0)
            self.bgView.alpha = 0.3
        }
        
    }
    
    @objc public func hide() {
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.alpha = 0
            self.containerView.transform = CGAffineTransform(translationX: 0, y: 40)
            self.bgView.alpha = 0
        }) { (isFinished) in
            self.removeSubViews()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func removeSubViews() {
        isHidden = true
        [containerView, bgView].forEach{
            $0.removeFromSuperview()
        }
    }
    
    private func addSubviews() {
        guard subviews.isEmpty else { return }
        isHidden = false
        [bgView, containerView].forEach {
            $0.alpha = 0
            addSubview($0)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        var rect = CGRect.zero
        rect.size = CGSize(width: bounds.size.width, height: style.contentHeight)
        containerView.bounds = rect
        containerView.center.y = -style.contentHeight / 2 + bounds.size.height
        containerView.center.x = bounds.midX
    }
    
}

fileprivate final class FYShareContainerView: UIView {
    
    lazy var cancelBtn: UIButton = { [unowned self] in
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.setTitle("取消", for: .normal)
        btn.setTitleColor(UIColor(red: 51.0/255, green: 51.0/255, blue: 51.0/255, alpha: 1), for: .normal)
        btn.backgroundColor = .white
        btn.addTarget(self, action: #selector(cancelBtnDidTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var scrollView: UIScrollView = { [unowned self] in
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.contentOffset = .zero
        view.backgroundColor = .white
        view.delegate = self
        return view
    }()
    
    lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.backgroundColor = UIColor.white
        control.pageIndicatorTintColor = UIColor.groupTableViewBackground
        control.currentPageIndicatorTintColor = UIColor.gray
        control.isHidden = true
        return control
    }()
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    var style: FYShareStyle!
    var itemView: Array<FYShareItemModel>!
    var itemAction: FYShareItemButtonAction!
    var cancelAction: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        [cancelBtn, scrollView, pageControl, bgView].forEach({ addSubview($0) })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        print("bounds:\(bounds)")
        
        var pageControlHeight: CGFloat = 0
        
        let isShowPageControl = style.isPagingEnabled(from: itemView.count)
        
        scrollView.isPagingEnabled = isShowPageControl
        pageControl.isHidden = !isShowPageControl
        cancelBtn.frame = bounds.inset(offsetY: style.cancelHeight)
        
        if !pageControl.isHidden{
            pageControlHeight = style.pageControlMarginBottom + 8
        }
        
        scrollView.frame = bounds.inset(height: style.cancelHeight + style.cancelMarginTop + pageControlHeight)
        scrollView.setupView(style: style, itemView: itemView, action: itemAction)
        
        pageControl.numberOfPages = itemView.count / style.itemCount + 1
        pageControl.frame = CGRect(x: 0, y: scrollView.frame.maxY, width: bounds.size.width, height: 8)
        bgView.frame = CGRect(x: 0, y: pageControl.frame.maxY, width: bounds.size.width, height: style.pageControlMarginBottom)
    }
    
    @objc func cancelBtnDidTapped() {
        cancelAction?()
    }
}

extension FYShareContainerView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = bounds.size.width
        let pageFraction = scrollView.contentOffset.x / pageWidth
        pageControl.currentPage = Int(pageFraction)
    }
}

public protocol FYShareItemViewDelegate: class {
    func setupView(style: FYShareStyle, itemView:Array<FYShareItemModel>, action: @escaping FYShareItemButtonAction)
}

extension FYShareItemViewDelegate where Self: UIScrollView {
    
    public func setupView(style: FYShareStyle, itemView:Array<FYShareItemModel>, action: @escaping FYShareItemButtonAction) {
        
        subviews.forEach{ $0.removeFromSuperview() }
        
        func row(count:Int) -> Int {
            let num = style.itemCount
            return (count % num == 0 ? 0 : 1) + count / num
        }
        
        func createCounter(width: CGFloat) -> () -> CGFloat {
            
            var index = 0
            
            let offsetX = style.insetHorizontal
            
            return {
                defer { index += 1 }
                return CGFloat(index) * width + offsetX + (2 * offsetX) * CGFloat(row(count: index + 1) - 1)
            }
            
        }
        
        let size = style.originSize(from: bounds.size)
        let counter = createCounter(width: size.width)
        itemView.forEach { (model) in
            
            var rect: CGRect = .zero
            rect.size = size
            rect.origin.y = style.offsetY
            rect.origin.x = counter()
            let btn = FYShareItemButton(frame: rect)
            btn.setTitle(model.title, for: .normal)
            btn.setTitleColor(UIColor(red: 51.0/255, green: 51.0/255, blue: 51.0/255, alpha: 1), for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            btn.setImage(model.normalImage, for: .normal)
            btn.setImage(model.highlightedImage, for: .highlighted)
            btn.identifier = model.identifier
            btn.titleMarginTop = style.titleMarginTop
            btn.addAction(action)
            addSubview(btn)
        }
        
        contentSize = CGSize(width: CGFloat(row(count: itemView.count)) * bounds.size.width, height: 0)
        
    }
    
}

extension UIScrollView: FYShareItemViewDelegate { }

public final class FYShareItemButton: UIButton {
    
    var titleMarginTop: CGFloat = 5
    var action: FYShareItemButtonAction?
    public var identifier: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(FYShareItemButton.didPressed(_:)), for: UIControlEvents.touchUpInside)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didPressed(_ sender: FYShareItemButton) {
        action?(sender)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        guard let titleLabel = titleLabel,  let imageView = imageView else {
            return
        }
        
        var newFrame = titleLabel.frame
        var center = imageView.center
        
        center.x = frame.size.width / 2
        center.y = (frame.size.height - titleMarginTop - newFrame.size.height) / 2
        imageView.center = center
        
        newFrame.origin.x = 0
        newFrame.origin.y = imageView.frame.maxY + titleMarginTop
        newFrame.size.width = frame.size.width
        titleLabel.frame = newFrame
        titleLabel.textAlignment = .center
    }
    
    public func addAction(_ action: @escaping FYShareItemButtonAction) {
        self.action = action
    }
}

extension FYShareStyle {
    fileprivate func originSize(from superview: CGSize) -> CGSize {
        return CGSize(width: (superview.width - insetHorizontal * 2) / CGFloat(itemCount), height: -2 * offsetY + superview.height)
    }
    
    fileprivate func isPagingEnabled(from count: Int) -> Bool {
        guard isPagingEnabled else { return false }
        return itemCount < count ? true : false
    }
    
}

extension CGRect {
    fileprivate func inset(height value: CGFloat) -> CGRect {
        return CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height - value)
    }
    
    fileprivate func inset(offsetY value: CGFloat) -> CGRect {
        return CGRect(x: origin.x, y: size.height - value, width: size.width, height: value)
    }
}


