//
//  CreateChannelCell.swift
//  Chatting
//
//  Created by magicmon on 2017. 4. 17..
//  Copyright © 2017년 magicmon. All rights reserved.
//

import UIKit

class CreateChannelCell: UITableViewCell {
    @IBOutlet weak var newChannelNameField: UITextField!
    @IBOutlet weak var createChannelButton: UIButton!
    
    var touchedCell: ((String?) -> Void)?
}

extension CreateChannelCell {
    @IBAction func createChannel(_ sender: UIButton) {
        newChannelNameField.resignFirstResponder()
        touchedCell?(newChannelNameField?.text)
        newChannelNameField.text = ""
    }
}
