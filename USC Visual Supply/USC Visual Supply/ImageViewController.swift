//
//  ImageViewController.swift
//  USC Visual Supply
//
//  Created by benny dalby on 11/27/21.
//

import UIKit
import MessageUI
import CoreLocation
import MapKit

enum MailStatus {
    
    case calledOnce
    case noPhotos
    case noCall
}



protocol imageDelegate: AnyObject {
    
    
    func recieveImage(_ image: UIImage,_ pngData: CVPixelBuffer,_ depthData:CVPixelBuffer)
    
}

class ImageViewController: ViewController, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet var overlayView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var collectionList: UICollectionView!
    var imageList = [UIImage]()
    var imagePicker =  UIImagePickerController()
    var cameraTimer = Timer()
    private var imageModelList = [ImageModel]()
    private var imageData : Data? = Data()
    private var imageDepthData : Data? = Data()
    var depthStriing : String = ""
    var filepathStr = ""
    let locManager = CLLocationManager()
    var deviceModel = DeviceData()
    var isEdit: Bool = false
    var status : MailStatus = .noPhotos

  
    override func viewDidLoad() {
 
        
        collectionList.delegate = self
        collectionList.dataSource = self
        
        
        collectionList.setMessage("No photos")
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        layout.itemSize = CGSize(width: 75, height: 100)
                 layout.minimumInteritemSpacing = 5
                 layout.minimumLineSpacing = 5
        collectionList.collectionViewLayout = layout
        
        loadCell()

        self.setRightBarButttonWithImage("email")
        setupLocationServices()
        
        DispatchQueue.global(qos: .background).async {
            
            self.deviceModel.ipAddress = self.getIPAddress()
        }
        
        
        
    }
    
    @objc override func myRightSideBarButtonItemTapped(_ sender:UIBarButtonItem!) {
        
        self.sendMail()
        
    }
    
    func setupLocationServices() {
        
        if CLLocationManager.locationServicesEnabled() {
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.requestAlwaysAuthorization()
            locManager.requestLocation()
            
        }
        
        
    }
    
    func loadCell() {
        
        
        let nib = UINib(nibName: "cell", bundle: nil)
        collectionList.register(nib, forCellWithReuseIdentifier: "Cell")
    }
    
    
    @IBAction func removeAll(_ sender: Any) {
        
        
        imageList.removeAll()
        
        collectionList.reloadData()
        collectionList.setMessage("No Photos")
        
        status = .noPhotos
        

    }
    
    
    
    @IBAction func editClicked(_ sender: Any) {
        
        isEdit = !isEdit
        
        
    }
    
    
    

    @IBAction func TakeImage(_ sender: Any) {
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        
        let arVC = storyboard?.instantiateViewController(withIdentifier: "arViewController") as! ARViewController
//
        arVC.modalPresentationStyle = .fullScreen
        
        present(arVC, animated: true) {
            
            self.collectionList.reloadData()
            self.collectionList.removeMessage()
            
        }
        
        arVC.delegate = self
       
    }
    
    
    func sendMail() {
        
        if status == .noPhotos {
            
            return
        }
        
        
      if( MFMailComposeViewController.canSendMail()){
         //   print("Can send email.")
          
          
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self

            //Set to recipients
            mailComposer.setToRecipients(["d4dalby@gmail.com"])

            //Set the subject
            mailComposer.setSubject("Attached are the image meta data")

            //set mail body
          
          
          var body = """
                        Hello,<br>
                        Attaching the image in base64 encoding and its meta data.<br>
                                                        field 1 : \(field1) <br>
                                                        field 2 : \(field2) <br>
                                                        field 3 : \(field3) <br>
                                                        field 4 : \(field4) <br>
                                                        field 5 : \(field5) <br>
                    """
          
          mailComposer.setMessageBody(body, isHTML: true)
            
          
          print("number of items is \(imageModelList.count)")
          
          
              
              let filePathDeviceData = "\(NSTemporaryDirectory())DeviceData.txt"
              if let fileData = NSData(contentsOfFile:filePathDeviceData )
              {
    //              print("File data loaded 3 \(item.filePathRGBMeta!).")
                  mailComposer.addAttachmentData(fileData as Data, mimeType: "text/plain", fileName:"deviceData.txt" )
                  status = .calledOnce
              }
             
          
          
          
          
          for (i,item) in imageModelList.enumerated() {
              
            
              
              if let fileData = NSData(contentsOfFile: item.filePathRGB!)
              {
                  print("File data loaded 1 \(item.filePathRGB!).")
                  mailComposer.addAttachmentData(fileData as Data, mimeType: "text/plain", fileName:"rgbPNG\(i+1).txt" )
              }
              
              if let fileData = NSData(contentsOfFile: item.filePathDepth!)
              {
                  print("File data loaded 2 \(item.filePathDepth!).")
                  mailComposer.addAttachmentData(fileData as Data, mimeType: "text/plain", fileName:"depthPNG\(i+1).txt" )
              }
              
              if let fileData = NSData(contentsOfFile: item.filePathRGBMeta!)
              {
                  print("File data loaded 3 \(item.filePathRGBMeta!).")
                  mailComposer.addAttachmentData(fileData as Data, mimeType: "text/plain", fileName:"RGBMeta\(i+1).txt" )
              }
              
              if let fileData = NSData(contentsOfFile: item.filePathDepthMeta!)
              {
                  print("File data loaded 4 \(item.filePathDepthMeta!).")
                  mailComposer.addAttachmentData(fileData as Data, mimeType: "text/plain", fileName:"DepthMeta\(i+1).txt" )
              }
          
          }
          
          
          //device data
          
         
          
          
         

            //this will compose and present mail to user
            self.present(mailComposer, animated: true, completion: nil)
        }
        else
        {
            print("email is not supported")
        }
        
    }
    
    func getIPAddress() -> String {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }

                guard let interface = ptr?.pointee else { return "" }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                    // wifi = ["en0"]
                    // wired = ["en2", "en3", "en4"]
                    // cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]

                    let name: String = String(cString: (interface.ifa_name))
                    if  name == "en0" || name == "en2" || name == "en3" || name == "en4" || name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t((interface.ifa_addr.pointee.sa_len)), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address ?? ""
    }
    
    
    
    
    
}

