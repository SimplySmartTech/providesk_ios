//
//  ViewController.swift
//  ProviDesk
//
//  Created by Omkar Awate on 09/10/17.
//  Copyright © 2017 Omkar Awate. All rights reserved.
//

import UIKit

class ImageViewViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var selectedImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imgHeight = selectedImage.size.height
        let imgWidth = selectedImage.size.width
        print("Image width is :\(imgWidth)")
        print("Image height is :\(imgHeight)")
        print("Screen Height:\(UIScreen.main.bounds.height)")
        print("Screen Width:\(UIScreen.main.bounds.width)")
        
        
        
        if imgHeight > imgWidth {
            self.imageView.contentMode = .scaleAspectFill
            self.selectedImage.draw(in: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.imageView.frame.size.height))
            
        }
        else{
            self.imageView.contentMode = .scaleAspectFit
        }
        
        self.imageView.image = selectedImage
        self.scrollView.delegate = self
        
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        //        self.dismiss(animated: true, completion:nil)
    }
    func tap(sender: UIButton){
        print("Tapped ImageViewViewController")
        //        _ = self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
