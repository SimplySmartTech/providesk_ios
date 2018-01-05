//
//  UpdateStatusViewController.swift
//  ProviDesk
//
//  Created by Omkar Awate on 03/01/18.
//  Copyright © 2018 Omkar Awate. All rights reserved.
//

import UIKit

class UpdateStatusViewController: UIViewController {
    @IBOutlet weak var selectStatusTextField: UITextField!
    @IBOutlet weak var commentTextArea: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBOutlet weak var backTapped: UIImageView!
    
}
