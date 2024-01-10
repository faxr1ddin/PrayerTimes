//
//  TabBarController.swift
//  PrayerTimes_Demo
//
//  Created by Faxriddin Mo'ydinxonov on 10/01/24.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        //view settings
        initViews()
    }
    
    private func initViews() {
        let category = UIViewController()
        let favorite = PrayerTimeViewController()
        let cart = UIViewController()
        let status = UIViewController()
        
        category.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "unsel")?.withRenderingMode(.alwaysOriginal).withTintColor(.gray), selectedImage: UIImage(named: "diamond")?.withRenderingMode(.alwaysOriginal))
        favorite.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "favUns")?.withRenderingMode(.alwaysOriginal).withTintColor(.gray), selectedImage: UIImage(named: "favSel")?.withRenderingMode(.alwaysOriginal))
        cart.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "cartUns")?.withRenderingMode(.alwaysOriginal).withTintColor(.gray), selectedImage: UIImage(named: "cartSel")?.withRenderingMode(.alwaysOriginal))
        status.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "statusUns")?.withRenderingMode(.alwaysOriginal).withTintColor(.gray), selectedImage: UIImage(named: "status")?.withRenderingMode(.alwaysOriginal))
        viewControllers = [category, favorite, cart, status]
        tabBar.backgroundColor = .white
        tabBar.layer.cornerRadius = 25
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
}
