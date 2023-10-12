//
//  AudioPreview.swift
//  whatsgoingon
//
//  Created by Fabian Gruß on 06.10.23.
//

import Foundation
import SwiftUI

struct AudioPreviewModel: Hashable {
    var magnitude: Float
    var color: Color
    var hasPlayed: Bool = false
}
