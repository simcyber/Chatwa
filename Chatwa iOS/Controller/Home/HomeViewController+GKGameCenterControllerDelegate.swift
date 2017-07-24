//
//  HomeViewController+GKGameCenterControllerDelegate.swift
//  Chatwa iOS
//
//  Created by Javon Davis on 7/23/17.
//  Copyright © 2017 Chatwa. All rights reserved.
//

import Foundation
import GameKit

extension HomeViewController: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
