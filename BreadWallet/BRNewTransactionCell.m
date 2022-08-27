//
//  BRNewTransactionCell.m
//  WoodcoinWallet
//
//  Created by Renat Gafarov on 03/08/2022.
//  Copyright © 2022 Aaron Voisine. All rights reserved.
//

#import "BRNewTransactionCell.h"

@interface BRNewTransactionCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *cryptoAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *fiatAmountLabel;

@end

@implementation BRNewTransactionCell

-(void)setIsReceivedIcon:(BOOL)isReceived
{
    UIImage *image = isReceived ? [UIImage imageNamed:@"Expand_down"] : [UIImage imageNamed:@"Expand_up"];
    self.iconView.image = image;
}

- (void)setAddress:(NSString *)address
{
    self.addressLabel.text = address;
}

- (void)setDate:(NSString *)date
{
    self.dateLabel.text = date;
}

- (void)setCryptoAmount:(NSString *)cryptoAmount
{
    self.cryptoAmountLabel.text = cryptoAmount;
}

- (void)setFiatAmount:(NSString *)fiatAmount
{
    self.fiatAmountLabel.text = fiatAmount;
}

@end
