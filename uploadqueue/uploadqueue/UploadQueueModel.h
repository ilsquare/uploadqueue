//
//  UploadQueueModel.h
//  detu_uploadqueue
//
//  Created by lsq on 2017/7/20.
//  Copyright © 2017年 detu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadModel.h"

//上传状态
typedef NS_ENUM(NSInteger,UPLOADING_STATE){
    UPLOADING_STATE_WAIT,
    UPLOADING_STATE_UPLOADING,
    UPLOADING_STATE_SUCCESS,
    UPLOADING_STATE_FAIL
};
typedef void (^uploadProgressBlock)(float);

@interface UploadQueueModel : NSObject

// 上传状态
@property (nonatomic, assign) UPLOADING_STATE state;

// 上传的进度
@property (nonatomic, copy) uploadProgressBlock progress;

// 上传模型
@property (nonatomic, strong) UploadModel *uploadmodel;

@end
