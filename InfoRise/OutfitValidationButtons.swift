//
//  OutfitValidationButtons.swift
//  InfoRise
//
//  Created by Alec Fong on 12/23/16.
//  Copyright © 2016 Alec Fong. All rights reserved.
//

import UIKit

class OutfitValidationButtons: RadioButton {
    
    var tooHotButton:RadioButton!
    var tooColdButton:RadioButton!
    var justRightButton:RadioButton!
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2.0
        self.layer.masksToBounds = true
        tooHotButton = RadioButton()
        tooColdButton = RadioButton()
        justRightButton = RadioButton()
    }

    override var selected: Bool {
        didSet {
            if selected {
                self.layer.borderColor = UIColor.blueColor().CGColor
            } else {
                self.layer.borderColor = UIColor.grayColor().CGColor
            }
        }
    }

}
