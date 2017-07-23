//
//  UploadQueueManager.h
//  detu_uploadqueue
//
//  Created by lsq on 2017/7/20.
//  Copyright © 2017年 detu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadQueueModel.h"

typedef void (^uploadCompleteBlock)(BOOL);

@interface UploadQueueManager : NSObject

+ (instancetype)sharedInstance;

// 最大并行数,默认一个
@property (nonatomic, assign) int maxParallel;

// 上传完成结果回调
@property (nonatomic, copy) uploadCompleteBlock uploadCompleteBlock;

/*
 添加到上传队列中
 */
- (void)addTask:(UploadQueueModel *)queueModel;

// 开始上传
- (void)startUpload;
    
// 取消上传
- (void)cancelUpload:(UploadQueueModel *)item;

// 重新上传
- (void)restartUpload:(UploadQueueModel*)item;

@end
