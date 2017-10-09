//
//  HelpdeskChatTableViewCell.swift
//  ProviDesk
//
//  Created by Omkar Awate on 09/10/17.
//  Copyright © 2017 Omkar Awate. All rights reserved.
//

import UIKit

protocol tab{
    
}

class HelpdeskChatTableViewCell: UITableViewCell {
    
    @IBOutlet var userMsgView: UIView!
    @IBOutlet var userMsgLbl: UILabel!
    @IBOutlet weak var datelbl: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var profilePictureImage: UIImageView!
    
    @IBOutlet weak var usernameLbl: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}
