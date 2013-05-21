//
//  CProperties.h
//  OutlineTest
//
//  Created by Jodynek on 21.05.13.
//  Copyright (c) 2013 Petr Jodas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CProperties : NSObject
{
  NSString *_sKey;
  NSString *_sValue;
  NSArray *_values;
  BOOL _isRoot;
}
@property (nonatomic, copy) NSArray* values;
@property (nonatomic, copy) NSString *sKey;
@property (nonatomic, copy) NSString *sValue;
@property (readwrite) BOOL isRoot;
@end
