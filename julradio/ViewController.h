//
//  ViewController.h
//  julradio
//
//  Created by Axel Möller on 07/11/15.
//  Copyright © 2015 Appreviation AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YLGIFImage/YLImageView.h>

@interface ViewController : UIViewController

@property (nonatomic, weak) IBOutlet YLImageView *backgroundImage;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UILabel *trackTitleLabel;
@property (nonatomic, weak) IBOutlet UIView *volumeSlider;

@end

