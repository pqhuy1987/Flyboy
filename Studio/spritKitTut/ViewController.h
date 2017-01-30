//
//  ViewController.h
//  spritKitTut
//

//  Copyright (c) 2014 15and50. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>
#import <MessageUI/MessageUI.h>

@interface ViewController : UIViewController <ADBannerViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate> {
    
    IBOutlet ADBannerView *iAd;
    
}

-(void) hideBanner;

@end
