//
//  LoginViewConfiguration.swift
//  Authentication
//
//  Created by Daniela Riesgo on 3/31/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import Foundation

public protocol LoginViewConfigurationType {
    
    var logoImage: UIImage? { get }
    var colorPalette: ColorPaletteType { get }
    var fontPalette: FontPaletteType { get }
    
}

public struct DefaultLoginViewConfiguration: LoginViewConfigurationType {
    
    public let logoImage: UIImage?
    public let colorPalette: ColorPaletteType
    public let fontPalette: FontPaletteType
    
    public init(logoImage: UIImage? = .None) {
        self.logoImage = logoImage
        self.colorPalette = DefaultColorPalette()
        self.fontPalette = DefaultFontPalette()
    }
    
}