//
//  HelpDeskTableViewCell.swift
//  ProviDesk
//
//  Created by Omkar Awate on 09/10/17.
//  Copyright © 2017 Omkar Awate. All rights reserved.
//

import UIKit

class HelpDeskTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var ComplaintIDLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var flatIDLBl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
