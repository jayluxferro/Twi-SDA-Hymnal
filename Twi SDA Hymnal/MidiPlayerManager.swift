//
//  MidiPlayerManager.swift
//  Twi SDA Hymnal
//
//  Created by Jay on 04/04/2020.
//  Copyright © 2020 SPERIXLABS. All rights reserved.
//

import AVFoundation


struct MidiPlayerManager {
    var mp: AVMIDIPlayer!
 
    init(mp: AVMIDIPlayer) {
        self.mp = mp
    }
    
}
