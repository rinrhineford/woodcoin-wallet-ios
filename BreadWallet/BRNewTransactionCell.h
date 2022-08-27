//
//  BRNewTransactionCell.h
//  WoodcoinWallet
//
//  Created by Renat Gafarov on 03/08/2022.
//  Copyright © 2022 Aaron Voisine. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface BRNewTransactionCell : UITableViewCell

- (void)setIsReceivedIcon:(BOOL)isReceived;
- (void)setAddress:(NSString *)address;
- (void)setDate:(NSString *)date;
- (void)setCryptoAmount:(NSString *)cryptoAmount;
- (void)setFiatAmount:(NSString *)fiatAmount;

@end

NS_ASSUME_NONNULL_END
