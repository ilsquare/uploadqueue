//
//  UploadQueueManager.m
//  detu_uploadqueue
//
//  Created by lsq on 2017/7/20.
//  Copyright © 2017年 detu. All rights reserved.
//

#import "UploadQueueManager.h"
#import "UploadRequestManager.h"

@interface UploadQueueManager ()

// 上传列表
@property (nonatomic, strong) NSMutableArray *uploadList;

// 上传线程
@property (nonatomic, strong) NSOperationQueue *uploadQueue;

// 任务锁
@property (nonatomic, strong) NSConditionLock *conditionlock;

// lock
@property (strong , nonatomic) dispatch_semaphore_t semaphore;

@end

@implementation UploadQueueManager

+ (instancetype)sharedInstance{
    static id obj = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        obj = [[self alloc]init];
        [obj initQueue];
    });
    return  obj;
    
}

- (void)initQueue{
    self.maxParallel = 1;
    self.conditionlock = [[NSConditionLock alloc] init];
    self.semaphore  = dispatch_semaphore_create(1);
    [self uploadList];
    [self uploadQueue];
    
}

- (NSMutableArray *)uploadList{
    if (!_uploadList) {
        _uploadList = [[NSMutableArray alloc] init];
    }
    return _uploadList;
    
}

- (NSOperationQueue *)uploadQueue{
    if (!_uploadQueue) {
        _uploadQueue = [[NSOperationQueue alloc] init];
    }
    return _uploadQueue;
    
}

#pragma mark - 锁
- (void)_lock{
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
}
- (void)_unlock{
    dispatch_semaphore_signal(_semaphore);
}

// 加入上传队列
- (void)addTask:(UploadQueueModel *)queueModel{
    [self _lock];
    [self.uploadList addObject:queueModel];
    [self _unlock];
    
}

// 开始上传
- (void)startUpload{
    int uploadCount = 0;
    for (int i = 0; i < self.uploadList.count; i ++) {
        //  最大并发数
        if (uploadCount < self.maxParallel) {
            [self _lock];
            UploadQueueModel *queueModel = [self.uploadList objectAtIndex:i];
            if (queueModel.state == UPLOADING_STATE_WAIT) {
                [self oneUpload:queueModel];
                uploadCount ++;
            }
            [self _unlock];
        }
    }
    
}

// 单个上传
- (void)oneUpload:(UploadQueueModel *)queueModel{
    // 获取签名
    NSBlockOperation *signTaskOperation = [NSBlockOperation blockOperationWithBlock:^{
        [self signTask:queueModel];
    }];
    // 建立依赖关系, 先获取签名在上传
    [self.uploadQueue addOperation:signTaskOperation];
}

// 获取签名
- (void)signTask:(UploadQueueModel *)queueModel{
    UploadModel *uploadmodel = queueModel.uploadmodel;
    __weak typeof(self) weak = self;
    NSLog(@"获取签名");
    [[UploadRequestManager sharedInstance] requestSign:uploadmodel complete:^(id sign, BOOL success) {
        __strong typeof(weak) self = weak;
        if (success) {
            NSString *code = [sign objectForKey:@"code"];
            if (code.intValue == 1) {
                NSLog(@"%@获取签名成功%@",uploadmodel.fileName,[[sign objectForKey:@"data"] objectForKey:@"key"]);
                NSString *key = [[sign objectForKey:@"data"] objectForKey:@"key"];
                NSString *token = [[sign objectForKey:@"data"] objectForKey:@"token"];
                uploadmodel.sign = key;
                uploadmodel.token = token;
                queueModel.state = UPLOADING_STATE_UPLOADING;
                // 开始上传
                [self uploadTask:queueModel];
            }else{
                NSLog(@"%@获取签名失败",uploadmodel.fileName);
                queueModel.state = UPLOADING_STATE_FAIL;
            }
        }else{
            NSLog(@"%@获取签名失败",uploadmodel.fileName);
            queueModel.state = UPLOADING_STATE_FAIL;
        }
    }];

}

// 上传
- (void)uploadTask:(UploadQueueModel *)queueModel{
    NSLog(@"上传");
    UploadModel *uploadmodel = queueModel.uploadmodel;
    queueModel.state = UPLOADING_STATE_UPLOADING;
    __weak typeof(self) weak = self;
    [[UploadRequestManager sharedInstance] upload:uploadmodel progress:^(float progress) {
        if (queueModel.progress) {
            queueModel.progress(progress);
        }
    } complete:^(id data, BOOL success) {
        __strong typeof(weak) self = weak;
        if (self.uploadCompleteBlock) {
            self.uploadCompleteBlock(success);
        }
        if (success) {
            NSString *code = [data objectForKey:@"code"];
            if (code.intValue == 1) {
                NSLog(@"%@上传成功",uploadmodel.fileName);
                queueModel.state = UPLOADING_STATE_SUCCESS;
                [self.uploadList removeObject:queueModel];
            }else{
                NSLog(@"%@上传失败",uploadmodel.fileName);
                queueModel.state = UPLOADING_STATE_FAIL;
            }
        }else{
            NSLog(@"%@上传失败",uploadmodel.fileName);
            queueModel.state = UPLOADING_STATE_FAIL;
        }
        // 继续上传
        [self startUpload];
    }];

}

// 取消上传
- (void)cancelUpload:(UploadQueueModel *)item{
    
}

// 重新上传
- (void)restartUpload:(UploadQueueModel*)item{
    
}


@end
