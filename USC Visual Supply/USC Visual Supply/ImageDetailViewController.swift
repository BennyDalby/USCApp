//
//  ImageDetailViewController.swift
//  USC Visual Supply
//
//  Created by benny dalby on 12/18/21.
//

import UIKit

class ImageDetailViewController: UIViewController {
    
    var rgbImage = UIImage()
    var depthImage = UIImage()
    @IBOutlet weak var rgbImageView: UIImageView!
    
    @IBOutlet weak var depthImageView: UIImageView!
    override func viewDidLoad() {
      //  super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        rgbImageView.image = rgbImage
        depthImageView.image = depthImage
        
       // print("Inside here ImageDetailViewController")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
