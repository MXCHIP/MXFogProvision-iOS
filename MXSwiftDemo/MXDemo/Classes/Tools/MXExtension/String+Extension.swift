//
//  String+Extension.swift
//  MXApp
//
//  Created by Khazan on 2021/8/3.
//

import Foundation
import UIKit

extension String {
    func getStringSize(font:UIFont, viewSize: CGSize) -> CGSize {
        let rect = self.boundingRect(with: viewSize, options: [.usesLineFragmentOrigin, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: font], context: nil)
        return rect.size
    }
}
