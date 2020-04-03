//
//  UtilityObjC.h
//  PhototainmentVR
//
//  Created by Admin on 29/06/17.
//  Copyright © 2018 Pushan Mitra (ios.dev.mitra@gmail.com). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UtilityObjC : NSObject

@end

@interface CCFileHandle : NSObject


@property (nonatomic, strong) NSString * lineSeperator;

- (BOOL) open:(NSString *) path;
- (void) close;

- (void) print:(NSString *) input;
- (BOOL) canLog;

@end
