//
//  FPMainViewController.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 22/01/2020.
//  Copyright © 2020 Naveed Azhar. All rights reserved.
//

import UIKit
import SwiftyXMLParser


class FPMainViewController: UIViewController, UITextFieldDelegate, XMLParserDelegate, UITextViewDelegate {
    
    
    @IBOutlet weak var flightPlanContents: UITextView!
    
    @IBOutlet weak var txtLabelDebug: UILabel!
    
    @IBOutlet weak var segmentControlSections: UISegmentedControl!
    
    var sections: [Section] = []
    var elementName: String = String()
    var sectionName = String()
    var sectionData = String()
    var level = 0
    var sectionFields = [SectionField]()
    
    var selectedSection:Section!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        flightPlanContents.delegate = self
        
        

        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        
        
        // Do any additional setup after loading the view.
        if let path = Bundle.main.path(forResource: "Books", ofType: "xml") {
            
            
            let string = try!  String(contentsOfFile: path)
            
            let xml = try! XML.parse(string)
            
            print(xml.SectionList.section[0].sectionData.text)
            
            
            let parentSectionElements = xml.SectionList.section.all ?? []
            
            
            
            
            for i in 0..<parentSectionElements.count
            {
                sections.append(Section(sectionName: parentSectionElements[i].attributes["Name"]!, sectionData: xml.SectionList.section[i].sectionData.text!, level: Int(parentSectionElements[i].attributes["level"]!)!, fields: [], subSection: []))
                
                let subSectionElements = xml.SectionList.section[i].section.all ?? []
                for j in 0..<subSectionElements.count
                {
                    sections[i].subSection.append(Section(sectionName: subSectionElements[j].attributes["Name"]!, sectionData: xml.SectionList.section[i].section[j].sectionData.text!, level: Int(subSectionElements[j].attributes["level"]!)!, fields: [], subSection: []))
                    
                }
                
            }
            
            if ( sections.count > 0  ) {
                self.selectedSection = self.sections[0]
                self.flightPlanContents.text = self.selectedSection.sectionData
                
                segmentControlSections.removeAllSegments();
                
                for  section in sections {
                    if ( section.level == 1) {
                        segmentControlSections.insertSegment(withTitle: section.sectionName, at: segmentControlSections.numberOfSegments, animated: false)
                    }
                }
                
                segmentControlSections.addTarget(self, action: #selector(segmentedControlValueChanged), for:.valueChanged)
                
                
            }
            
        }
        
        
        
        
        
        
        
        
        
        //        self.highlight(text: ["..", ". . . . . . . . . . ."], colours: [UIColor.lightGray, UIColor.blue])
        
        
        self.flightPlanContents.resignFirstResponder()
        
        if ( selectedSection != nil ) {
            
            self.highlight(fields: selectedSection!.fields, colours: [UIColor.lightGray])
            
            
            for field in selectedSection!.fields {
                print( " field \(field.fieldName)  \(field.startLocationInSection) \(field.length)  \(field.regex)  \(field.padding)  \(field.invalidMessage)" )
            }
        }
        
        
        
    }
    
    func highlight(fields: [SectionField], colours: [UIColor]) {
        var ranges = Array<Int>()
        var attrString = self.flightPlanContents.attributedText.mutableCopy() as! NSMutableAttributedString
        
        for i in 0..<fields.count {
            
            let field = fields[i]
            let col = colours[0]
            // var range = (self.flightPlanContents.text as NSString).range(of: str)
            
            //            let from = self.flightPlanContents.position(from: self.flightPlanContents.beginningOfDocument, offset: field.startLocationInSection - 1)!
            //
            //            let to = self.flightPlanContents.position(from: self.flightPlanContents.beginningOfDocument, offset: field.startLocationInSection - 1 + field.length - 1)!
            //
            //            var range = self.flightPlanContents.textRange(from: from , to: to)
            
            // var nsRange = self.flightPlanContents.text.nsRange(from: range)
            
            
            
            
            var nsRange = NSMakeRange(field.startLocationInSection-1, field.length)
            
            attrString.replaceCharacters(in: nsRange, with: field.updatedValue)
            
            attrString.addAttribute(NSAttributedString.Key.backgroundColor, value: col, range:   nsRange)
            
            
        }
        
        self.flightPlanContents.attributedText = attrString
    }
    
