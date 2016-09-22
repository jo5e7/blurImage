//
//  TouchTrackerView.h
//  Dentsio Smile
//
//  Created by Jorge Palacio on 6/17/14.
//  Copyright (c) 2014 Jorge Palacio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TouchTrackerView : UIView

@property (nonatomic, copy) void (^trackTouchesInitiated)();
@property (nonatomic, copy) void (^trackTouchesFinished)(UIBezierPath *path);
@property (nonatomic, assign) BOOL autoRemoveTrackOnFinish;

- (void)clearTrackerPath;
//- (void)setController:(UIViewController *)viewController;

@end
