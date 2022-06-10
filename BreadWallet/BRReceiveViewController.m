//
//  BRReceiveViewController.m
//  BreadWallet
//
//  Created by Aaron Voisine on 5/8/13.
//  Copyright (c) 2013 Aaron Voisine <voisine@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "BRReceiveViewController.h"
#import "BRRootViewController.h"
#import "BRPaymentRequest.h"
#import "BRWalletManager.h"
#import "BRWallet.h"
#import "BRBubbleView.h"

#define QR_TIP      NSLocalizedString(@"Let others scan this QR code to get your woodcoin address. Anyone can send "\
                    "woodcoins to your wallet by transferring them to your address.", nil)
#define ADDRESS_TIP NSLocalizedString(@"This is your woodcoin address. Tap to copy it or send it by email or sms. The "\
                    "address will change each time you receive funds, but old addresses always work.", nil)

@interface BRReceiveViewController ()

@property (nonatomic, strong) BRBubbleView *tipView;
@property (nonatomic, assign) BOOL showTips, updated;

@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, strong) IBOutlet UIButton *addressButton;
@property (nonatomic, strong) IBOutlet UIImageView *qrView;

@end

@implementation BRReceiveViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.addressButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self updateAddress];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateAddress];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (! self.updated) [self performSelector:@selector(updateAddress) withObject:nil afterDelay:0.1];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self hideTips];
    
    [super viewWillDisappear:animated];
}

- (void)updateAddress
{
    if (! [self.paymentRequest isValid]) return;

    NSString *s = [[NSString alloc] initWithData:self.paymentRequest.data encoding:NSUTF8StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];

    [filter setValue:[s dataUsingEncoding:NSISOLatin1StringEncoding] forKey:@"inputMessage"];
    [filter setValue:@"L" forKey:@"inputCorrectionLevel"];
    UIGraphicsBeginImageContext(self.qrView.bounds.size);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGImageRef img = [[CIContext contextWithOptions:nil] createCGImage:filter.outputImage
                      fromRect:filter.outputImage.extent];

    if (context) {
        CGContextSetInterpolationQuality(context, kCGInterpolationNone);
        CGContextDrawImage(context, CGContextGetClipBoundingBox(context), img);
        self.qrView.image = [UIImage imageWithCGImage:UIGraphicsGetImageFromCurrentImageContext().CGImage scale:1.0
                             orientation:UIImageOrientationDownMirrored];
        [self.addressButton setTitle:self.paymentAddress forState:UIControlStateNormal];
        self.updated = YES;
    }

    UIGraphicsEndImageContext();
    CGImageRelease(img);
}

- (BRPaymentRequest *)paymentRequest
{
    return [BRPaymentRequest requestWithString:self.paymentAddress];
}

- (NSString *)paymentAddress
{
    return [[[BRWalletManager sharedInstance] wallet] receiveAddress];
}

- (BOOL)nextTip
{
    if (self.tipView.alpha < 0.5) return [(id)self.parentViewController.parentViewController nextTip];

    BRBubbleView *v = self.tipView;

    self.tipView = nil;
    [v popOut];

    if ([v.text hasPrefix:QR_TIP]) {
        self.tipView = [BRBubbleView viewWithText:ADDRESS_TIP tipPoint:[self.addressButton.superview
                        convertPoint:CGPointMake(self.addressButton.center.x, self.addressButton.center.y - 10.0)
                        toView:self.view] tipDirection:BRBubbleTipDirectionDown];
        if (self.showTips) self.tipView.text = [self.tipView.text stringByAppendingString:@" (4/6)"];
        self.tipView.backgroundColor = v.backgroundColor;
        self.tipView.font = v.font;
        self.tipView.userInteractionEnabled = NO;
        [self.view addSubview:[self.tipView popIn]];
    }
    else if (self.showTips && [v.text hasPrefix:ADDRESS_TIP]) {
        self.showTips = NO;
        [(id)self.parentViewController.parentViewController tip:self];
    }

    return YES;
}

- (void)hideTips
{
    if (self.tipView.alpha > 0.5) [self.tipView popOut];
}

#pragma mark - IBAction

- (IBAction)tip:(id)sender
{
    if ([self nextTip]) return;

    if (! [sender isKindOfClass:[UIGestureRecognizer class]] ||
        ([sender view] != self.qrView && ! [[sender view] isKindOfClass:[UILabel class]])) {
        if (! [sender isKindOfClass:[UIViewController class]]) return;
        self.showTips = YES;
    }

    self.tipView = [BRBubbleView viewWithText:QR_TIP
                    tipPoint:[self.qrView.superview convertPoint:self.qrView.center toView:self.view]
                    tipDirection:BRBubbleTipDirectionUp];
    if (self.showTips) self.tipView.text = [self.tipView.text stringByAppendingString:@" (3/6)"];
    self.tipView.backgroundColor = [UIColor orangeColor];
    self.tipView.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
    [self.view addSubview:[self.tipView popIn]];
}

