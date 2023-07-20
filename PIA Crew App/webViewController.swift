//
//  webViewController.swift

//
//  Created by Admin on 27/04/2016.
//  Copyright © 2016 PIA. All rights reserved.
//

import UIKit

class webViewController: UIViewController {

    @IBOutlet weak var webview: UIWebView!
    var fileName:String?
    var dc:UIDocumentInteractionController!
    @IBOutlet weak var fileTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("inside viewDidLoad of webViewContoller")
        if let name = self.fileName {
            self.fileTitle.text = name
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let getImagePath = documentsURL.appendingPathComponent(name)
            print("getImagePath" + getImagePath.absoluteString)
            let request = URLRequest(url: getImagePath)
            self.webview.loadRequest(request)
            self.webview.scalesPageToFit=true
        }

  
    }
    
    @IBAction func Done(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func openWith(_ sender: UIBarButtonItem) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let getImagePath = documentsURL.appendingPathComponent(self.fileName!)
        dc = UIDocumentInteractionController(url: getImagePath)
        dc.presentOpenInMenu(from: sender, animated: true)
        
    }
   
}
