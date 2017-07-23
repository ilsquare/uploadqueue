//
//  UploadRequest.m
//  detu_uploadqueue
//
//  Created by lsq on 2017/7/20.
//  Copyright © 2017年 detu. All rights reserved.
//

#import "UploadRequest.h"
#import "AFNetworking.h"

@implementation UploadRequest

+ (instancetype)sharedInstance{
    static id obj = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        obj = [[self alloc]init];
    });
    return  obj;
}

// 开始请求
- (void)startRequest:(NSString *)url parameters:(id)parameters complete:(requestComleteBlock)complete{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //适配https
    manager.securityPolicy = [self appTranportSecurity:NO];
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            if (complete) {
                complete(responseObject,YES);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (complete) {
            complete(nil,NO);
        }
    }];
    
}

// 文件上传
- (void)uploadRequest:(UploadModel *)uploadModel parameters:(id)parameters progress:(requestProgressBlock)progressBlock complete:(requestComleteBlock)complete{
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:uploadModel.serverUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSURL *fileUrl = uploadModel.fileUrl;
        NSString *name = @"file";
        NSString *fileName = uploadModel.fileName;
        NSString *type = @"";
        if (uploadModel.fileType == UploadFileType_Picture) {
            type = @"image/jpeg";
            UIImage* image =  [UIImage imageWithContentsOfFile:[fileUrl.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@""]];
            NSData *data = UIImageJPEGRepresentation(image, 1);
            [formData appendPartWithFileData:data name:name fileName:fileName mimeType:type];
        }else if (uploadModel.fileType == UploadFileType_Movie) {
            type = @"video/quicktime";
            [formData appendPartWithFileURL:fileUrl name:name fileName:fileName mimeType:type error:nil];
        }

    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      // This is not called back on the main queue.
                      // You are responsible for dispatching to the main queue for UI updates
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                          if (progressBlock) {
                              NSLog(@"progress:%f",uploadProgress.fractionCompleted);
                              progressBlock(uploadProgress.fractionCompleted);
                          }
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          if (complete) {
                              complete(error,NO);
                          }
                          NSLog(@"Error: %@", error);
                      } else {
                          if (complete) {
                              complete(responseObject,YES);
                          }
                          NSLog(@"%@ %@", response, responseObject);
                          NSLog(@"msg %@",[responseObject objectForKey:@"msg"]);
                      }
                  }];
    
    [uploadTask resume];
}

//获取https需要的AFSecurityPolicy  isUpdate上传用七牛的证书
- (AFSecurityPolicy *)appTranportSecurity:(BOOL)isUpdate {
    NSString *cerPath;
    if (isUpdate) {
        NSLog(@"qiuincer");
        cerPath = [[NSBundle mainBundle] pathForResource:@"qiniu" ofType:@"cer"];
    }else{
        //外网
        cerPath = [[NSBundle mainBundle] pathForResource:@"Release" ofType:@"cer"];
    }
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    //https配置
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = YES;
    //添加证书
    [securityPolicy setPinnedCertificates:@[certData]];
    return securityPolicy;
    
}


@end
