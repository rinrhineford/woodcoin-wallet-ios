//
//  BRWelcomeViewController.m
//  BreadWallet
//
//  Created by Aaron Voisine on 7/8/13.
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

#import "BRWelcomeViewController.h"
#import "BRWalletManager.h"
#import "BRRestoreViewController.h"

@interface BRWelcomeViewController ()

@property (nonatomic, assign) BOOL hasAppeared, animating;
@property (nonatomic, strong) id activeObserver, resignActiveObserver;
@property (nonatomic, strong) UINavigationController *seedNav;
@property (nonatomic, strong) IBOutlet UIButton *generateButton;
@property (weak, nonatomic) IBOutlet UIButton *createWalletButton;
@property (weak, nonatomic) IBOutlet UIButton *importPrivateKeysButton;

@end

@implementation BRWelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.activeObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil
        queue:nil usingBlock:^(NSNotification *note) {
            if ([[BRWalletManager sharedInstance] wallet]) { // sanity check
                [self.navigationController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
            }
        }];
    
    self.resignActiveObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil
        queue:nil usingBlock:^(NSNotification *note) {
        }];
}

- (void)dealloc
{
    if (self.activeObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.activeObserver];
    if (self.resignActiveObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.resignActiveObserver];
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

    /*[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];*/
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    dispatch_async(dispatch_get_main_queue(), ^{ // animation sometimes doesn't work if run directly in viewDidAppear
        if ([[BRWalletManager sharedInstance] wallet]) { // sanity check
            [self.navigationController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
        }
        
        if (! self.hasAppeared) {
            self.hasAppeared = YES;
            [UIView animateWithDuration:0.35 delay:1.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.0
             options:UIViewAnimationOptionCurveEaseOut animations:^{
                /*[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];*/
                [self.view.superview layoutIfNeeded];
            } completion:nil];
        }
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    self.generateButton = (id)[[segue.destinationViewController view] viewWithTag:1];
    [self.generateButton addTarget:self action:@selector(generate:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark IBAction

- (void)generate:(id)sender
{
    [self.navigationController setNavigationBarHidden:YES];
    [sender setEnabled:NO];

    UIViewController *seedNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"SeedViewController"];
    [self.navigationController pushViewController:seedNavigationController animated:YES];
}

@end
