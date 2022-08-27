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

@property (weak, nonatomic) IBOutlet UIView *textViewContainer;
@property (weak, nonatomic) CAShapeLayer *textViewContainerBorderLayer;

@end

@implementation BRShowSeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    @autoreleasepool {  // @autoreleasepool ensures sensitive data will be dealocated immediately
        self.seedOutlet.text = [[BRWalletManager sharedInstance] seedPhrase];
    }
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

- (IBAction)doneAction:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)copy:(id)sender {
    [[UIPasteboard generalPasteboard] setString:self.seedOutlet.text];
}
@end