extension ImageViewController : MFMailComposeViewControllerDelegate {
    
    
    func mailComposeController(_ didFinishWithcontroller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
      {
        self.dismiss(animated: true, completion: nil)
      }
    
}

extension ImageViewController : CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
        
        let locValue:CLLocationCoordinate2D = location.coordinate
        
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        deviceModel.latitute = String(format: "%f", locValue.latitude)
        deviceModel.longitude = String(format: "%f", locValue.longitude)
        
        print("LAT: \(deviceModel.latitute) & LONG: \(deviceModel.longitude)")
        
        
        var deviceInfoStr = "IP Address : \(self.deviceModel.ipAddress) Longitude : \(self.deviceModel.longitude) Latitude : \(self.deviceModel.latitute) Date : \(Date())"
        
        print("deviceInfoStr = \(deviceInfoStr)")
        
        let filePathDeviceData = "\(NSTemporaryDirectory())DeviceData.txt"
        
        deviceInfoStr.writeToFile(filePathDeviceData)
        
    }
        
        
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Failed to find user's location: \(error.localizedDescription)")
        }


    
}

extension ImageViewController : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
                self.imagePicker.dismiss(animated: true) {
                
                    let image = info[.originalImage] as? UIImage
                
                self.imageList.append(image!)
                
                self.collectionList.removeMessage()
                
                self.collectionList.reloadData()
                
        }
                
    }
    
}


extension ImageViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ImageCollectionViewCell
        
        guard let cell = cell else {
            
            return UICollectionViewCell()
        }
        
        cell.imageView.image = imageList[indexPath.row]
        
        
        return cell
    }
    
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        let alert = UIAlertController(title: "Future Works..", message: "Image under processing...", preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//
//        self.present(alert, animated: true) {
//
//
//
//        }
//
//
//    }
    
    
    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         
         
         if indexPath.row >= self.imageModelList.count {
             
             let alert = UIAlertController(title: "Processing", message: "Image is under construction..Please wait..", preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                             
             self.present(alert, animated: true, completion: nil)

             return
         }
         
      
         let imageDetailVC = storyboard?.instantiateViewController(withIdentifier: "imageDetailVC") as! ImageDetailViewController

         imageDetailVC.modalPresentationStyle = .fullScreen

         let item = self.imageModelList[indexPath.row]

               imageDetailVC.rgbImage = item.rgbImage
                imageDetailVC.depthImage = item.depthImage

         navigationController?.pushViewController(imageDetailVC, animated: true)
         
    }

    

}

