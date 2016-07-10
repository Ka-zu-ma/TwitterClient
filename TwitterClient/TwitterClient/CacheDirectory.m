//
//  CacheDirectory.m
//  TwitterClient
//
//  Created by 宮崎数磨 on 2016/07/10.
//  Copyright © 2016年 Miyazaki Kazuma. All rights reserved.
//

#import "CacheDirectory.h"

@implementation CacheDirectory

//Cacheディレクトリのパス取得
+(NSString *)getCachesDirectoryPath{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *cachesDirectoryPath= paths[0];
    
    return cachesDirectoryPath;
}

//Cacheディレクトリの下に新規で作るディレクトリのパスを作成
+(NSString *)createNewDirectoryPath:(NSString *)directoryName{
    
    //新規ディレクトリパスを作成
    NSString *newDirectoryPath=[[self getCachesDirectoryPath] stringByAppendingPathComponent:directoryName];
    
    return newDirectoryPath;
}

//Cacheディレクトリの下に新規でディレクトリを作る
+(void)createNewDirectory:(NSString *)directoryName{
    
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    
    NSError *error = nil;
    BOOL created = [fileManager createDirectoryAtPath:[[self getCachesDirectoryPath] stringByAppendingPathComponent:directoryName]
                          withIntermediateDirectories:YES
                                           attributes:nil
                                                error:&error];
    // 作成に失敗した場合は、原因をログに出力
    if (!created) {
        NSLog(@"failed to create directory. reason is %@ - %@", error, error.userInfo);
    }
}

//サーバー上のデータを直接取得して、NSData形式で保持する
+(void)saveData:(NSData *)data directoryName:(NSString *)directoryName fileName:(NSString *)fileName{
    
    
//    NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
    
    //NSLog(@"データ:%@",[data description]);
    
    // 保存する先のパス
    NSString *savedPath = [[[self getCachesDirectoryPath]stringByAppendingPathComponent:directoryName] stringByAppendingPathComponent:fileName];
    
NSLog(@"パス:%@",savedPath);
    
    //保存処理を行う。ファイルにデータを書き出す
    [data writeToFile:savedPath atomically:YES];
    
    //以下のやり方だと、ファイルにデータが書き出されないためオフラインのときに画像表示されない
    //失敗した場合には、NSErrorのインスタンスを得られるので、その情報を表示する。
    /*NSFileManager *saveFileManager = [NSFileManager defaultManager];
     NSError *saveError = nil;
     BOOL success = [saveFileManager createFileAtPath:savedPath contents:data attributes:nil];
     
     if (!success) {
     NSLog(@"failed to save image. reason is %@ - %@", saveError, saveError.userInfo);
     
     }*/

}

//キャッシュを取得
+(NSData *)getData:(NSString *)directoryName fileNameString:(NSString *)fileNameString{
    
    NSString *newDirectoryPath=[[self getCachesDirectoryPath] stringByAppendingPathComponent:directoryName];
    
    NSString *DataPath = [newDirectoryPath stringByAppendingPathComponent:fileNameString];
    
    NSFileHandle *fileHandle=[NSFileHandle fileHandleForReadingAtPath:DataPath];
    
    if (!fileHandle) {
        NSLog(@"ファイルがありません．");
        return nil;
    }
    
    //ファイルの末尾までデータを読み込む
    NSData *data=[fileHandle readDataToEndOfFile];
    
    return data;
}

@end
