//
//  MaxContinuousSubArray.swift
//  InterviewDemo
//
//  Created by wentianen on 2018/3/21.
//  Copyright © 2018年 wentianen. All rights reserved.
//

import Foundation

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
    func demo() {
        let array = [1, 2, -4, 4, 10, -3, 4, -5, 1]
        let sub = maxContinuousSubArray(array)
        print("\(sub)")
    }
}
