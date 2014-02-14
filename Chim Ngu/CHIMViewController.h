//
//  CHIMViewController.h
//  Chim Ngu
//

//  Copyright (c) 2014 Tran Hoang Duong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>

@interface CHIMViewController : UIViewController <ADBannerViewDelegate>
{
    
    ADBannerView *_bannerView;
}

@end