- (IBAction)address:(id)sender
{
    if ([self nextTip]) return;

   /* UIActionSheet *a = [UIActionSheet new];

    a.title = [NSString stringWithFormat:NSLocalizedString(@"Receive woodcoins at this address: %@", nil),
               self.paymentAddress];
    a.delegate = self;
    [a addButtonWithTitle:NSLocalizedString(@"copy to clipboard", nil)];*/
    NSString *str = [@"Receive woodcoins at this:" stringByAppendingString:self.paymentAddress];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:str preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction * copyClipboard= [UIAlertAction actionWithTitle:@"copy to clipboard" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        [[UIPasteboard generalPasteboard] setString:self.paymentAddress];
        
        [self.view
         addSubview:[[[BRBubbleView viewWithText:NSLocalizedString(@"copied", nil)
                                          center:CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0 - 130.0)]
                      popIn] popOutAfterDelay:2.0]];
    }];
    
    [alertController addAction:copyClipboard];
    
    if ([MFMailComposeViewController canSendMail]) {
        UIAlertAction * sendEmail = [UIAlertAction actionWithTitle:@"send as email" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *c = [MFMailComposeViewController new];
                
                [c setSubject:NSLocalizedString(@"Woodcoin address", nil)];
                [c setMessageBody:[@"woodcoin:" stringByAppendingString:self.paymentAddress] isHTML:NO];
                c.mailComposeDelegate = self;
                [self.navigationController presentViewController:c animated:YES completion:nil];
                c.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wallpaper-default"]];
            }
            else {
                /*[[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"email not configured", nil) delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil] show];*/
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:@"email not configured" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancelAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
       [alertController addAction:sendEmail];
    }
        //[a addButtonWithTitle:NSLocalizedString(@"send as email", nil)];
#if ! TARGET_IPHONE_SIMULATOR
    if ([MFMessageComposeViewController canSendText]) {
        UIAlertAction * sendMessage = [UIAlertAction actionWithTitle:@"send as message" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            if ([MFMessageComposeViewController canSendText]) {
                MFMessageComposeViewController *c = [MFMessageComposeViewController new];
                
                c.body = [@"woodcoin:" stringByAppendingString:self.paymentAddress];
                c.messageComposeDelegate = self;
                [self.navigationController presentViewController:c animated:YES completion:nil];
                c.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wallpaper-default"]];
            }
            else {
                /*[[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"sms not currently available", nil)
                                           delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil] show];*/
                
            }
        }];
        
        [alertController addAction:sendMessage];
    }
        
        //[a addButtonWithTitle:NSLocalizedString(@"send as message", nil)];
#endif
    //[a addButtonWithTitle:NSLocalizedString(@"cancel", nil)];
   // a.cancelButtonIndex = a.numberOfButtons - 1;
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action){
    }];
       // [a showInView:[[UIApplication sharedApplication] keyWindow]];
    
    [alertController addAction:cancelAction];
    UIViewController *viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:alertController.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:viewController.view.frame.size.height*2.0f];
    [alertController.view addConstraint:constraint];
    [viewController presentViewController:alertController animated:YES completion:^{}];
}

#pragma mark - UIActionSheetDelegate

/*- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];

    //TODO: allow user to specify a request amount
    if ([title isEqual:NSLocalizedString(@"copy to clipboard", nil)]) {
        [[UIPasteboard generalPasteboard] setString:self.paymentAddress];

        [self.view
         addSubview:[[[BRBubbleView viewWithText:NSLocalizedString(@"copied", nil)
                       center:CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0 - 130.0)]
                      popIn] popOutAfterDelay:2.0]];
    }
    else if ([title isEqual:NSLocalizedString(@"send as email", nil)]) {
        //TODO: implement BIP71 payment protocol mime attachement
        // https://github.com/bitcoin/bips/blob/master/bip-0071.mediawiki
        
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *c = [MFMailComposeViewController new];
            
            [c setSubject:NSLocalizedString(@"Woodcoin address", nil)];
            [c setMessageBody:[@"bitcoin:" stringByAppendingString:self.paymentAddress] isHTML:NO];
            c.mailComposeDelegate = self;
            [self.navigationController presentViewController:c animated:YES completion:nil];
            c.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wallpaper-default"]];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"email not configured", nil) delegate:nil
              cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil] show];
        }
    }
    else if ([title isEqual:NSLocalizedString(@"send as message", nil)]) {
        if ([MFMessageComposeViewController canSendText]) {
            MFMessageComposeViewController *c = [MFMessageComposeViewController new];
            
            c.body = [@"bitcoin:" stringByAppendingString:self.paymentAddress];
            c.messageComposeDelegate = self;
            [self.navigationController presentViewController:c animated:YES completion:nil];
            c.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wallpaper-default"]];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"sms not currently available", nil)
              delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil] show];
        }
    }    
}*/

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
didFinishWithResult:(MessageComposeResult)result
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result
error:(NSError *)error
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