    func highlight(text: [String], colours: [UIColor]) {
        var ranges = Array<Int>()
        let attrString = self.flightPlanContents.attributedText.mutableCopy() as! NSMutableAttributedString
        
        for i in 0..<text.count {
            
            let str = text[i]
            let col = colours[i]
            // var range = (self.flightPlanContents.text as NSString).range(of: str)
            
            var ranges = self.flightPlanContents.text.ranges(of: str)
            
            for range in ranges {
                
                var nsRange = self.flightPlanContents.text.nsRange(from: range)
                attrString.addAttribute(NSAttributedString.Key.backgroundColor, value: col, range:   nsRange)
                
                
            }
        }
        
        self.flightPlanContents.attributedText = attrString
    }
    
    
    @objc func segmentedControlValueChanged(segment: UISegmentedControl) {
        
        self.selectedSection = sections[segment.selectedSegmentIndex]
        
        self.flightPlanContents.text = self.selectedSection.sectionData
        
        self.flightPlanContents.resignFirstResponder()
        
        if ( selectedSection != nil ) {
            
            self.highlight(fields: selectedSection!.fields, colours: [UIColor.lightGray])
            
            
            for field in selectedSection!.fields {
                print( " field \(field.fieldName)  \(field.startLocationInSection) \(field.length)  \(field.regex)  \(field.padding)  \(field.invalidMessage)" )
            }
        }
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    // 1
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if elementName == "section" {
            sectionName = String()
            sectionData = String()
            level = 0
            
            sectionName = attributeDict["Name"] ?? "Naveed"
            level = Int(attributeDict["level"]!) ?? 0
            sectionFields = [SectionField]()
            
        } else if elementName == "field" {
            let tempSectionField = SectionField(fieldName: attributeDict["fieldName"]!, startLocationInSection: Int(attributeDict["startLocationInSection"]!)!, length: Int(attributeDict["length"]!)!, regex: attributeDict["regex"]!, invalidMessage: attributeDict["invalidMessage"]!, padding: attributeDict["padding"]!, initialValue: attributeDict["initialValue"]!, updatedValue: attributeDict["updatedValue"]!)
            sectionFields.append(tempSectionField)
        }
        
        
        //        sectionData = attributeDict["Name"] ?? "Azhar"
        
        self.elementName = elementName
    }
    
    // 2
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        
        if elementName == "section" {
            let section = Section(sectionName: sectionName, sectionData: sectionData, level: level, fields: sectionFields, subSection: [])
            sections.append(section)
        }
    }
    
    // 3
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // do not trim string
        //let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let data = string
        if (!data.isEmpty) {
            if self.elementName == "sectionData" {
                sectionData += data
            }
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        
        if let cursorPosition = textView.selectedTextRange?.start {
            print("\(cursorPosition)")
            let cursorPosition1 = textView.offset(from: textView.beginningOfDocument, to: cursorPosition) + 1
            
            print (" You selected position \(cursorPosition1) ")
            self.txtLabelDebug.text = " You selected position \(cursorPosition1) "
            
            let selectedFieldIndex = self.getSelectedField(cursorPosition: cursorPosition1 )
            if ( selectedFieldIndex != nil) {
                let currentField = selectedSection.fields[selectedFieldIndex!]
                if (currentField != nil) {
                    alertWithTF(selectedFieldIndex: selectedFieldIndex!, title: currentField.fieldName, message: "Please enter " + currentField.fieldName)
                }
            }
            
        }
        
    }
    
    func alertWithTF(selectedFieldIndex: Int, title:String, message:String) {
        
        let sectionField = selectedSection.fields[selectedFieldIndex]
        
        //Step : 1
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert )
        //Step : 2
        let save = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            
            var valid = true
            if textField.text != "" {
                //Read TextFields text data
                print(textField.text!)
                print("TF 1 : \(textField.text!)")
                
                let phoneRegex = "[0-9]{1,6}"
                let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
                valid =  predicate.evaluate(with: textField.text!)
                if ( !valid) {
                    MiscUtils.alert("Invalid value", message: (self.selectedSection.fields[selectedFieldIndex].invalidMessage), controller: self)
                } else {
                    
                    var inputText = textField.text!
                    inputText = inputText.leftPadding(toLength:         sectionField.length, withPad: " ")
                    
                    self.selectedSection.fields[selectedFieldIndex].updatedValue = inputText
                    
                    if ( self.selectedSection != nil ) {
                        
                        self.highlight(fields: self.selectedSection.fields, colours: [UIColor.lightGray])
                    }
                    
                }
            }
            
        }
        
        //Step : 3
        //For first TF
        alert.addTextField { (textField) in
            textField.placeholder = "0000000000"
            textField.textColor = .red
        }
        
        //Step : 4
        alert.addAction(save)
        //Cancel action
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }
        alert.addAction(cancel)
        //OR single line action
        //alert.addAction(UIAlertAction(title: "Cancel", style: .default) { (alertAction) in })
        
        self.present(alert, animated:true, completion: nil)
        
    }
    
    
    
    func getSelectedField(cursorPosition:Int) -> Int? {
        
        if ( selectedSection != nil ) {
            
            for i in 0..<self.selectedSection.fields.count  {
                let field =  self.selectedSection!.fields[i]
                let checkString = "\(field.fieldName) \(field.startLocationInSection) \(cursorPosition) \(field.startLocationInSection + field.length)"
                print(checkString)
                if (field.startLocationInSection <= cursorPosition &&
                    cursorPosition <= field.startLocationInSection + field.length  ) {
                    return i
                }
            }
        }
        return nil
    }
}

extension String {
    
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        
        let newLength = self.count
        
        if newLength < toLength {
            
            return String(repeatElement(character, count: toLength - newLength)) + self
            
        } else {
            
            return self.substring(from: index(self.startIndex, offsetBy: newLength - toLength))
            
        }
    }
    
}

extension String {
    func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while let range = range(of: substring, options: options, range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: locale) {
            ranges.append(range)
        }
        return ranges
    }
}

extension String {
    func nsRange(from range: Range<Index>) -> NSRange {
        let startPos = self.distance(from: self.startIndex, to: range.lowerBound)
        let endPos = self.distance(from: self.startIndex, to: range.upperBound)
        return NSMakeRange(startPos, endPos - startPos)
    }
}



