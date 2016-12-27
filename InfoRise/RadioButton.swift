//
//  RadioButton.swift
//  InfoRise
//
//  Created by Alec Fong on 12/23/16.
//  Copyright © 2016 Alec Fong. All rights reserved.
//

import UIKit

class RadioButton: UIButton {

    var alternateButton:Array<RadioButton>?
    var color:CGColor?
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2.0
        self.layer.masksToBounds = true
    }
    
    func setButtonColor(color: CGColor){
        self.color = color
    }
    
    func unselectAlternateButtons(){
        if alternateButton != nil {
            self.selected = true
            
            for aButton:RadioButton in alternateButton! {
                aButton.selected = false
            }
        }else{
            toggleButton()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        unselectAlternateButtons()
        super.touchesBegan(touches, withEvent: event)
    }
    
    func toggleButton(){
        self.selected = !selected
    }
    
    override var selected: Bool {
        didSet {
            if selected {
                self.layer.backgroundColor = color
            } else {
                self.layer.borderColor = color
            }
        }
    }

}
