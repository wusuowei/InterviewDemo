//
//  Interview.swift
//  InterviewDemo
//
//  Created by wentianen on 2018/3/19.
//  Copyright © 2018年 wentianen. All rights reserved.
//

import Foundation
import UIKit

// 求一个整数数组中和最大的连续子数组，例如：[1, 2, -4, 4, 10, -3, 4, -5, 1]的最大连续子数组是[4, 10, -3, 4]（需写明思路，并编程实现）。
/*
 *  思路：
 *  1、和最大的子序列的第一个元素肯定是正数
 *  2、因为元素有正有负，因此子序列的最大和一定大于0
 */
struct MaxContinuousSubArray {
    func maxContinuousSubArray(_ array: [Int]) -> [Int] {
        guard !array.isEmpty else { return [Int]() }
        guard !(array.count == 1) else { return array }
        let average = array.reduce(0, +) / array.count
        var maxSum = 0
        var currentSum = 0
        var startIndex: Int = 0
        var endIndex: Int = 0
        array.enumerated().forEach { index, item in
            currentSum += item
            if maxSum < currentSum {
                maxSum = currentSum
                endIndex = index
            }
            if currentSum < average {
                startIndex = index + 1
                currentSum = 0
            }
        }
        let sub = array.enumerated().filter( { ($0.offset >= startIndex && $0.offset <= endIndex) } )
        return sub.map( { $0.element } )
    }
    func test() {
        let array = [1, 2, -4, 4, 10, -3, 4, -5, 1]
        let sub = maxContinuousSubArray(array)
        print("\(sub)")
    }
}

// 图片缓存
struct ImageCacheError: Error {
    enum ImageCacheErrorType {
        case unAvailableUrl
        case networkLoadFailed
    }
    var reason: String
    var type: ImageCacheErrorType
}
class ImageCacheTool {
    var memoryCache = ImageMemoryCache()
    var diskCache = ImageDiskCache()

    func loadImage(urlStr: String, success:@escaping ((UIImage) -> Void), failure:@escaping ((Error) -> Void)) {
        guard let url = URL(string: urlStr) else {
            failure(ImageCacheError.init(reason: "url 非法", type: .unAvailableUrl))
            return
        }
        if let memoryImage = memoryCache.loadImage(urlStr: urlStr) {
            success(memoryImage)
            return
        }
        if let diskImage = diskCache.loadImage(urlStr: urlStr) {
            success(diskImage)
            return
        } else {
            ImageLoader.loadImageData(url, success: { [weak self] imageData in
                if let image = UIImage(data: imageData) {
                    success(image)
                    self?.memoryCache.cacheImage(urlStr: urlStr, image: image)
                    self?.diskCache.cacheImage(urlStr: urlStr, image: image)
                }
                }, failure: failure)
        }
    }
}
struct ImageMemoryCache {
    fileprivate var memoryCache = [String: UIImage]()
    fileprivate var cachePriorityInfo = [String]()
    fileprivate var maxCacheCount = 10
    mutating func loadImage(urlStr: String) -> UIImage? {
        if let memoryImage = memoryCache[urlStr] { // 内存
            markHighPriority(urlStr: urlStr)
            return memoryImage
        }
        return nil
    }
    mutating func cacheImage(urlStr: String, image: UIImage) {
        if memoryCache.count >= maxCacheCount {
            let lowPriorityImageUrl = cachePriorityInfo.removeLast()
            memoryCache[lowPriorityImageUrl] = nil
        }
        memoryCache[urlStr] = image
        markHighPriority(urlStr: urlStr)
    }
    mutating func markHighPriority(urlStr: String) {
        guard let index = cachePriorityInfo.index(of: urlStr), index != 0 else {
            cachePriorityInfo.insert(urlStr, at: 0)
            return
        }
        cachePriorityInfo.remove(at: index)
        cachePriorityInfo.insert(urlStr, at: 0)
    }
}
struct ImageDiskCache {
    fileprivate var cacheDir: String {
        guard let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first else {
            return ""
        }
        let fullPath = "\(cachePath)\\ImageCacheDir"
        return fullPath
    }
    fileprivate var priorityInfo = [String]()
    fileprivate var maxCacheCount = 100
    mutating func loadImage(urlStr: String) -> UIImage? {
        let path = imagePath(urlStr: urlStr)
        if let image = UIImage.init(contentsOfFile: path) {
            markHighPriority(urlStr: urlStr)
            cachePriorityInfoToDisk()
            return image
        }
        return nil
    }
    mutating func cacheImage(urlStr: String, image: UIImage) {
        if priorityInfo.count >= maxCacheCount {
            let lowPriorityImageUrl = priorityInfo.removeLast()
            removeImageFromDisk(urlStr: lowPriorityImageUrl)
        }
        cacheImageToDisk(urlStr: urlStr, image: image)
        markHighPriority(urlStr: urlStr)
        cachePriorityInfoToDisk()
    }
    mutating func markHighPriority(urlStr: String) {
        guard let index = priorityInfo.index(of: urlStr), index != 0 else {
            priorityInfo.insert(urlStr, at: 0)
            return
        }
        priorityInfo.remove(at: index)
        priorityInfo.insert(urlStr, at: 0)
    }

    func cachePriorityInfoToDisk() {
        if !FileManager.default.fileExists(atPath: cacheDir) {
            try? FileManager.default.createDirectory(atPath: cacheDir, withIntermediateDirectories: true, attributes: nil)
        }
        let path = imagePath(urlStr: "CachePriorityInfo")
        NSArray(array: priorityInfo).write(toFile: path, atomically: true)
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
        return "\(cacheDir)\\\(urlStr)"
    }
}

struct ImageLoader {
    static func loadImageData(_ url: URL, success:@escaping ((Data) -> Void), failure:@escaping ((Error) -> Void)) {
        DispatchQueue.global().async {
            guard let imageData = (try? Data(contentsOf: url)) else {
                DispatchQueue.main.async {
                    failure(ImageCacheError.init(reason: "网络加载失败", type: .networkLoadFailed))
                }
                return
            }

            DispatchQueue.main.async {
                success(imageData)
            }
        }
    }
}

