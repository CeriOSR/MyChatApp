//
//  UserCollectionViewCell.swift
//  Messenger Clone 2.0
//
//  Created by Rey Cerio on 2016-11-22.
//  Copyright © 2016 CeriOS. All rights reserved.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
}

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var toMessageLabel: UILabel!
    
    @IBOutlet weak var toDateLabel: UILabel!
    
    @IBOutlet weak var fromMessageLabel: UILabel!
    
    @IBOutlet weak var fromDateLabel: UILabel!
    
}
