//
//  Sugar.swift
//  mauth
//
//  Created by Marat S. on 11/10/15.
//  Copyright © 2015 emfo. All rights reserved.
//

import Foundation

func dispatch_async_on_main_queue(block: dispatch_block_t) {
  dispatch_async(dispatch_get_main_queue(), block)
}

func dispatch_async_on_global_queue(block: dispatch_block_t) {
  let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
  dispatch_async(queue, block)
}

func dispatch_after_delay_on_main_queue(delayInSeconds: Float, block: dispatch_block_t) {
  let queue = dispatch_get_main_queue()
  dispatch_after_delay(delayInSeconds, queue: queue, block: block)
}

func dispatch_after_delay(delayInSeconds: Float, queue: dispatch_queue_t, block: dispatch_block_t) {
  let nSecF = Float(NSEC_PER_SEC)
  let delay = Int64(delayInSeconds * nSecF)
  let popTime = dispatch_time(DISPATCH_TIME_NOW, delay);
  dispatch_after(popTime, queue, block);
}

//func dispatch_async_on_background_queue(block: dispatch_block_t) {
//  let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
//  dispatch_async(queue, block)
//}
