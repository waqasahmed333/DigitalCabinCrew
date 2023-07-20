
//
//  StringUtils.swift
//  FlightLog
//
//  Created by Naveed Azhar on 04/07/2015.
//  Copyright (c) 2015 Naveed Azhar. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext

import Foundation
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG





class StringUtils: NSObject {
    
    class func MD5_New(string: String) -> Data {
            let length = Int(CC_MD5_DIGEST_LENGTH)
            let messageData = string.data(using:.utf8)!
            var digestData = Data(count: length)

            _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
                messageData.withUnsafeBytes { messageBytes -> UInt8 in
                    if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                        let messageLength = CC_LONG(messageData.count)
                        CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                    }
                    return 0
                }
            }
            return digestData
        }
    
    class func md5(string: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        if let data = string.data(using: String.Encoding.utf8) {
            CC_MD5(data.withUnsafeBytes { bytes in
                CC_MD5(bytes, CC_LONG(data.count), &digest)
            }, CC_LONG(data.count), &digest)
        }
        
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        
        return digestHex
    }
    
    class func   getYMDStringFromDMYString(_ str :String) -> String  {
        if str != ""{
            let d = str.substring(with: (str.index(str.startIndex, offsetBy: 0) ..< str.index(str.startIndex, offsetBy: 2)))
            let m = str.substring(with: (str.index(str.startIndex, offsetBy: 2) ..< str.index(str.startIndex, offsetBy: 4)))
            let y = str.substring(with: (str.index(str.startIndex, offsetBy: 4) ..< str.index(str.startIndex, offsetBy: 8)))
            return y + m + d
            
        }
        return ""
        
    }
    
    class func  getDMYStringFromYMDString (_ str :String) -> String  {
        //        if (str == "" ) {
        //            print(str)
        //        }
        let d = str.substring(with: (str.index(str.startIndex, offsetBy: 6) ..< str.index(str.startIndex, offsetBy: 8)))
        let m = str.substring(with: (str.index(str.startIndex, offsetBy: 4) ..< str.index(str.startIndex, offsetBy: 6)))
        let y = str.substring(with: (str.index(str.startIndex, offsetBy: 0) ..< str.index(str.startIndex, offsetBy: 4)))
        return d + m + y
    }
    
    
    class func  getDDMMStringFromYMDString (_ str :String) -> String  {
        //        if (str == "" ) {
        //            print(str)
        //        }
        let d = str.substring(with: (str.index(str.startIndex, offsetBy: 6) ..< str.index(str.startIndex, offsetBy: 8)))
        let m = str.substring(with: (str.index(str.startIndex, offsetBy: 4) ..< str.index(str.startIndex, offsetBy: 6)))
        //        let y = str.substring(with: (str.index(str.startIndex, offsetBy: 0) ..< str.index(str.startIndex, offsetBy: 4)))
        return d + m //+ y
    }
    
    class func isBetweenDate (_ date:Date, beginDate:Date?, endDate:Date?) -> Bool
    {
        if ( beginDate == nil || endDate == nil ) {
            return false
        }
        if  date.compare(beginDate!) == ComparisonResult.orderedAscending {
            return false
        }
        
        if  date.compare(endDate!) == ComparisonResult.orderedDescending {
            return false
        }
        
        return true;
        
    }
    
    class func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-*=(),._")
        return String(text.filter {okayChars.contains($0) })
    }
    
    class func  getDateFromString (_ str :String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyyyy"
        return  dateFormatter.date(from: str)
    }
    
    class func  getDateFromString (_ str :String, dateFormat:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return  dateFormatter.date(from: str)
    }
    
    public class func getNumericFromString(_ str:String) -> String {
        
        let result = String(str.filter { String($0).rangeOfCharacter(from: CharacterSet(charactersIn: "0123456789")) != nil })
        return result
        
    }
    
    class func getStringFromDate(_ date: Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyyyy"
        return dateFormatter.string(from: date!)
    }
    
    
    class func getStringFromDate(_ date: Date?, dateFormat:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date!)
    }
    
    
    class func formatExpiryDuration(label:UILabel, date:Date?) -> Bool  {
        if ( date == nil ) {
            label.text = ""
            return true
        } else {
            let calendar = NSCalendar.current
            // Replace the hour (time) of both dates with 00:00
            let date1 = calendar.startOfDay(for: Date())
            let date2 = calendar.startOfDay(for: date!)
            
            let components = calendar.dateComponents([.day], from: date1, to: date2)
            label.text = String(describing: components.day!)
            if ( components.day! <= 0 ) {
                label.textColor = UIColor.red
                return true
            }
        }
        return false
    }
    
    class func formatExpiryDuration(label:UILabel, dateStr:String)  {
        let date = getDateFromString(getNumericFromString(dateStr))
        let calendar = NSCalendar.current
        
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: Date())
        let date2 = calendar.startOfDay(for: date!)
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        label.text = String(describing: components.day!)
        if ( components.day! <= 0 ) {
            label.textColor = UIColor.red
        }
    }

    
    
    class func getCurrentUTCTime() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")! as TimeZone
        dateFormatter.dateFormat = "HHmm"
        return dateFormatter.string(from: date)
    }
    
    class func  getDateTimeFromString (_ str :String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyyyy HH:mm"
        return  dateFormatter.date(from: str)
    }
    
    class func getStringFromDateTime(_ date: Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyyyy HH:mm"
        return dateFormatter.string(from: date!)
    }
    
    class func getHHMMFromDateTime(_ date: Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date!)
    }
    
    
    class func getMinutesFromHHMM(_ hhmm:String) -> Int {
        let hour =  Int(hhmm.substring(with: (hhmm.index(hhmm.startIndex, offsetBy: 0) ..< hhmm.index(hhmm.startIndex, offsetBy: 2))))!
        
        let minute =  Int(hhmm.substring(with: (hhmm.index(hhmm.startIndex, offsetBy: 2) ..< hhmm.index(hhmm.startIndex, offsetBy: 4))))!
        
        return hour * 60 + minute
    }
    
    class func getHHMMFromMinutes(_ minutes:Int) -> String {
        let mins = minutes % 1440
        return String(format: "%02d%02d",Int(mins/60),mins%60)
    }
    
    class func getDifferenceInMinutes(_ hhmm1:String, hhmm2:String) -> Int {
        let std = StringUtils.getMinutesFromHHMM(hhmm1)
        var sta = StringUtils.getMinutesFromHHMM(hhmm2)
        if ( sta < std ) {
            sta += 1440
        }
        return sta-std
    }
    
    
    class func isEmptyValue(str: String? ) -> Bool {
        
        if ( str == nil || str == "" ) {
            return true
        } else {
            return false;
        }
    }
    
    
    class func isEmptyNSNumberValue(str: NSNumber? ) -> Bool {
        
        if ( str == nil ) {
            return true
        } else {
            return false;
        }
    }
    
    
    class func getFixedString (_ str:String, length:Int, chr:String)  -> String {
        var buffer = str
        
        if ( buffer.count < length) {
            for _ in buffer.count...length - 1 {
                buffer = String(chr) + buffer;
            }
        }
        
        return buffer
        
    }
    
    class func getFixedDigit (_ str:String, length:Int, chr:String)  -> String {
        var buffer = str
        
        if ( buffer.count < length) {
            for _ in buffer.count...length - 1 {
                buffer =  buffer + String(chr) ;
            }
        }
        
        return buffer
        
    }
    
    class func getCodedPosForFlightLogApp (_ status:String ) -> String {
        
        let dict : Dictionary<String, String> = [
            "0": "0", "1": "1", "5": "7", "6": "7", "7": "8", "8": "8", "9": "5"
        ]
        var str = status
        for (key, value) in dict {
            str = str.replacingOccurrences(of: key, with: value)
            if (str != status) {
                break;
            }
        }
        
        print(status + " > " + str)
        
        return str
        
    }
    
    
    
    class func isFlightQueryLegAlreadyPresent (_ flightDate:String, flightNo:String, depStation:String) -> Bool {
        
        
        let fetchreq = NSFetchRequest<FlightQueryLeg>(entityName: "FlightQueryLeg")
        
        let datePredicate = NSPredicate(format: "date = %@", StringUtils.getYMDStringFromDMYString( flightDate))
        let fltNoPredicate = NSPredicate(format: "flightNumber = %@", flightNo)
        let fromPredicate = NSPredicate(format: "depStation = %@", depStation)
        //        let sourcePredicate = NSPredicate(format: "source = %@", "IPAD")
        
        let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate])
        
        fetchreq.predicate = compound
        
        
        let data = try! context.fetch(fetchreq)
        
        return data.count > 0
        
        
    }
    
    class func isCrewMessageAlreadyPresent (_ messageId:String) -> Bool {
        
        
        let fetchreq = NSFetchRequest<CrewMessage>(entityName: "CrewMessage")
        let messageIdPredicate = NSPredicate(format: "id = %@", messageId)
        
        let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [messageIdPredicate])
        
        fetchreq.predicate = compound
        
        
        let data = try! context.fetch(fetchreq) 
        
        return data.count > 0
        
        
    }
    
    
    class func printDifference(_ str1:String, str2:String)  {
        
        //        print("Str1:\r\n" + str1)
        //        print("Str2:\r\n" + str2)
        
        var smallerLength = str1.count
        
        if ( smallerLength > str2.count  ) {
            smallerLength = str2.count
        }
        
        for i in 0..<smallerLength {
            let c1 = str1.substring(with: (str1.index(str1.startIndex, offsetBy: i) ..< str1.index(str1.startIndex, offsetBy: i+1)))
            let c2 = str2.substring(with: (str2.index(str2.startIndex, offsetBy: i) ..< str2.index(str2.startIndex, offsetBy: i+1)))
            
            if ( c1 == c2 ) {
                print ("_", terminator: "")
            } else {
                print (c1, terminator: "")
            }
        }
        
        
        //        print("\r\n length difference =  \(str1.count - str2.count)")
        
    }
    
    class func pastDataExists(_ flightDate:String, flightNo:String, depStation:String) -> Bool {
        
        
        let fetchreq = NSFetchRequest<CrewData>(entityName: "CrewData")
        
        let datePredicate = NSPredicate(format: "date = %@", StringUtils.getYMDStringFromDMYString( flightDate))
        let fltNoPredicate = NSPredicate(format: "fltNo = %@", flightNo)
        let fromPredicate = NSPredicate(format: "from = %@", depStation)
        let sourcePredicate = NSPredicate(format: "source = %@", "IPAD")
        
        let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate,sourcePredicate])
        
        fetchreq.predicate = compound
        
        
        let data = try! context.fetch(fetchreq)
        
        return data.count > 0
        
        
    }
    
    class func isIPADFlightPresent (_ flightDate:String, flightNo:String, depStation:String) -> Bool {
        
        
        let fetchreq = NSFetchRequest<LegData>(entityName: "LegData")
        
        let datePredicate = NSPredicate(format: "date = %@", StringUtils.getYMDStringFromDMYString( flightDate))
        let fltNoPredicate = NSPredicate(format: "fltNo = %@", flightNo)
        let fromPredicate = NSPredicate(format: "from = %@", depStation)
        //        let sourcePredicate = NSPredicate(format: "source = %@", "IPAD")
        
        // modified after duplicate flights were being created.
        
        let statusPredicate = NSPredicate(format: "uploadStatus = nil OR uploadStatus != %@", "Uploaded")
        
        
        let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate, statusPredicate])
        
        fetchreq.predicate = compound
        
        
        let data = try! context.fetch(fetchreq)
        
        return data.count > 0
        
        
    }
    
    
    class func isIPADFlightPresentSavedOrUploaded (_ flightDate:String, flightNo:String, depStation:String) -> Bool {
        
        
        let fetchreq = NSFetchRequest<LegData>(entityName: "LegData")
        
        let datePredicate = NSPredicate(format: "date = %@", StringUtils.getYMDStringFromDMYString( flightDate))
        let fltNoPredicate = NSPredicate(format: "fltNo = %@", flightNo)
        let fromPredicate = NSPredicate(format: "from = %@", depStation)
        //        let sourcePredicate = NSPredicate(format: "source = %@", "IPAD")
        
        // modified after duplicate flights were being created.
        
        let statusPredicate = NSPredicate(format: "uploadStatus = %@ OR uploadStatus = %@ OR uploadStatus == %@", "", "Saved", "Uploaded")
        
        
        let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate, statusPredicate])
        
        fetchreq.predicate = compound
        
        
        let data = try! context.fetch(fetchreq)
        
        return data.count > 0
        
        
    }
    
    
    
    class func removeExistingCrewFromFlight(flightDate:String, flightNo:String, depStation:String, staffno:String) {
        
        
        let fetchreq = NSFetchRequest<CrewData>(entityName: "CrewData")
        
        let datePredicate = NSPredicate(format: "date = %@",  flightDate)
        let fltNoPredicate = NSPredicate(format: "fltNo = %@", flightNo)
        let fromPredicate = NSPredicate(format: "from = %@", depStation)
        let staffnoPredicate = NSPredicate(format: "staffno = %@", staffno)
        
        let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate,staffnoPredicate])
        
        fetchreq.predicate = compound
        
        
        let data = try! context.fetch(fetchreq)
        
        
        for bas: AnyObject in data
        {
            
            context.delete(bas as! NSManagedObject)
            
            
        }
        
        do {
            try context.save()
        } catch _ {
        }
        
    }
    
    class func isInProgressFlightPresent (_ flightDate:String, flightNo:String, depStation:String) -> Bool {
        
        
        let fetchreq = NSFetchRequest<LegData>(entityName: "LegData")
        
        let datePredicate = NSPredicate(format: "date = %@", StringUtils.getYMDStringFromDMYString( flightDate))
        let fltNoPredicate = NSPredicate(format: "fltNo = %@", flightNo)
        let fromPredicate = NSPredicate(format: "from = %@", depStation)
        //        let sourcePredicate = NSPredicate(format: "source = %@", "IPAD")
        
        let statusPredicate = NSPredicate(format: "uploadStatus != nil")
        
        let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate, statusPredicate])
        
        fetchreq.predicate = compound
        
        
        let data = try! context.fetch(fetchreq)
        
        return data.count > 0
        
        
    }
}

extension String {
    
    var MD5: String? {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        
        guard let data = self.data(using: String.Encoding.utf8) else { return nil }
        
        let hash = data.withUnsafeBytes { (bytes: UnsafePointer<Data>) -> [UInt8] in
            var hash: [UInt8] = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes, CC_LONG(data.count), &hash)
            return hash
        }
        
        return (0..<length).map { String(format: "%02x", hash[$0]) }.joined()
    }
    
}


