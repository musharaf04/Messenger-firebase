//
//  ActivityIndicator.swift
//  MessengerFireBase
//
//  Created by apple on 01/11/2021.
//  Copyright © 2021 apple. All rights reserved.
//

import Foundation
import ALLoadingView

class ActivityIndicator
{
    static let activity = ActivityIndicator()
    func startAnimating()
    {
        ALLoadingView.manager.resetToDefaults(message: "Loading")
        ALLoadingView.manager.blurredBackground = true
        ALLoadingView.manager.animationDuration = 1.0
        ALLoadingView.manager.itemSpacing = 30.0
        ALLoadingView.manager.showLoadingView(ofType: .messageWithIndicator, windowMode: .fullscreen)
    }
    func stopAnimating()
    {
        ALLoadingView.manager.hideLoadingView()
    }
}
