//
//  UploadModel.h
//  detu_uploadqueue
//
//  Created by lsq on 2017/7/20.
//  Copyright © 2017年 detu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    UploadFileType_Picture,
    UploadFileType_Movie,
} UploadFileType;

@interface UploadModel : NSObject

// 上传的文件路径
@property (nonatomic, strong) NSURL *fileUrl;
// 文件名
@property (nonatomic, copy) NSString *fileName;
// 文件类型
@property (nonatomic, assign) UploadFileType fileType;
// 用户资料
@property (nonatomic, copy) NSString *usercode;

// 上传服务器地址
@property (nonatomic, copy) NSString *serverUrl;
// 签名
@property (nonatomic, copy) NSString *sign;
// token
@property (nonatomic, copy) NSString *token;

@end
