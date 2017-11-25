//
//  ZBMouseTapModel.m
//  AutoClick
//
//  Created by xzb on 2017/11/24.
//  Copyright © 2017年 lucas. All rights reserved.
//

#import "ZBMouseTapModel.h"

@implementation ZBMouseTapModel


- (NSString *)description {
    return [NSString stringWithFormat:@"index : %ld point: < %@ >, 距离上次点击 : %ld",self.index,NSStringFromPoint(self.point),self.time];
}
@end
