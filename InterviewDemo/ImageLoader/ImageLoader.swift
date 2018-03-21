//
//  ImageLoader.swift
//  InterviewDemo
//
//  Created by wentianen on 2018/3/21.
//  Copyright © 2018年 wentianen. All rights reserved.
//

import Foundation
import UIKit

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
