//
//  UploadQueueModel.m
//  detu_uploadqueue
//
//  Created by lsq on 2017/7/20.
//  Copyright © 2017年 detu. All rights reserved.
//

#import "UploadQueueModel.h"

@implementation UploadQueueModel
- (instancetype)init{
    if (self == [super init]) {
        self.state = UPLOADING_STATE_WAIT;
    }
    return self;
}

@end
