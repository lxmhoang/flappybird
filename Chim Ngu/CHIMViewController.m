//
//  CHIMViewController.m
//  Chim Ngu
//
//  Created by Tran Hoang Duong on 13/2/14.
//  Copyright (c) 2014 Tran Hoang Duong. All rights reserved.
//

#import "CHIMViewController.h"
#import "CHIMMyScene.h"

@implementation CHIMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
        _bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    } else {
        _bannerView = [[ADBannerView alloc] init];
    }
    _bannerView.delegate = self;
    
    

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [CHIMMyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    
    [self.view addSubview:_bannerView];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


- (void)layoutAnimated:(BOOL)animated
{
    // As of iOS 6.0, the banner will automatically resize itself based on its width.
    // To support iOS 5.0 however, we continue to set the currentContentSizeIdentifier appropriately.
    CGRect contentFrame = self.view.bounds;
    if (contentFrame.size.width < contentFrame.size.height) {
        _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    } else {
        _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    }
    
    
    CGRect bannerFrame = _bannerView.frame;
    if (_bannerView.bannerLoaded) {
        NSLog(@"ads loaded !");
        contentFrame.size.height -= _bannerView.frame.size.height;
        bannerFrame.origin.y = contentFrame.size.height;
    } else {
        NSLog(@"ads NOT loaded !");
        bannerFrame.origin.y = contentFrame.size.height;
    }
    
    //    if (_bannerView.bannerLoaded){
    [UIView animateWithDuration:animated ? 0 : 0.0 animations:^{
//        self.view.frame = contentFrame;
        [self.view layoutIfNeeded];
        _bannerView.frame = bannerFrame;
    }];
    //    }else{
    //        NSLog(@"Banner not loaded");
    //    }
}


#pragma mark Bannerview delegate

- (void)viewDidLayoutSubviews
{
        [self layoutAnimated:[UIView areAnimationsEnabled]];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self layoutAnimated:YES];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"error log : %@",error);
    [self layoutAnimated:YES];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    
}


@end
