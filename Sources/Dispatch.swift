import Foundation

func delay(delay: Double, closure: (Void) -> Void) {
  let t = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))

  dispatch_after(t, dispatch_get_main_queue(), closure)
}

func dispatch_after_delay(delayInSeconds: Float, queue: dispatch_queue_t, block: dispatch_block_t) {
  let floatNSec = Float(NSEC_PER_SEC)
  let delay = Int64(delayInSeconds * floatNSec)
  let popTime = dispatch_time(DISPATCH_TIME_NOW, delay);

  dispatch_after(popTime, queue, block);
}

func dispatch_after_delay_on_main_queue(delayInSeconds: Float, block: dispatch_block_t) {
  let queue = dispatch_get_main_queue()

  dispatch_after_delay(delayInSeconds, queue: queue, block: block)
}

func dispatch_async_on_high_priority_queue(block: dispatch_block_t) {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), block);
}

func dispatch_async_on_background_queue(block: dispatch_block_t) {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block)
}

func dispatch_async_on_main_queue(block: dispatch_block_t) {
  dispatch_async(dispatch_get_main_queue(), block)
}
