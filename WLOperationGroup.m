//
//  WLOperationGroup.m
//  WLOperationQueue
//
//  Created by 张尉 on 2018/7/9.
//  Copyright © 2018年 Wayne. All rights reserved.
//

#import "WLOperationGroup.h"

@interface WLOperationGroup ()

@property (nonatomic) NSPointerArray *mutableOperations;
@property (nonatomic) dispatch_semaphore_t semaphore;

@end


@implementation WLOperationGroup

- (NSArray <NSOperation*>*)operations {
    NSArray *res = nil;
    [self _lock];
    res = [_mutableOperations allObjects];
    [self _unlock];
    return res;
}

- (void)_lock {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
}

- (void)_unlock {
    dispatch_semaphore_signal(_semaphore);
}

- (void)_initLock {
    _semaphore = dispatch_semaphore_create(1);
}

- (instancetype)initWithName:(NSString *)name asynchronous:(BOOL)asynchronous {
    self = [super init];
    if (self) {
        _name = name;
        _asynchronous = asynchronous;
        _mutableOperations = [NSPointerArray weakObjectsPointerArray];
        [self _initLock];
    }
    
    return self;
}

- (instancetype)initWithName:(NSString *)name {
    return [self initWithName:name asynchronous:NO];
}

- (void)addOperations:(NSArray<NSOperation *> *)operations {
    [self _lock];
    [operations enumerateObjectsUsingBlock:^(NSOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         [self.mutableOperations addPointer:(__bridge void*)obj];
    }];
    [self _unlock];
}

- (void)addOperation:(NSOperation *)operation {
    [self _lock];
    [self.mutableOperations addPointer:(__bridge void*)operation];
    [self _unlock];
}

@end
