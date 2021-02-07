//
//  K.swift
//  Twi SDA Hymnal
//
//  Created by Jay on 04/04/2020.
//  Copyright © 2020 SPERIXLABS. All rights reserved.
//
import Firebase

struct K {
    
    private static let dbName = "hymnal"
    static let dB = Firestore.firestore().collection(dbName)
    static let favDb = Firestore.firestore().collection("\(dbName)_favorite")
    
    struct tableCell {
        static let cellIdentifier = "hymnCell"
        static let favHymnCell = "favHymnCell"
    }
    
    struct segue {
        static let gotoHymn = "loadHymn"
        static let favToHymn = "favToHymn"
    }
    
    struct font {
        static let twiFont = "wogyaf"
        static let twiFontSize = 23
        static let engFont = "Helvetica Neue"
        static let engFontSize = 21
    }
    
    struct hymnView {
        static let eng = "eng"
        static let twi = "twi"
    }
    
    struct hymn {
        static let title = "title"
        static let category = hymnView.self
        static let num = "num"
        static let midi = "midi"
        static let scripture = "scripture"
        static let id = "id"
    }
    
    struct icons {
        static let play = "play.circle"
        static let stop = "stop.circle"
        static let yes = "star.fill"
        static let no = "star"
        static let remove = "Remove"
        static let delete = "trash.fill"
        static let account = "person.crop.circle.fill"
    }
    
    struct sound {
        static let museScore = "museScore"
        static let museScoreExt = "sf2"
        static let soundbank = Bundle.main.url(forResource: K.sound.museScore, withExtension: K.sound.museScoreExt)
        static let audioFormat = "mid"
        static let midiDirectory = "midi"
    }
    
    struct favHymn {
        static let uid = "uid"
    }
    
    struct loader {
        static let loading = "Loading"
    }
}
