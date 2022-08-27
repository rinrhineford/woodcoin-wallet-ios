//
//  BRTabBar.swift
//  WoodcoinWallet
//
//  Created by Renat Gafarov on 06/08/2022.
//  Copyright © 2022 Aaron Voisine. All rights reserved.
//

import UIKit

class BRTabBar: UITabBar {
    private let defaultColor: UIColor = UIColor(named: "Ocean Deep")!
    private let selectedColor: UIColor = UIColor(named: "Kryptonite")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = defaultColor
        self.tintColor = selectedColor
        self.barTintColor = defaultColor
    }
}
