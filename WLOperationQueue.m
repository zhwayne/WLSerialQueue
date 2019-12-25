//
//  WLOperationQueue.m
//  WLOperationQueue
//
//  Created by 张尉 on 2018/7/6.
//  Copyright © 2018年 Wayne. All rights reserved.
//

#import "WLOperationQueue.h"

@interface WLOperationQueue ()

@property (nonatomic) NSOperationQueue *defaultQueue;
@property (nonatomic) NSMutableDictionary <NSString *, NSOperationQueue*>*groupQueueMap;
@property (nonatomic) NSMutableDictionary <NSString *, NSOperationQueue*>*customQueueMap;
@property (nonatomic) NSLock *lock;
@property (nonatomic, getter=isAsynchronous) BOOL asynchronous;

@end

@implementation WLOperationQueue

static
dispatch_queue_t WLSerialQueueGetReleaseQueue()
{
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

+ (instancetype)shared {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] _init];
    });
    return instance;
}


+ (instancetype)queueForID:(NSString *)ID {
    return [self queueForID:ID asynchronous:NO];
}

+ (instancetype)queueForID:(NSString *)ID asynchronous:(BOOL)asynchronous {
    static NSMutableDictionary *instanceSet = nil;
    static dispatch_semaphore_t sem = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceSet = [NSMutableDictionary dictionary];
        sem = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    WLOperationQueue *instance = instanceSet[ID];
    if (instance == nil) {
        instance = [[self alloc] _init];
        instance.asynchronous = asynchronous;
        instanceSet[ID] = instance;
    }
    dispatch_semaphore_signal(sem);
    return instance;
}

- (instancetype)_init {
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
        _groupQueueMap = @{}.mutableCopy;
        _customQueueMap = @{}.mutableCopy;
    }
    return self;
}

- (NSOperationQueue *)defaultQueue {
    if (!_defaultQueue) {
        _defaultQueue = [[NSOperationQueue alloc] init];
        _defaultQueue.name = NSStringFromClass([self class]);
        if (!self.isAsynchronous) {
            _defaultQueue.maxConcurrentOperationCount = 1;
        }
    }
    return _defaultQueue;
}

- (void)addOperationToDefaultQueue:(NSOperation *)operation {
    [self addOperation:operation toQueueWithName:nil];
}

- (void)addOperation:(NSOperation *)operation toQueueWithName:(NSString *)queueName {
    if (queueName) {
        NSOperationQueue *queue = _customQueueMap[queueName];
        if (queue == nil) {
            queue = [[NSOperationQueue alloc] init];
            queue.name = [NSString stringWithFormat:@"%@Custom%@", self.class, queueName];
            if (!self.isAsynchronous) {
                queue.maxConcurrentOperationCount = 1;
            }
            [_customQueueMap setObject:queue forKey:queueName];
        }
        [queue addOperation:operation];
        if (!objc_getAssociatedObject(queue, "__autoReleaseflag")) {
            objc_setAssociatedObject(queue, "__autoReleaseflag", @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            dispatch_async(WLSerialQueueGetReleaseQueue(), ^{
                [queue waitUntilAllOperationsAreFinished];
                [self.lock lock];
                [self.customQueueMap removeObjectForKey:queueName];
                [self.lock unlock];
            });
        }
    }
    else {
        [self.defaultQueue addOperation:operation];
    }
}


- (void)addOperationGroup:(WLOperationGroup *)group {
    NSOperationQueue *queue = _groupQueueMap[group.name];
    if (queue == nil) {
        queue = [[NSOperationQueue alloc] init];
        queue.name = [NSString stringWithFormat:@"%@Group%@", self.class, group.name];
        if (group.isAsynchronous == NO) {
            queue.maxConcurrentOperationCount = 1;
        } else {
            queue.maxConcurrentOperationCount = group.maxConcurrentOperationCount;
        }
        [_groupQueueMap setObject:queue forKey:group.name];
    }
    [queue addOperations:group.operations waitUntilFinished:NO];
    if (!objc_getAssociatedObject(queue, "__autoReleaseflag")) {
        objc_setAssociatedObject(queue, "__autoReleaseflag", @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        dispatch_async(WLSerialQueueGetReleaseQueue(), ^{
            [queue waitUntilAllOperationsAreFinished];
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (group.allOperationsAreFinished) {
                    group.allOperationsAreFinished();
                }
            });
            [self.lock lock];
            [self.groupQueueMap removeObjectForKey:group.name];
            [self.lock unlock];
        });
    }
}

- (void)cancelAllOperationsInQueueWithName:(NSString *)queueName {
    NSOperationQueue *queue = _customQueueMap[queueName];
    [queue cancelAllOperations];
    // 取消操作后，当所有操作全部停止时，队列会被释放（添加队列时已有释放操作）
}

- (void)cancelAllOperationsInGroupWithName:(NSString *)groupName {
    NSOperationQueue *queue = _groupQueueMap[groupName];
    [queue cancelAllOperations];
    // 取消操作后，当所有操作全部停止时，队列会被释放（添加队列时已有释放操作）
}

- (void)cancelAllOperationsInDefaultQueue {
    // 取消全局队列中的操作
    [self.defaultQueue cancelAllOperations];
}

- (void)cancelAllOperations {
    [self cancelAllOperationsInDefaultQueue];
    [_customQueueMap enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSOperationQueue *obj, BOOL *stop) {
        [obj cancelAllOperations];
    }];
    [_groupQueueMap enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSOperationQueue *obj, BOOL *stop) {
        [obj cancelAllOperations];
    }];
}


- (NSArray<NSOperation *> *)operationsInQueue:(NSString *)queueName {
    return _customQueueMap[queueName].operations;
}

- (NSArray<NSOperation *> *)operationsInDefaultQueue {
    return self.defaultQueue.operations;
}

- (NSArray<NSOperation *> *)operationsInGroup:(NSString *)groupName {
    return _groupQueueMap[groupName].operations;
}

@end
