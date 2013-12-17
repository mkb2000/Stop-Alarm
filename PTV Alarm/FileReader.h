//
//  FileReader.h
//  PTV Alarm
//
//  Created by Kangbo Mo on 7/12/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileReader : NSObject

-(NSString *) nextLine;
-(FileReader *) initWithFile:(NSString *) filePath;

@end
