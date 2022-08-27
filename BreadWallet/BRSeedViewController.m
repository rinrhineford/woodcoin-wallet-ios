//
//  BRSeedViewController.m
//  BreadWallet
//
//  Created by Aaron Voisine on 6/12/13.
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

#import "BRSeedViewController.h"
#import "BRWalletManager.h"
#import "BRWallet.h"
#import "BRPeerManager.h"
#import "BRBIP32Sequence.h"

#define LABEL_MARGIN       20.0
#define WRITE_TOGGLE_DELAY 15.0

@interface BRSeedViewController ()

@property (nonatomic, strong) id resignActiveObserver, screenshotObserver;
@property (weak, nonatomic) IBOutlet UIView *textViewContainer;
@property (weak, nonatomic) CALayer *textViewContainerBorderLayer;
@property (weak, nonatomic) IBOutlet UITextView *seedTextView;

@end

@implementation BRSeedViewController

- (instancetype)customInit
{
    if ([[UIApplication sharedApplication] isProtectedDataAvailable] && ! [[BRWalletManager sharedInstance] wallet]) {
        [[BRWalletManager sharedInstance] generateRandomSeed];
        [[BRPeerManager sharedInstance] connect];
    }

    return self;
}

- (instancetype)init
{
    if (! (self = [super init])) return nil;
    return [self customInit];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (! (self = [super initWithCoder:aDecoder])) return nil;
    return [self customInit];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (! (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) return nil;
    return [self customInit];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.resignActiveObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:
         ^(NSNotification *note) {
            if (self.navigationController.viewControllers.firstObject != self) {
                [self.navigationController popViewControllerAnimated:NO];
            }
        }];


    //TODO: make it easy to create a new wallet and transfer balance
    self.screenshotObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationUserDidTakeScreenshotNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:
         ^(NSNotification *note) {
            if ([[[BRWalletManager sharedInstance] wallet] balance] == 0) {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Screenshots are visible to other apps and devices. "
                                            "Generate a new backup phrase and keep it secret." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction* showAction = [UIAlertAction actionWithTitle:@"show" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                     [self refreshSeedPhrase];
                }];
                [alert addAction:cancelAction];
                [alert addAction:showAction];
                [self presentViewController:alert animated:YES completion:nil];

            }
            else {
                UIAlertController* alertS = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                                message:@"Screenshots are visible to other apps and devices. "
                                             "Your funds are at risk. Transfer your balance to another wallet."
                                                                         preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"cancel"
                                                                       style:UIAlertActionStyleCancel
                                                                     handler:nil];
                [alertS addAction:cancelAction];
                [self presentViewController:alertS animated:YES completion:nil];
            }
        }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self configureTextViewContainerIfNeeded];
}

- (void)configureTextViewContainerIfNeeded {
    CAShapeLayer *shapeLayer = [CAShapeLayer new];
    CGSize frameSize = self.textViewContainer.frame.size;
    CGRect shapeRect = CGRectMake(0, 0, frameSize.width, frameSize.height);
    
    shapeLayer.bounds = shapeRect;
    shapeLayer.position = CGPointMake(frameSize.width / 2, frameSize.height / 2);
    shapeLayer.fillColor = UIColor.clearColor.CGColor;
    shapeLayer.strokeColor = [UIColor colorNamed:@"Pure White"].CGColor;
    shapeLayer.lineWidth = 2;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineDashPattern = @[@10, @10];
    shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:shapeRect cornerRadius:16].CGPath;
    
    CALayer *oldShapeLayer = self.textViewContainerBorderLayer;
    if (oldShapeLayer) {
        for (CALayer *layer in self.textViewContainer.layer.sublayers) {
            if ([layer isEqual:oldShapeLayer]) {
                [layer removeFromSuperlayer];
            }
        }
    }
    
    [self.textViewContainer.layer addSublayer:shapeLayer];
    self.textViewContainerBorderLayer = shapeLayer;
}


- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (self.resignActiveObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.resignActiveObserver];
    if (self.screenshotObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.screenshotObserver];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    @autoreleasepool {  // @autoreleasepool ensures sensitive data will be dealocated immediately
        self.seedTextView.text = [[BRWalletManager sharedInstance] seedPhrase];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // don't leave the seed phrase laying around in memory any longer than necessary
    self.seedTextView.text = @"";
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark - IBAction

- (void)refreshSeedPhrase
{
    if (! [[UIApplication sharedApplication] isProtectedDataAvailable]) return;
    [[BRWalletManager sharedInstance] generateRandomSeed];
    [[BRPeerManager sharedInstance] connect];
    
    @autoreleasepool {
        self.seedTextView.text = [[BRWalletManager sharedInstance] seedPhrase];
    }
}

- (IBAction)didTapNext:(UIButton *)sender {
    UIViewController *pinNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"PINNav"];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [self presentViewController:pinNavigationController animated:YES completion:^{}];
    }];
    
}

- (IBAction)copy:(UIButton *)sender
{
    [[UIPasteboard generalPasteboard] setString:[[BRWalletManager sharedInstance] seedPhrase]];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) return;

    if ([[[BRWalletManager sharedInstance] wallet] balance] == 0 &&
        [[alertView buttonTitleAtIndex:buttonIndex] isEqual:NSLocalizedString(@"new phrase", nil)]) {
        [self refreshSeedPhrase];
    }
}

@end
