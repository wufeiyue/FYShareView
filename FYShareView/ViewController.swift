//
//  ViewController.swift
//  FYShareView
//
//  Created by 武飞跃 on 2017/10/24.
//  Copyright © 2017年 wufeiyue.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var shareView: FYShareView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBtnView()
        setupShareView()
    }
    
    //MARK: - 创始化分享视图
    
    func setupShareView() {
        let friend = FYShareItemModel(title: "朋友圈", normal: "share_friend", highlighted: "share_friend_hover", id: "friend")
        let qq = FYShareItemModel(title: "QQ", normal: "share_qq", highlighted: "share_qq_hover", id: "qq")
        let sina = FYShareItemModel(title: "微博", normal: "share_sina", highlighted: "share_sina_hover", id: "sina")
        let wechat = FYShareItemModel(title: "微信", normal: "share_weixin", highlighted: "share_weixin_hover", id: "wechat")
        let qzone = FYShareItemModel(title: "QQ空间", normal: "share_zone", highlighted: "share_zone_hover", id: "qzone")
        
        shareView = FYShareView(frame: view.bounds, items:  [wechat, friend, sina, qq, qzone])
        shareView.delegate = self
        var style = FYShareStyle()
        style.insetHorizontal = 10
        style.cancelHeight = 42
        shareView.style = style
        view.addSubview(shareView)
    }
    
    //MARK: - 创建按钮视图
    
    func setupBtnView() {
        
        let btn = UIButton(type: .system)
        btn.setTitle("点击", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.bounds = CGRect(x: 0, y: 0, width: 100, height: 44)
        btn.center = view.center
        btn.backgroundColor = UIColor.black
        btn.addTarget(self, action: #selector(btnDidTapped), for: .touchUpInside)
        view.addSubview(btn)
    }
    
    @objc func btnDidTapped() {
        shareView.show()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ViewController: FYShareViewDelegate {
    func shareView(itemDidTapped identifier: String) {
        print("identifier:\(identifier)")
    }
}
