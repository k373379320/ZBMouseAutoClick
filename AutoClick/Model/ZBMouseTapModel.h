//
//  ZBMouseTapModel.h
//  AutoClick
//
//  Created by xzb on 2017/11/24.
//  Copyright © 2017年 lucas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZBMouseTapModel : NSObject

@property (nonatomic, assign) NSPoint point;
@property (nonatomic, copy) NSString *pointStr;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger time;
@property (nonatomic, assign) NSInteger interval;
@end
