//
//  BRShowSeedViewController.m
//  loughwallet
//
//  Created by Robert Gludo II on 5/20/22.
//  Copyright © 2022 Aaron Voisine. All rights reserved.
//

#import "BRShowSeedViewController.h"
#import "BRWalletManager.h"
#import "BRWallet.h"
#import "BRPeerManager.h"
#import "BRBIP32Sequence.h"

@interface BRShowSeedViewController ()

@end

@implementation BRShowSeedViewController

//- (instancetype)customInit
//{
//    if ([[UIApplication sharedApplication] isProtectedDataAvailable] && ! [[BRWalletManager sharedInstance] wallet]) {
//        [[BRWalletManager sharedInstance] generateRandomSeed];
//        [[BRPeerManager sharedInstance] connect];
//    }
//
//    return self;
//}
//
//- (instancetype)init
//{
//    if (! (self = [super init])) return nil;
//    return [self customInit];
//}
//
//- (instancetype)initWithCoder:(NSCoder *)aDecoder
//{
//    if (! (self = [super initWithCoder:aDecoder])) return nil;
//    return [self customInit];
//}
//
//- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    if (! (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) return nil;
//    return [self customInit];
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    @autoreleasepool {  // @autoreleasepool ensures sensitive data will be dealocated immediately
        self.seedOutlet.text = [[BRWalletManager sharedInstance] seedPhrase];
    }
}


- (IBAction)doneAction:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
