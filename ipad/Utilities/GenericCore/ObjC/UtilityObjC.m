//
//  UtilityObjC.m
//  PhototainmentVR
//
//  Created by Pushan on 29/06/17.
//  Copyright © 2018 Pushan Mitra (ios.dev.mitra@gmail.com). All rights reserved.
//

#import "UtilityObjC.h"

@implementation UtilityObjC

@end




@interface CCFileHandle ()
@property (nonatomic, assign) FILE * file;
@end

@implementation CCFileHandle


- (BOOL) canLog {
    return self.file != NULL;
}

- (id) init
{
    if ((self = [super init])){
        self.file = NULL;
    }
    return self;
}

- (BOOL) open:(NSString *) path {
    self.file = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "a+");
    if (self.file) {
        return YES;
    }
    return NO;
}

- (void) close {
    if (self.file) {
        fclose(self.file);
        self.file = NULL;
    }
}

- (void) print:(NSString *)input {
    if (self.file) {
        int count = fprintf(self.file, "%s\n", [input cStringUsingEncoding:NSUTF8StringEncoding]);
        fflush(self.file);
        if (count == 0) {
            NSLog(@"No Data Written in File");
        }
    }
}

@end
