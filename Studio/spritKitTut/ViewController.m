//
//  ViewController.m
//  spritKitTut
//
//  Created by Ricky Brown on 6/2/14.
//  Copyright (c) 2014 15and50. All rights reserved.
//

#import "ViewController.h"

#import "MyScene.h"
#import "Twitter/Twitter.h"
#import "AppDelegate.h"
#import <iAd/iAd.h>
#import <MessageUI/MessageUI.h>


@implementation ViewController

-(void) viewWillLayoutSubviews
{
    
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [MyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;

    SKView *spriteView = (SKView *) self.view;
    spriteView.showsNodeCount = NO;
    spriteView.showsFPS = NO;
    
    // Present the scene.
    [skView presentScene:scene];
    
    
}

-(BOOL) prefersStatusBarHidden
{
    return YES;
}

#pragma mark Share app

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   
    if (buttonIndex == 1)
    {
        [self postScore];
    }
    else if (buttonIndex == 2)
    {
        [self tweetScore];
    }
    else if (buttonIndex == 3)
    {
        [self sendTheText];
    }
    else if (buttonIndex == 4)
    {
        [self sendTheEmail];
    }
    
}

-(void) postScore
{
    
    NSString *shareString = [NSString stringWithFormat:@"I just got %i on [app name]! Beat that!", shareScore];
    
    SLComposeViewController *post = [[SLComposeViewController alloc] init];
    
    post = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [post addImage:[UIImage imageNamed:@"TheIcon"]];
    [post setInitialText:shareString];
    
    [self presentViewController:post animated:YES completion:nil];
    
}

-(void) tweetScore
{
    
    NSString *shareString = [NSString stringWithFormat:@"I just got %i on [app name]! Beat that!", shareScore];
    
    SLComposeViewController *tweet = [[SLComposeViewController alloc] init];
    
    tweet= [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [tweet addImage:[UIImage imageNamed:@"TheIcon"]];
    [tweet setInitialText:shareString];
    
    [self presentViewController:tweet animated:YES completion:nil];
    
}

-(void) sendTheText
{
    
    NSString *shareString = [NSString stringWithFormat:@"I just got %i on [app name]! Beat that!", shareScore];
    
    MFMessageComposeViewController *textMessage = [[MFMessageComposeViewController alloc] init];
    
    [textMessage setMessageComposeDelegate:self];
    
    if ([MFMessageComposeViewController canSendText])
    {
        
        [textMessage setBody:shareString];
        
        [self presentViewController:textMessage animated:YES completion:nil];
        
    }
    
}

-(void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void) sendTheEmail
{
    
    NSString *shareString = [NSString stringWithFormat:@"I just got %i on [app name]! Beat that!", shareScore];
    
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    
    [mailComposer setMailComposeDelegate:self];
    
    if ([MFMailComposeViewController canSendMail])
    {
        
        [mailComposer setSubject:@"App Name"];
        
        [mailComposer setMessageBody:shareString isHTML:NO];
        
        [self presentViewController:mailComposer animated:YES completion:nil];
        
    }
    
}

-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end




