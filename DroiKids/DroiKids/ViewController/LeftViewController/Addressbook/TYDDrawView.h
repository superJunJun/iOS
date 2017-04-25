//
//  TYDDrawView.h
//  DroiKids
//
//  Created by superjunjun on 15/8/22.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@protocol TYDDrawViewDelegate <NSObject>
@optional
- (void)drawEnd;

@end
@interface TYDDrawView : UIView <TYDDrawViewDelegate>

{
    CGPoint _firstPoint;
    CGPoint _lastPoint;
}
@property (strong, nonatomic) NSMutableArray            *arrayStrokes;
@property (assign, nonatomic) id<TYDDrawViewDelegate>   draweDlegate;


- (void)clearCanvas;

@end
