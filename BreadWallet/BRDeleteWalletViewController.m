//
//  BRDeleteWalletViewController.m
//  WoodcoinWallet
//
//  Created by Renat Gafarov on 16/08/2022.
//  Copyright © 2022 Aaron Voisine. All rights reserved.
//

#import "BRDeleteWalletViewController.h"
#import "BRWalletManager.h"
#import "BRWallet.h"

@interface BRDeleteWalletViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *textViewContainer;
@property (weak, nonatomic) CALayer *textViewContainerBorderLayer;

@end

@implementation BRDeleteWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.text = [[BRWalletManager sharedInstance] seedPhrase];
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

- (IBAction)deleteWallet:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        BRWalletManager *m = [BRWalletManager sharedInstance];
        [m eraseSeedPhrase];
        [[NSNotificationCenter defaultCenter]  postNotificationName:@"BRTabBarSetDefaultTab" object:nil];
    }];
}

- (IBAction)crossAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)copyAction:(UIButton *)sender {
    [[UIPasteboard generalPasteboard] setString:self.textView.text];
}

@end
