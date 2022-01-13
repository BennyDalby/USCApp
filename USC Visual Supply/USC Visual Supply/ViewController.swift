//
//  ViewController.swift
//  USC Visual Supply
//
//  Created by benny dalby on 11/20/21.
//

import UIKit
import QRCodeScanner

class ViewController: UIViewController  {
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var textField5: UITextField!
    
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField2: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    
    lazy var viewController = QRCodeScanViewController.create()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        textField1.delegate = self
        textField2.delegate = self
        textField3.delegate = self
        textField4.delegate = self
        textField5.delegate = self
        
        
        
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 164/255, green: 34/255, blue: 59/255, alpha: 1.0)]
        
        
//        let rightBarButton = UIBarButtonItem(title: "Scan", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.myRightSideBarButtonItemTapped(_:)))
        
//        let suggestImage  = UIImage(named: "qr-code")
//        let suggestButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
//        suggestButton.setBackgroundImage(suggestImage, for: .normal)
//        suggestButton.addTarget(self, action: #selector(self.myRightSideBarButtonItemTapped(_:)), for:.touchUpInside)
//
//          // here where the magic happens, you can shift it where you like
//        suggestButton.transform = CGAffineTransform(translationX: 10, y: 0)
//
//          // add the button to a container, otherwise the transform will be ignored
//          let suggestButtonContainer = UIView(frame: suggestButton.frame)
//          suggestButtonContainer.addSubview(suggestButton)
//          let rightBarButton = UIBarButtonItem(customView: suggestButtonContainer)
//
//
//         self.navigationItem.rightBarButtonItem = rightBarButton
//
        
        self.setRightBarButttonWithImage("qr-code")

      //  self.navigationItem.rightBarButtonItem?.image = UIImage(named: "qr-code")
        

        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)

       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        
        super.viewDidDisappear(animated)
        
              
        
        
  
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
//
//        print("disappear \(field1)")
        
        
    }
    
    @objc func myRightSideBarButtonItemTapped(_ sender:UIBarButtonItem!) {
        

                // Set itself as delegate
                viewController.delegate = self
                
                // Present the view controller
                self.present(viewController, animated: true)
        
    }
    
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @IBAction func submitTapped(_ sender: Any) {
        
     
            
        field1 = textField1.text!
                field2 = textField2.text!
                field3 = textField3.text!
                field4 = textField4.text!
                field5 = textField5.text!
        
            
            
        
    }
    

}

extension ViewController : QRCodeScanViewControllerDelegate,UITextFieldDelegate {
   
    
    
    func qrCodeScanViewController(_ viewController: QRCodeScanViewController, didScanQRCode value: String) {
        
        // Dismiss the view controller
               viewController.dismiss(animated: true) { [weak self] in
               
                   self?.textField1.text = value
        
    }
        
        
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            
            
            textField.resignFirstResponder()
            
            return true
        }
    

}
    
}

extension ViewController {
    
    func setRightBarButttonWithImage(_ imagename: String) {
        
        
        let suggestImage  = UIImage(named: imagename)
        let suggestButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        suggestButton.setBackgroundImage(suggestImage, for: .normal)
        suggestButton.addTarget(self, action: #selector(self.myRightSideBarButtonItemTapped(_:)), for:.touchUpInside)

          // here where the magic happens, you can shift it where you like
        suggestButton.transform = CGAffineTransform(translationX: 10, y: 0)

          // add the button to a container, otherwise the transform will be ignored
          let suggestButtonContainer = UIView(frame: suggestButton.frame)
          suggestButtonContainer.addSubview(suggestButton)
          let rightBarButton = UIBarButtonItem(customView: suggestButtonContainer)

        
         self.navigationItem.rightBarButtonItem = rightBarButton
        
        
        
        
    }
    
    
    
    
}



