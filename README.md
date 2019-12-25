# WLSerialQueue

支持异步操作的同步队列，比如实现一个支持队列的网络请求：


``` objc

WLAsyncOperation *op = [WLAsyncOperation  asyncOperationWithBlock:^(WLAsyncOperation * _Nonnull operation) {
    if (operation.isCancelled) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1000);
        dispatch_async(dispatch_get_main_queue(), ^{
            // exit the queue
            [operation finish];
            // do something here
        });
    });
} inMainQueue:YES];

self.operation = op;
[[WLOperationQueue queueForID:@"NetReq"] addOperationToDefaultQueue:op];

```
