//
//  SwitchCell.swift
//  ChowHunt
//
//  Created by Jon O'Keefe on 10/23/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate {
    @objc optional func switchCell(switchCell: SwitchCell, didChangeValue value: Bool)
}

class SwitchCell: UITableViewCell {


    @IBOutlet weak var switchTitle: UILabel!
    @IBOutlet weak var switchView: UISwitch!
    
    weak var delegate: SwitchCellDelegate?
    
    var content: [String: String]! {
        didSet {
            self.switchTitle.text = content["name"]
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        switchView.addTarget(self, action: #selector(onSwitchClicked), for: UIControlEvents.valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)

        // Configure the view for the selected state
    }
    
    func onSwitchClicked() {
        delegate?.switchCell?(switchCell: self, didChangeValue: switchView.isOn)
    }

}
