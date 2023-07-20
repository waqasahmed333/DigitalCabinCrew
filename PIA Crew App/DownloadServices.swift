//
//  DownloadServices.swift

//
//  Created by Naveed Azhar on 29/04/2016.
//  Copyright © 2016 PIA. All rights reserved.
//

import UIKit
import Alamofire

class DownloadServices {

    //download and unzip
    // https://stackoverflow.com/questions/40371977/path-to-downloaded-file-with-alamofire4-swift3
    
    static func downloadFile(_ url:String , callback:@escaping (_ percentage:Double?,_ error:String?)->Void){
        

        // file should be removed first before downloading
        let url2 = url.replacingOccurrences(of: " ", with: "%20")
        print(url2)
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        Alamofire.download(url2,to:destination).downloadProgress(closure: { (p) in
            // This closure is NOT called on the main queue for performance
            // reasons. To update your ui, dispatch to the main queue.
            DispatchQueue.main.async {
                let progress = p.fractionCompleted
                callback(progress , nil)
            }
        }).response(completionHandler: { (response) in
            if response.error != nil{
                callback(nil, response.error?.localizedDescription)
            }
        })
    }
    
    static func downloadMultipleFiles(_  url:[String] , callback:@escaping (_ index: Int, _ percentage:Double?,_ error:String?)->Void){
        

        
        for i in  stride(from: 0, to: url.count, by: 1)   {
        // file should be removed first before downloading
        let url2 = url[i].replacingOccurrences(of: " ", with: "%20")
            
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let getImagePath = documentsURL.appendingPathComponent((url2 as NSString).lastPathComponent)
            print("Checking file" + getImagePath.absoluteString)

            if FileManager.default.fileExists(atPath: getImagePath.path) {
                continue
            }
            
            
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
            
            
            
        Alamofire.download(url2,to:destination).downloadProgress(closure: { (p) in
            // This closure is NOT called on the main queue for performance
            // reasons. To update your ui, dispatch to the main queue.
            DispatchQueue.main.async {
                let progress = p.fractionCompleted
                callback(i, progress , nil)
            }
        }).response(completionHandler: { (response) in
            if response.error != nil{
                callback(i, nil, response.error?.localizedDescription)
            }
        })
        }
    }
    
    
    
    static func createFolder(folderName:String)->URL
    {
        var paths: [Any] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory: String = paths[0] as? String ?? ""
        let dataPath: String = URL(fileURLWithPath: documentsDirectory).appendingPathComponent(folderName).absoluteString
        if !FileManager.default.fileExists(atPath: dataPath) {
            try? FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: false, attributes: nil)
        }
        let fileURL = URL(string: dataPath)
        return fileURL!
    }
    
    static func downloadFlightPlan2(_ url:String,  callback:@escaping (_ percentage:Double?,_ error:String?)->Void){


            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                 var fileURL = createFolder(folderName: "naveedflightplans")
                 let fileName = URL(string : url)
                 fileURL = fileURL.appendingPathComponent((fileName?.lastPathComponent)!)
                 return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
             }
             Alamofire.download(url, to: destination)
                .downloadProgress(closure: { (p) in
                         // This closure is NOT called on the main queue for performance
                         // reasons. To update your ui, dispatch to the main queue.
                         DispatchQueue.main.async {
                             //                    print("Total bytes read on main queue: \(totalBytesRead)")
                             let progress = p.fractionCompleted
             //                print(progress)
             //                print(url)
             //                print(destination)
                             callback(progress , nil)
                         }
                     })
                .response(completionHandler: { (response) in
                            if response.error != nil{
                                let filename = response.response?.suggestedFilename
                                var folderDestination=response.destinationURL?.path
                //                print("folderdestination" + folderDestination!)
                //                print("filename" + filename!)
                                callback(nil, response.error?.localizedDescription)
                            }
                        })

        }
  
        static func downloadFlightPlan(_ url:String , callback:@escaping (_ percentage:Double?,_ error:String?)->Void){
      // @swift3
              // file should be removed first before downloading
              
              var url2 = url.replacingOccurrences(of: " ", with: "%20")
              
              
              let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
              
              // naveedflightplan
              
              Alamofire.download(url2,to:destination).downloadProgress(closure: { (p) in
                  // This closure is NOT called on the main queue for performance
                  // reasons. To update your ui, dispatch to the main queue.
                  DispatchQueue.main.async {
                      //                    print("Total bytes read on main queue: \(totalBytesRead)")
                      let progress = p.fractionCompleted
      //                print(progress)
      //                print(url)
      //                print(destination)
                      callback(progress , nil)
                  }
              }).response(completionHandler: { (response) in
                  if response.error != nil{
                      let filename = response.response?.suggestedFilename
                      var folderDestination=response.destinationURL?.path
      //                print("folderdestination" + folderDestination!)
      //                print("filename" + filename!)
                      callback(nil, response.error?.localizedDescription)
                  }
              })
          }
    
    
    
}
