//
//  ImageCache.swift
//  InterProj
//
//  Created by Andrei Lucacel on 25/06/2026.
//

import UIKit

final class ImageCache {
    
    private let cache = NSCache<NSString, UIImage>()
    
    func saveImage(image: UIImage, urlString: String) {
        cache.setObject(image, forKey: NSString(string: urlString))
    }
    
    func getImage(urlString: String) -> UIImage? {
        return cache.object(forKey: NSString(string: urlString))
    }
}
