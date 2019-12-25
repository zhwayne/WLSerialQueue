//
//  WLAsyncOperation.m
//  WLOperationQueue
//
//  Created by 张尉 on 2018/7/6.
//  Copyright © 2018年 Wayne. All rights reserved.
//

#import "WLAsyncOperation.h"

@interface WLAsyncOperation ()

@property (nonatomic) dispatch_semaphore_t semaphore;

@end

@implementation WLAsyncOperation

- (BOOL)isAsynchronous {
    return YES;
}

- (void)dealloc {
    _block = nil;
    _beginningBlock = nil;
    [self removeObserver:self forKeyPath:@"executing"];
    DDLogDebug(@"%s", __func__);
}

+ (WLAsyncOperation *)asyncOperationWithBlock:(WLAsyncOperationBlock)block {
    return [self asyncOperationWithBlock:block inMainQueue:NO];
}

+ (WLAsyncOperation *)asyncOperationWithBlock:(WLAsyncOperationBlock)block inMainQueue:(BOOL)runInMainQueue {
    return [[WLAsyncOperation alloc] initWithBlock:block inMainQueue:runInMainQueue];
}

- (instancetype)initWithBlock:(void (^)(WLAsyncOperation * _Nonnull))block inMainQueue:(BOOL)runInMainQueue {
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:@"executing" options:NSKeyValueObservingOptionNew context:nil];
        if (runInMainQueue) {
            _block = [^(WLAsyncOperation *opetation) {
                // 检测当前是否在主队列
                if ([NSOperationQueue currentQueue] == [NSOperationQueue mainQueue]
                    && [NSThread currentThread] == [NSThread mainThread]) {
                    !block ?: block(opetation);
                } else {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        !block ?: block(opetation);
                    }];
                }
            } copy];
        } else {
            _block = [block copy];
        }
    }
    return self;
}

- (instancetype)initWithBlock:(void (^)(WLAsyncOperation *operation))block {
    return [self initWithBlock:block inMainQueue:NO];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:@"executing" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)main {
    if (self.isCancelled) return;
    _semaphore = dispatch_semaphore_create(0);
    do {
        if (self.isCancelled) return;
        if (_block) {
            if (self.isCancelled) return;
            _block(self);
        }
    } while (0);
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
}

- (void)finish {
    if (self.isExecuting != YES) { return; }
    dispatch_semaphore_signal(_semaphore);
    self.block = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"executing"]) {
        !self.beginningBlock ?: self.beginningBlock();
        self.beginningBlock = nil;
        return;
    }
}

@end
