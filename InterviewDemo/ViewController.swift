//
//  ViewController.swift
//  InterviewDemo
//
//  Created by wentianen on 2018/3/19.
//  Copyright © 2018年 wentianen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView?
    let cacheImageTool = ImageCacheTool()
    var currentIndex = 0
    var isLoading = false

    let imageUrls = ["https://img.25pp.com/uploadfile/soft/images/2015/0612/20150612101439320.jpg",
                     "https://wanzao2.b0.upaiyun.com/system/pictures/28106370/original/1440722717_500x500.png",
                     "https://img3.duitang.com/uploads/item/201511/05/20151105135111_s54Uw.thumb.700_0.jpeg",
                     "https://img3.duitang.com/uploads/item/201608/31/20160831123505_FYxcT.png"
                     ]

    override func viewDidLoad() {
        super.viewDidLoad()
        change()
    }

    @IBAction func change() {
        guard !isLoading else {
            return
        }
        isLoading = true
        currentIndex += 1
        if currentIndex >= imageUrls.count {
            currentIndex = 0
        }
        let imageUrl = imageUrls[currentIndex]
        cacheImageTool.loadImage(urlStr: imageUrl, success: { [weak self] image in
            self?.imageView?.image = image
            self?.isLoading = false
        }) { [weak self] error in
            self?.isLoading = false
            print("\(error)")
        }
    }
}

