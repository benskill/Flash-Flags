//
//  RootWireframe.swift
//  CountryTrainer
//
//  Created by Ben Sullivan on 12/09/2016.
//  Copyright © 2016 Ben Sullivan. All rights reserved.
//

import UIKit

class RootWireframe: NSObject {
  
  func showRootViewController(viewController: UIViewController, inWindow: UIWindow) {
    let NVC = navigationControllerFromWindow(window: inWindow)
    NVC.viewControllers = [viewController]
    NVC.navigationBar.barStyle = .black
  }
  
  func navigationControllerFromWindow(window: UIWindow) -> UINavigationController {
    let NVC = window.rootViewController as! UINavigationController
    return NVC
  }
}
