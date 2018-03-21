//
//  ImageCacheTool.swift
//  InterviewDemo
//
//  Created by wentianen on 2018/3/21.
//  Copyright © 2018年 wentianen. All rights reserved.
//

import Foundation
import UIKit

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
            memoryCache.cacheImage(urlStr: urlStr, image: diskImage)
            success(diskImage)
            return
        } else {
            ImageLoader.loadImageData(url, success: { [weak self] imageData in
                if let image = UIImage(data: imageData) {
                    success(image)
                    print("网络加载了图片")
                    self?.memoryCache.cacheImage(urlStr: urlStr, image: image)
                    self?.diskCache.cacheImage(urlStr: urlStr, image: image)
                }
            }, failure: failure)
        }
    }
}
