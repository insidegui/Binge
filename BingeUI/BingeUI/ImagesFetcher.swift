//
//  ImagesFetcher.swift
//  BingeUI
//
//  Created by Guilherme Rambo on 20/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

#if os(iOS)
    import UIKit
#else
    import Cocoa
    public typealias UIImage = NSImage
#endif

private let _fetcherCache = ImagesFetcherCache()
private struct ImagesFetcherCache {
    let cache = NSCache()
    
    var instance: ImagesFetcherCache {
        return _fetcherCache
    }
}

public struct ImagesFetcher {
    
    private let imageURL: NSURL?
    private let callback: (image: UIImage?) -> ()
    private var cancelled = false
    
    #if os(iOS)
    private let usesDiskCache = true
    #else
    private let usesDiskCache = false
    #endif
    
    private let placeholder = UIImage(named: "placeholder")
    
    private let imagesCache = ImagesFetcherCache().instance.cache
    
    private var cachesPath: String {
        let searchPath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        
        return searchPath[0]
    }
    
    private func cachePathForImageURL(imageURL: NSURL) -> String {
        let filename: String
        if let lastComponent = imageURL.lastPathComponent {
            filename = lastComponent
        } else {
            filename = NSUUID().UUIDString + ".jpg"
        }
        
        return cachesPath + "/" + filename
    }
    
    private func cachedImageForURL(imageURL: NSURL) -> UIImage? {
        if usesDiskCache {
            let cacheFilePath = cachePathForImageURL(imageURL)
            
            if NSFileManager.defaultManager().fileExistsAtPath(cacheFilePath) {
                return UIImage(contentsOfFile: cacheFilePath)
            } else {
                return nil
            }
        } else {
            if let image = imagesCache.objectForKey(imageURL) as? UIImage {
                return image
            } else {
                return nil
            }
        }
    }
    
    private func writeImageToDiskCache(data: NSData, forURL URL: NSURL) {
        let cacheFilePath = self.cachePathForImageURL(URL)
        do {
            try data.writeToFile(cacheFilePath, options: .AtomicWrite)
        } catch {
            print("Unable to save image \(URL) to file \(cacheFilePath): \(error)")
        }
    }
    
    private func writeImageToMemoryCache(image: UIImage, forURL URL: NSURL) {
        imagesCache.setObject(image, forKey: URL)
    }
    
    public init(imageURL: NSURL?, callback: (image: UIImage?) -> ()) {
        self.imageURL = imageURL
        self.callback = callback
        
        load()
    }
    
    public mutating func cancel() {
        cancelled = true
    }
    
    private func load() {
        guard !cancelled else { return }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            guard let URL = self.imageURL else { return }
            
            if let cachedImage = self.cachedImageForURL(URL) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.callback(image: cachedImage)
                }
                return
            }
            
            guard let data = NSData(contentsOfURL: URL) else {
                guard !self.cancelled else { return }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.callback(image: self.placeholder)
                }
                return
            }
            
            guard !self.cancelled else { return }
            
            if self.usesDiskCache {
                self.writeImageToDiskCache(data, forURL: URL)
            }
            
            guard let image = UIImage(data: data) else {
                guard !self.cancelled else { return }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.callback(image: self.placeholder)
                }
                return
            }
            
            if !self.usesDiskCache {
                self.writeImageToMemoryCache(image, forURL: URL)
            }
            
            guard !self.cancelled else { return }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.callback(image: image)
            }
        }
    }
    
}