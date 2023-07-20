//
//  DocumentSection.swift

//
//  Created by Naveed Azhar on 29/04/2016.
//  Copyright © 2016 PIA. All rights reserved.
//

import UIKit

class DocumentItem {
   
    var name:String!
    var type:String!
    var createDate:String!
    var url:String!
    var docID:String!
    var subject:String!
    var year:String!
    
    init(name:String,type:String, createDate:String, url:String,docID:String, subject:String, year:String){
        
        self.name = name
        self.type = type
        self.createDate = createDate
        self.url = url
        self.docID = docID
        self.subject = subject
        self.year = year
    }
}

class LFEDocumentItem {
   
    var filename:String!
    var type:String!
    var createDate:String!
    var url:String!
    var docID:String!
    var subject:String!
    var iata:String!
    var icao:String!
    
    init(filename:String,type:String, createDate:String, url:String,docID:String, subject:String, iata:String, icao:String){
        
        self.filename = filename
        self.type = type
        self.createDate = createDate
        self.url = url
        self.docID = docID
        self.subject = subject
        self.iata = iata
        self.icao = icao
    }
}

class DocumentSection {

    
    var title:String!
    var description:String!
    var documents=[DocumentItem]()
    
    
    init(title:String,description:String, documents:[DocumentItem]){
        
        self.title = title
        self.description = description
        self.documents = documents
    }
    
    
}


class LFEDocumentSection {

    
    var title:String!
    var description:String!
    var documents=[LFEDocumentItem]()
    
    
    init(title:String,description:String, documents:[LFEDocumentItem]){
        
        self.title = title
        self.description = description
        self.documents = documents
    }
    
    
}