extension ImageViewController : imageDelegate {
    
    func recieveImage(_ image: UIImage,_ capturedImage: CVPixelBuffer,_ depthmap: CVPixelBuffer) {
        
        self.imageList.append(image)
       
        DispatchQueue.global(qos: .background).async {
            
            let rgbImage = self.convertDepthRBGToImage(capturedImage)
            let depthImage = self.convertDepthRBGToImage(depthmap)
            
            let rgbMetaDataString = self.getMetaData(rgbImage.pngData())
            let depthMetaDataString = self.getMetaData(depthImage.pngData())
            
            let filePathRGB = "\(NSTemporaryDirectory())rgbPNG\(self.imageModelList.count + 1).txt"
            let filePathDepth = "\(NSTemporaryDirectory())depthPNG\(self.imageModelList.count + 1).txt"
            
            let filePathRGBMeta = "\(NSTemporaryDirectory())RGBMeta\(self.imageModelList.count + 1).txt"
            let filePathDepthMeta = "\(NSTemporaryDirectory())DepthMeta\(self.imageModelList.count + 1).txt"
            
        //    print(filePathRGB)
         //   print(filePathDepth)
         //   print(filePathRGBMeta)
         //   print(filePathDepthMeta)
            
            let imageModel = ImageModel(image: image, depthImage: depthImage, rgbImage: rgbImage,rgbData: capturedImage, sceneDepthData: depthmap,rgbImageData: rgbImage.pngData(),depthData: depthImage.pngData(),rgbMeta: rgbMetaDataString,depthMeta: depthMetaDataString,filePathRGB: filePathRGB,filePathDepth: filePathDepth,filePathRGBMeta: filePathRGBMeta, filePathDepthMeta:filePathDepthMeta)
            
            self.imageModelList.append(imageModel)
            
            guard let rgbPNG = rgbImage.pngData() else {
                
                return
            }

            guard let depthPNG = depthImage.pngData() else {
                
                return
            }
            
            let rbgStr = rgbPNG.base64EncodedString(options: .lineLength64Characters)
            let depthStr = depthPNG.base64EncodedString(options: .lineLength64Characters)

            
            rbgStr.writeToFile(filePathRGB)
            depthStr.writeToFile(filePathDepth)
            rgbMetaDataString.writeToFile(filePathRGBMeta)
            depthMetaDataString.writeToFile(filePathDepthMeta)
            if self.status == .noPhotos {
                
                self.status = .noCall
            }
            
//            let depthString = depthImage.getDepthDataPerPixel(0, 0, depthmap)
//            let depthData = [depthString]
//
//            let depthJsonData =  self.getDepthJsonData(depthData)
//
          
            UIImageWriteToSavedPhotosAlbum(rgbImage, self, #selector(self.saveError), nil)
            UIImageWriteToSavedPhotosAlbum(depthImage, self, #selector(self.saveError), nil)
          //  self.imageModelList.append(imageModel)
            
        }
        
        DispatchQueue.main.async {
            
            self.collectionList.reloadData()
            
        }
        
    }
    
    
    func getMetaData(_ data: Data?) -> String {
        
        
        let source = CGImageSourceCreateWithData(data as! CFData, nil)!
        
        let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as! NSDictionary
       // print("meta data is \(metadata)")
        
        
        let metaDataString = (metadata.compactMap({ (key, value) -> String in
            return "\(key)=\(value)"
        }) as Array).joined(separator: ";")

        
        // filepathStr = metaDataString.writeToFile("output.txt")
        
        
        return metaDataString
    }
    
    
    func getDepthJsonData(_ depthData:[String])-> Data? {
        
        
        do {
            
        let jsonData = try? JSONSerialization.data(withJSONObject: depthData, options: [])
            
            
            let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
            
                        do {
                            let depthJson = try encoder.encode(jsonData as! Data)
            
                            
                            return depthJson
                        }
                        catch {
            
                            print("catch depth error")
            
                        }

    
      } catch {
            
          print("catch depth error")

        }
        
        
        return nil
        
    }
    
    
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("error: \(error.localizedDescription)")
        } else { }
    }
    

    
    func convertDepthRBGToImage(_ buffer: CVPixelBuffer)->UIImage {
        
        
        let depthCIImage = CIImage(cvPixelBuffer: buffer)
        let context: CIContext = CIContext.init(options: nil)
        let depth_RGB_CGImage: CGImage = context.createCGImage(depthCIImage, from: depthCIImage.extent)!
        let uIImage = UIImage.init(cgImage: depth_RGB_CGImage)
        
        return uIImage
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
      //  print("path is ",paths[0])
        return paths[0]
    }
    
}


