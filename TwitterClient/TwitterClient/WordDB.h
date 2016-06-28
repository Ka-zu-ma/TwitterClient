//
//  WordDB.h
//  TwitterClient
//
//  Created by 宮崎数磨 on 2016/06/28.
//  Copyright © 2016年 Miyazaki Kazuma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface WordDB : NSObject

+(FMDatabase *)getdb;
+(void)createTable;
+(void)insertTable:(NSString *)wordString;
+(NSMutableArray *)selectTable;
+(void)deleteData:(NSString *)wordString;

@end
