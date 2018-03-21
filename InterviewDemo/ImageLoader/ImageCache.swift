//
//  ImageCache.swift
//  InterviewDemo
//
//  Created by wentianen on 2018/3/21.
//  Copyright © 2018年 wentianen. All rights reserved.
//

import Foundation
import UIKit

class ImageCache {
    var cachePriorityInfo: [String] = [String]()
    func markHighPriority(urlStr: String) {
        guard let index = cachePriorityInfo.index(of: urlStr) else {
            cachePriorityInfo.insert(urlStr, at: 0)
            return
        }
        cachePriorityInfo.remove(at: index)
        cachePriorityInfo.insert(urlStr, at: 0)
    }
}

class ImageMemoryCache: ImageCache {
    fileprivate var memoryCache = [String: UIImage]()
    fileprivate var maxCacheCount = 5
    func loadImage(urlStr: String) -> UIImage? {
        if let memoryImage = memoryCache[urlStr] { // 内存
            markHighPriority(urlStr: urlStr)
            print("内存加载了图片")
            return memoryImage
        }
        return nil
    }
    func cacheImage(urlStr: String, image: UIImage) {
        if memoryCache.count >= maxCacheCount {
            let lowPriorityImageUrl = cachePriorityInfo.removeLast()
            memoryCache[lowPriorityImageUrl] = nil
        }
        markHighPriority(urlStr: urlStr)
        memoryCache[urlStr] = image
    }
}

class ImageDiskCache: ImageCache {
    fileprivate var cacheDir: String {
        guard let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first else {
            return ""
        }
        let fullPath = "\(cachePath)/ImageCacheDir"
        return fullPath
    }
    fileprivate var maxCacheCount = 100
    func loadImage(urlStr: String) -> UIImage? {
        if cachePriorityInfo.isEmpty {
            cachePriorityInfo = loadPriorityInfoFromDisk()
        }
        let path = imagePath(urlStr: urlStr)
        if let image = UIImage.init(contentsOfFile: path) {
            markHighPriority(urlStr: urlStr)
            cachePriorityInfoToDisk()
            print("磁盘加载了图片")
            return image
        }
        return nil
    }
    func cacheImage(urlStr: String, image: UIImage) {
        if cachePriorityInfo.count >= maxCacheCount {
            let lowPriorityImageUrl = cachePriorityInfo.removeLast()
            removeImageFromDisk(urlStr: lowPriorityImageUrl)
        }
        markHighPriority(urlStr: urlStr)
        cacheImageToDisk(urlStr: urlStr, image: image)
        cachePriorityInfoToDisk()
    }

    func cachePriorityInfoToDisk() {
        if !FileManager.default.fileExists(atPath: cacheDir) {
            try? FileManager.default.createDirectory(atPath: cacheDir, withIntermediateDirectories: true, attributes: nil)
        }
        let path = imagePath(urlStr: "CachePriorityInfo")
        NSArray(array: cachePriorityInfo).write(toFile: path, atomically: true)
    }
    func loadPriorityInfoFromDisk() -> [String] {
        if !FileManager.default.fileExists(atPath: cacheDir) {
            try? FileManager.default.createDirectory(atPath: cacheDir, withIntermediateDirectories: true, attributes: nil)
        }
        let path = imagePath(urlStr: "CachePriorityInfo")
        guard let info = (NSArray(contentsOfFile: path) as? [String]) else {
            return [String]()
        }
        return info
    }
    func cacheImageToDisk(urlStr: String, image: UIImage) {
        let path = imagePath(urlStr: urlStr)
        if let data = UIImageJPEGRepresentation(image, 1) {
            try? data.write(to: URL.init(fileURLWithPath: path), options: Data.WritingOptions.atomic)
        }
    }
    func removeImageFromDisk(urlStr: String) {
        let path = imagePath(urlStr: urlStr)
        try? FileManager.default.removeItem(atPath: path)
    }

    func imagePath(urlStr: String) -> String {
        let path = "\(cacheDir)/\(urlStr.hashValue)"
        return path
    }
}
