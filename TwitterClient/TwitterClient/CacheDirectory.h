//
//  CacheDirectory.h
//  TwitterClient
//
//  Created by 宮崎数磨 on 2016/07/10.
//  Copyright © 2016年 Miyazaki Kazuma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheDirectory : NSObject

+(NSString *)getCachesDirectoryPath;
+(NSString *)createNewDirectoryPath:(NSString *)directoryName;
+(void)createNewDirectory:(NSString *)directoryName;


+(void)saveData:(NSData *)data directoryName:(NSString *)directoryName fileName:(NSString *)fileName;
+(NSData *)getData:(NSString *)directoryName fileNameString:(NSString *)fileNameString;

@end
