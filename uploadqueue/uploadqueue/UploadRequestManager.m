//
//  UploadRequestManager.m
//  detu_uploadqueue
//
//  Created by lsq on 2017/7/20.
//  Copyright © 2017年 detu. All rights reserved.
//

#import "UploadRequestManager.h"
#import "CocoaSecurity.h"
#import <sys/utsname.h>
#import <UIKit/UIDevice.h>

const NSString *detuBase = @"https://www.baidu.com";
const NSString *detuUploadSign = @"xxx";
const NSString *qiniuupload = @"xxx";

@implementation UploadRequestManager

+ (instancetype)sharedInstance{
    static id obj = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        obj = [[self alloc]init];
    });
    return  obj;
}

// 获取视频,图片签名
- (void)requestSign:(UploadModel *)uploadModel complete:(requestComleteBlock)complete{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (uploadModel.fileName) {
        [dic setObject:uploadModel.fileName forKey:@"filename"];
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",detuBase,detuUploadSign];
    
    [[UploadRequest sharedInstance] startRequest:url parameters:[self combinParameter:dic getSign:YES usercode:uploadModel.usercode] complete:^(id responseData, BOOL success) {
        if (complete) {
            if (success) {
                complete(responseData,YES);
            }else{
                complete(nil,NO);

            }
        }
    }];
    
}

// 文件上传
- (void)upload:(UploadModel *)uploadModel progress:(requestProgressBlock)progressBlock complete:(requestComleteBlock)complete{
    uploadModel.serverUrl = [NSString stringWithFormat:@"%@",qiniuupload];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:uploadModel.sign forKey:@"key"];
    [dic setObject:uploadModel.token forKey:@"token"];
    [dic setObject:@"8" forKey:@"x:devicename"];
    [dic setObject:uploadModel.fileName forKey:@"x:name"];
    [dic setObject:uploadModel.usercode forKey:@"x:usercode"];

    [[UploadRequest sharedInstance] uploadRequest:uploadModel parameters:[self combinParameter:dic getSign:YES usercode:uploadModel.usercode] progress:^(float progress) {
        if (progressBlock) {
            progressBlock(progress);
        }
    } complete:^(id responseData, BOOL success) {
        if (complete) {
            complete(nil,success);
        }
    }];
    
}

// 加入需要组装的参数
- (NSMutableDictionary *)combinParameter:(NSMutableDictionary *)otherParameter getSign:(BOOL)_sign usercode:(NSString *)usercode{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[self httpBaseParameter:usercode]];
    if (otherParameter) {
        for (NSString *otherKey in [otherParameter allKeys]) {
            [parameters setObject:[otherParameter objectForKey:otherKey] forKey:otherKey];
        }
    }
    
    // 是否加入密钥
    if (_sign) {
        NSArray *keys = [parameters allKeys];
        keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        NSMutableString *signString = [[NSMutableString alloc] init];
        for (NSString *key in keys) {
            [signString appendFormat:@"%@=%@&",key,parameters[key]];
        }
        [signString appendString:@"detupro"];
        NSString *sign = [[CocoaSecurity md5:signString] hexLower];
        if (sign) {
            [parameters setObject:sign forKey:@"sign"];
        }
    }
    return parameters;
    
}

//基础参数组装 每个请求必须加上的
/**
 *  NSString identifier 该参数为AppId（com.detu.main转转鸟，com.detu.qumeng趣梦）
 *  NSString appversion app版本号
 *  NSString mobiledevice 终端的手机型号
 *  NSString mobilesystem   终端的操作系统
 */
- (NSMutableDictionary *)httpBaseParameter:(NSString *)usercodes{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    // app id
    NSString *identifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey];
    if (identifier) {
        [parameters setObject:identifier forKey:@"identifier"];
    }
    
    // usercode
    NSString *usercode = usercodes;
    if (usercode) {
        [parameters setObject:usercode forKey:@"usercode"];
    }
    
    // 版本号
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (appVersion) {
        [parameters setObject:appVersion forKey:@"appversion"];
    }
    
    // 硬件类型
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platformType = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if (platformType) {
        [parameters setObject:platformType forKey:@"mobiledevice"];
    }
    
    // 系统类型
    NSString *system = [NSString stringWithFormat:@"%@%@",[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]];
    if (system) {
        system=[system stringByReplacingOccurrencesOfString:@" " withString:@""];
        [parameters setObject:system forKey:@"mobilesystem"];
    }
    return parameters;
    
}

@end
