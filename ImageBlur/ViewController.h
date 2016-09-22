//
//  ViewController.h
//  ImageBlur
//
//  Created by Jose Maestre on 17/09/16.
//  Copyright © 2016 Jose Maestre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchTrackerView.h"

@interface ViewController : UIViewController

@property (nonatomic, strong) TouchTrackerView  *   trackerView;
@property (nonatomic, copy) void (^trackTouchesInitiated)();

//Image resources
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) UIImage *originalImage;
@property (strong, nonatomic) NSMutableArray *blurArray;

//Blur radio
@property float blurRadio;

//Helper Views
@property (weak, nonatomic) IBOutlet UIStepper *blurStepper;
@property (weak, nonatomic) IBOutlet UILabel *blurLabel;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;


@end

