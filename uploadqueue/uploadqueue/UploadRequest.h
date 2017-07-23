//
//  UploadRequest.h
//  detu_uploadqueue
//
//  Created by lsq on 2017/7/20.
//  Copyright © 2017年 detu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadModel.h"

typedef void (^requestComleteBlock)(id, BOOL);
typedef void (^requestProgressBlock)(float);

@interface UploadRequest : NSObject

+ (instancetype)sharedInstance;

// 开始请求
- (void)startRequest:(NSString *)url parameters:(id)parameters complete:(requestComleteBlock)complete;

// 文件上传
- (void)uploadRequest:(UploadModel *)uploadModel parameters:(id)parameters progress:(requestProgressBlock)progressBlock complete:(requestComleteBlock)complete;

@end
