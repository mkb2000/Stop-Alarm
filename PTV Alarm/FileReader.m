//
//  FileReader.m
//  PTV Alarm
//
//  Created by Kangbo Mo on 7/12/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//
//  Read a file line by line.

#import "FileReader.h"
#define BLOCK_SIZE 1024

@interface FileReader()

@property (nonatomic,strong) NSString* filepath;
@property (nonatomic,strong) NSFileHandle * filehandle;
@property (nonatomic,strong) NSMutableData * buf;
@property (nonatomic,strong) NSNumber *buflength;
@property (nonatomic,strong) NSMutableArray * bufline;
@property unsigned long long filelength;
@end

@implementation FileReader

- (NSMutableData *)buf{
    if (!_buf) {
        _buf=[NSMutableData data];
    }
    return _buf;
}

- (FileReader *)initWithFile:(NSString *)filePath{
    self=[super init];
    self.filepath=filePath;
    self.filehandle=[NSFileHandle fileHandleForReadingAtPath:filePath];
    self.filelength=[self.filehandle seekToEndOfFile];
    [self.filehandle seekToFileOffset:0];
    self.buflength=[NSNumber numberWithInt:0];
    //    self.buf=[NSMutableData data];
    self.bufline=[NSMutableArray array];
    return self;
}

//return nil if reaching the end of file. Use while(l=nextLine()) to check and get next line.
- (NSString *) nextLine{
    //    int cc=[self.filehandle offsetInFile];
    
    NSString * nextline;
    NSString * temp;
    int isEnd;
    
    //return if bufline has unread lines.
    if ([self.bufline count]>0) {
        nextline=[self.bufline objectAtIndex:0];
        [self.bufline removeObjectAtIndex:0];
        return  nextline;
    }
    
    //if reach the end of file
    if ([self.filehandle offsetInFile]>=self.filelength) {
        return nil;
    }
    
    //continue to read blocks until finding '\n' in it, or reach the end of file.
    do {
        isEnd=[self readNextBlock:self.buf withLength:BLOCK_SIZE bufLength:self.buflength];
        temp=[[NSString alloc] initWithData:self.buf encoding:NSMacOSRomanStringEncoding];
    } while (!temp||([temp rangeOfString:@"\n"].location==NSNotFound&&!isEnd));
    
    //if reach the end of file, try to add '\n' to it to enable split.
    if (isEnd&&[temp characterAtIndex:temp.length-1]!='\n' ) {
        temp=[temp stringByAppendingString:@"\n"];
    }
    
    //store complete lines.
    NSArray *lines=[temp componentsSeparatedByString:@"\n"];
    for (int i=0; i<[lines count]-1; i++) {
        [self.bufline addObject:lines[i]];
    }

    //put uncomplete line back to buf.
    self.buf=[NSMutableData dataWithData:[[lines lastObject] dataUsingEncoding:NSMacOSRomanStringEncoding]];
    self.buflength=[NSNumber numberWithInt:[self.buf length]];
    
    nextline=[self.bufline objectAtIndex:0];
    [self.bufline removeObjectAtIndex:0];
    
    return  nextline;
}



-(int) readNextBlock:(NSData *) buf withLength:(NSInteger)readlength bufLength:(NSNumber *) buflength{
    
    NSData *data=[self.filehandle readDataOfLength:readlength];
    [self.buf appendData:data];
    self.buflength=[NSNumber numberWithInt:self.buflength.intValue+[data length]];
    
    //a single line exceed NSData length.
    if (self.buflength.intValue>[self.buf length]) {
        [NSException raise:@"Exceed NSData capability." format:@"a single line exceed NSData capability in %@",[self class]];
    }
    
    if (readlength>[data length]) {
        //end of file
        return 1;
    }
    else{
        return 0;
    }
    
}

@end
