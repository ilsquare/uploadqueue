//
//  UploadRequestManager.h
//  detu_uploadqueue
//
//  Created by lsq on 2017/7/20.
//  Copyright © 2017年 detu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadRequest.h"

@interface UploadRequestManager : NSObject

+ (instancetype)sharedInstance;

// 获取视频,图片签名
- (void)requestSign:(UploadModel *)uploadModel complete:(requestComleteBlock)complete;

// 文件上传
- (void)upload:(UploadModel *)uploadModel progress:(requestProgressBlock)progressBlock complete:(requestComleteBlock)complete;

@end
