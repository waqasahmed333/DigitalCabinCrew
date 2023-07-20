//
//  ImagePreviewViewController.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 20/05/2022.
//  Copyright © 2022 Naveed Azhar. All rights reserved.
//

import UIKit

class ImagePreviewViewController: UIViewController {
    
    var filename = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if (  filename != "" ) {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            if (FileManager.default.fileExists(atPath: documentsURL.appendingPathComponent(filename).path)) {
                let data = try? Data(contentsOf: documentsURL.appendingPathComponent(filename)) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                imageViewFuelIndent.image = UIImage(data: data!)
            }
        }
        
    }
    
    @IBOutlet weak var imageViewFuelIndent: UIImageView!
    
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func deleteImage(_ sender: Any) {
        
        
        if (  filename != "" ) {
            
            // create the alert
            let alertC = UIAlertController(title: "Notice", message: "Are you sure you want to delete the image?", preferredStyle: UIAlertController.Style.alert)
            
            // add the actions (buttons)
            alertC.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { action in
                
                return
                
            }))
            
            alertC.addAction(UIAlertAction(title: "Confirm", style: UIAlertAction.Style.destructive, handler: { action in
                
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                do {
                    try FileManager.default.removeItem(atPath: documentsURL.appendingPathComponent(self.filename).path)
                    self.imageViewFuelIndent.image = nil
                } catch {
                    
                }
                
            }))
            
            self.present(alertC, animated: true, completion: nil)

            
        }
        
    }
    
    
}
