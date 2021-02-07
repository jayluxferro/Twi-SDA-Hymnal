//
//  FavHymn.swift
//  Twi SDA Hymnal
//
//  Created by Jay on 04/04/2020.
//  Copyright © 2020 SPERIXLABS. All rights reserved.
//
import FirebaseFirestoreSwift

struct FavHymn: Codable {
    @DocumentID var documentId: String?
    var id: Int?
    var uid: String?
    var num: String?
    var hymn: Hymn?
    
    init(num: String, hymn: Hymn, uid: String) {
        self.id = hymn.id
        self.num = num
        self.uid = uid
    }
}
