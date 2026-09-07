//
//  ImageService.swift
//  InterProj
//
//  Created by Andrei Lucacel on 25/06/2026.
//

import UIKit


final class ImageService {
    
    static let shared = ImageService()
    let cache = ImageCache()
    
    
    private init() {
        
    }
    
    private func downloadImage(urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else { throw URLError(.badServerResponse) }
        return image
    }

    func getImage(urlString: String) async -> UIImage {
        
        if let cachedImage = cache.getImage(urlString: urlString) {
            return cachedImage
        }
        
        do {
            
            let downloadedImage = try await downloadImage(urlString: urlString)
            cache.saveImage(image: downloadedImage, urlString: urlString)
            return downloadedImage
        } catch {
            return UIImage(systemName: "person")!
        }
        
        
    }
    
}
