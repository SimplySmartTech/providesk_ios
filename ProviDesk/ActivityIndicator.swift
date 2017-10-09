//
//  ActivityIndicator.swift
//  ProviDesk
//
//  Created by Omkar Awate on 19/09/17.
//  Copyright © 2017 Omkar Awate. All rights reserved.
//

import UIKit

class ActivityIndicator: NSObject {
    
    var myActivityIndicator:UIActivityIndicatorView!
    
    func StartActivityIndicator(obj:UIViewController) -> UIActivityIndicatorView
    {
        
        self.myActivityIndicator = UIActivityIndicatorView(frame:CGRect(x: 100, y: 100, width: 100, height: 100)) as UIActivityIndicatorView
        
        self.myActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.myActivityIndicator.center = obj.view.center;
        
        obj.view.addSubview(myActivityIndicator);
        
        self.myActivityIndicator.startAnimating();
        return self.myActivityIndicator;
    }
    
    func StopActivityIndicator(obj:UIViewController,indicator:UIActivityIndicatorView)-> Void
    {
        indicator.removeFromSuperview();
    }
    
    
}

