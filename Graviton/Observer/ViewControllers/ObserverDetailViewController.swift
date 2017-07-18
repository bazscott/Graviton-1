//
//  ObserverDetailViewController.swift
//  Graviton
//
//  Created by Sihao Lu on 7/6/17.
//  Copyright © 2017 Ben Lu. All rights reserved.
//

import UIKit
import StarryNight
import Orbits
import XLPagerTabStrip

enum BodyInfoTarget {
    case star(Star)
    case nearbyBody(Body)
}

class ObserverDetailViewController: UIViewController {
    var target: BodyInfoTarget!

    override func viewDidLoad() {
        super.viewDidLoad()
        childViewControllers.forEach { (viewController) in
            let innerVc = viewController as! ObserverDetailInnerViewController
            innerVc.target = target
        }
        setupViewElements()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.presentTransparentNavigationBar()
    }

    private func setupViewElements() {
    }
}

class ObserverDetailInnerViewController: ButtonBarPagerTabStripViewController {
    var target: BodyInfoTarget!

    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return [BodyInfoViewController(style: .plain)]
    }
}