extension UICollectionView {
  func setMessage(_ message: String) {
      let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
      messageLabel.text = message
      messageLabel.textColor = .darkGray
      messageLabel.numberOfLines = 0
      messageLabel.textAlignment = .center
      messageLabel.sizeToFit()
      messageLabel.font = UIFont(name: messageLabel.font.fontName, size: 32)

      self.backgroundView = messageLabel
  }
  func removeMessage() {
      self.backgroundView = nil
  }
  }

extension UIImage {
      
    func getRGBDataPerPixel (x: Int, y: Int) -> [RGBDataImage]? {

            if x < 0 || x > Int(size.width) || y < 0 || y > Int(size.height) {
                return []
            }

            let provider = self.cgImage!.dataProvider
            let providerData = provider!.data
            let data = CFDataGetBytePtr(providerData)

            let numberOfComponents = 4
        
        var rgbDataList = [RGBDataImage]()
       
        
        
        for x in 0..<Int(size.width) {
            for y in 0..<Int(size.height) {
                
                let pixelData = ((Int(size.width) * y) + x) * numberOfComponents

                let r = CGFloat(data![pixelData]) / 255.0
                let g = CGFloat(data![pixelData + 1]) / 255.0
                let b = CGFloat(data![pixelData + 2]) / 255.0
                let a = CGFloat(data![pixelData + 3]) / 255.0
                
              //  print("Red:\(r) Green:\(g) Blue:\(b) Alpha:\(a) ")
                
                var rgbPixelData = RGBDataImage(red: r, green: g, blue: b, alpha: a)
                rgbDataList.append(rgbPixelData)

            }
            
           // print("\n")
        }
        
        return rgbDataList
        
        }
    
    func getDepthDataPerPixel(_ x:Int,_ y:Int,_ depthDataMap: CVPixelBuffer)-> String {
        
        // Useful data
            let width = CVPixelBufferGetWidth(depthDataMap) //768 on an iPhone 7+
            let height = CVPixelBufferGetHeight(depthDataMap) //576 on an iPhone 7+
            CVPixelBufferLockBaseAddress(depthDataMap, CVPixelBufferLockFlags(rawValue: 0))

            // Convert the base address to a safe pointer of the appropriate type
            let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(depthDataMap), to: UnsafeMutablePointer<Float32>.self)

            // Read the data (returns value of type Float)
            // Accessible values : (width-1) * (height-1) = 767 * 575
        
        var depthList = [DepthDataImage]()
        var depthString : String = ""
        
        
        for x in 0..<width {
            for y in 0..<height {
                
                let distanceAtXYPoint = floatBuffer[Int(x * y)]
                
               // print("\(distanceAtXYPoint)")
                
                let depthData = DepthDataImage(distance: Double(distanceAtXYPoint))
                
              //  print(depthData)
                
                depthString += String(Double(distanceAtXYPoint)) + "    "
                
                depthList.append(depthData)
            }

        }

        return depthString
    
    }
  }


enum ParseError : Error {
    
    case parseIssue
}


extension Data {
    
    
    func writeToFile(_ fileName:String) {
        
        let file = "file://\(fileName)"
      
        let url = URL(string: file)!
        print("url is \(url)")
        do {
            
            try self.write(to: url, options: .noFileProtection)
            
        }catch {
            
            print("Throw error is \(error)")
        }
        
    }
    
    
    
    
}

extension String {
    
    
    func writeToFile(_ fileName:String) {
        
        // Set the contents
     //   let fileContentToWrite = "Text to be recorded into file"
        do {
            // Write contents to file
            try self.write(toFile: fileName, atomically: false, encoding: String.Encoding.utf8)
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
        
        
    }
    
    
   
    
}


