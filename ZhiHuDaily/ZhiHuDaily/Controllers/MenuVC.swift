//
//  MenuVC.swift
//  ZhiHuDaily
//
//  Created by xiabob on 17/3/17.
//  Copyright © 2017年 xiabob. All rights reserved.
//

import UIKit

class MenuVC: UIViewController {
    
    fileprivate lazy var loginView: MenuLoginView = {
        let view = MenuLoginView(frame: .zero)
        return view
    }()
    
    fileprivate lazy var topBarView: MenuTopBarView = {
        let view = MenuTopBarView(frame: .zero)
        return view
    }()
    
    fileprivate lazy var bottomBarView: MenuBottomBarView = {
        let view = MenuBottomBarView(frame: .zero)
        return view
    }()
    
    fileprivate lazy var bottomMaskLayer: CALayer = {
        let layer = CAGradientLayer()
        layer.colors = [kMenuBackgroundColor.cgColor, kMenuBackgroundColor.withAlphaComponent(0.0).cgColor]
        layer.startPoint = CGPoint(x: 0, y: 1)
        layer.endPoint = CGPoint(x: 0, y: 0)
        return layer
    }()
    
    fileprivate lazy var menuTableView: UITableView = { [unowned self] in
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(MenuFullCell.self, forCellReuseIdentifier: NSStringFromClass(MenuFullCell.self))
        tableView.register(MenuNormalCell.self, forCellReuseIdentifier: NSStringFromClass(MenuNormalCell.self))
        tableView.backgroundColor = kMenuBackgroundColor
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    fileprivate var themeModels = [[ThemeModel]]()
    
    fileprivate lazy var getThemesDS: GetThemes = {
        let ds = GetThemes()
        return ds
    }()
    
    //MARK: - life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        commonInit()
        configViews()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        loginView.frame = CGRect(x: 0, y: 25, width: view.xb_width, height: 40)
        topBarView.frame = CGRect(x: 0, y: loginView.xb_bottom+10, width: view.xb_width, height: 50)
        bottomBarView.frame = CGRect(x: 0, y: view.xb_bottom-60, width: view.xb_width, height: 60)
        menuTableView.frame = CGRect(x: 0, y: topBarView.xb_bottom, width: view.xb_width, height: bottomBarView.xb_top-topBarView.xb_bottom)
        bottomMaskLayer.frame = CGRect(x: 0, y: menuTableView.xb_bottom-20, width: view.xb_width, height: 20)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadThemes()
    }
    
    //MARK: - config
    
    fileprivate func commonInit() {
        view.backgroundColor = kMenuBackgroundColor
    }
    
    fileprivate func configViews() {
        view.addSubview(loginView)
        view.addSubview(topBarView)
        view.addSubview(bottomBarView)
        view.addSubview(menuTableView)
        view.layer.addSublayer(bottomMaskLayer)
    }
}


//MARK: - get themes ds

extension MenuVC {
    fileprivate func loadThemes() {
        getThemesDS.loadData { [weak self](api) in
            guard let wself = self else {return}
            wself.getThemesDS.subscribedThemeModel.insert(ThemeModel.mainModel(), at: 0)
            wself.themeModels.append(wself.getThemesDS.subscribedThemeModel)
            wself.themeModels.append(wself.getThemesDS.unsubscribedThemeModel)
            
            wself.menuTableView.reloadData()
        }
    }
}


//MARK: - UITableViewDataSource, UITableViewDelegate

extension MenuVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themeModels.count < 2 ? 0 : themeModels[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        let model = themeModels[indexPath.section][indexPath.row]
        if indexPath.section == 0 && indexPath.row == 0{
            let fullCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(MenuFullCell.self), for: indexPath) as! MenuFullCell
            fullCell.refreshViews(with: #imageLiteral(resourceName: "Menu_Icon_Home"), model: model)
            fullCell.delegate = self
            cell = fullCell
        } else {
            let normalCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(MenuNormalCell.self), for: indexPath) as! MenuNormalCell
            normalCell.refreshViews(with: model)
            normalCell.delegate = self
            cell = normalCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.5
        } else {
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let line = UIView()
        line.frame = CGRect(x: 0, y: 0, width: tableView.xb_width, height: 0.5)
        line.backgroundColor = UIColor(red:0.11, green:0.14, blue:0.16, alpha:1)
        return line
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //如果点击的是当前显示的视图
        if themeModels[indexPath.section][indexPath.row].isSelected {
            appDelegate.drawerController.closeDrawer(animated: true, completion: nil)
            return;
        }
        
        //reset model's isSelected
        for model in themeModels.flatMap({$0}) {
            model.isSelected = false
        }
        themeModels[indexPath.section][indexPath.row].isSelected = true
        tableView.reloadData()
        
        let backgroundImage = appDelegate.drawerController.centerViewController.view.snapshotImage()
        var centerVC: UIViewController
        if indexPath.section == 0 {
             centerVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MainNavigationController")
        } else {
            centerVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ThemeNavigationController")
            (centerVC as! ThemeNavigationController).themeId = themeModels[indexPath.section][indexPath.row].themeID
        }
        
        //添加过渡动画
        let backgroundImageView = UIImageView(frame: centerVC.view.bounds)
        backgroundImageView.image = backgroundImage
        centerVC.view.addSubview(backgroundImageView)
        appDelegate.drawerController.setCenterView(centerVC, withCloseAnimation: true) { (finished) in
            UIView.animate(withDuration: 0.25, animations: { 
                backgroundImageView.alpha = 0
            }, completion: { (finished) in
                backgroundImageView.removeFromSuperview()
            })
        }
        
    }
}


//MARK: - MenuCellDelegate

extension MenuVC: MenuCellDelegate {
    func onFlagButtonClicked(in cell: MenuCell, isSubscribed: Bool) {
        if !isSubscribed {
            guard let fromIndexPath = menuTableView.indexPath(for: cell), let model = cell.themeModel else {return}
            model.isSubscribed = true
            
            menuTableView.beginUpdates()
            
            themeModels[1].remove(at: fromIndexPath.row)
            menuTableView.deleteRows(at: [fromIndexPath], with: .none)
            
            themeModels[0].insert(model, at: 1)
            let toIndexPath = IndexPath(row: 1, section: 0)
            menuTableView.insertRows(at: [toIndexPath], with: .top)
            
            menuTableView.endUpdates()
            
            menuTableView.reloadData()
        }
    }
}
