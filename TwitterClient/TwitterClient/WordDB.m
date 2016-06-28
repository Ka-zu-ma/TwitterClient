//
//  WordDB.m
//  TwitterClient
//
//  Created by 宮崎数磨 on 2016/06/28.
//  Copyright © 2016年 Miyazaki Kazuma. All rights reserved.
//

#import "WordDB.h"
#import "FMDatabase.h"
@implementation WordDB

//DB接続
+(FMDatabase *)getdb{
    
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *dbPathString=paths[0];
    
    FMDatabase *db=[FMDatabase databaseWithPath:[dbPathString stringByAppendingPathComponent:@"word.db"]];
    
    NSLog(@"DBの場所:%@",[dbPathString stringByAppendingPathComponent:@"word.db"]);
    
    return db;
}

//テーブル作成
+(void)createTable{
    
    FMDatabase *db = [WordDB getdb];
    
    [db open];
    
    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS wordtable (id INTEGER PRIMARY KEY, word TEXT)"];
    
    [db close];
}

//データ挿入
+(void)insertTable:(NSString *)wordString{
    
    FMDatabase *db = [WordDB getdb];
    
    [db open];
    
    [db executeUpdate:@"INSERT INTO wordtable (word) VALUES (?);",wordString];
    
    [db close];
    
}

//データ取得
+(NSMutableArray *)selectTable{
    
    NSMutableArray *words = [[NSMutableArray alloc] init];
    
    FMDatabase *db = [WordDB getdb];
    
    [db open];
    
    FMResultSet *results=[db executeQuery:@"SELECT word FROM wordtable;"];
    while ([results next]) {
        
        [words addObject:[results stringForColumn:@"word"]];
    }
    
    [db close];
    
    return words;    
}

//データ削除
+(void)deleteData:(NSString *)wordString{
    
    FMDatabase *db = [WordDB getdb];
    
    [db open];
    
    [db executeUpdate:@"DELETE FROM wordtable WHERE word = ?",wordString];
    
    [db close];
}



@end
