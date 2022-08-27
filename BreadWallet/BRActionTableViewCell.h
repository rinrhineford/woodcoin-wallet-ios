//
//  BRActionTableViewCell.h
//  WoodcoinWallet
//
//  Created by Renat Gafarov on 01/08/2022.
//  Copyright © 2022 Aaron Voisine. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface BRActionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;

@end

NS_ASSUME_NONNULL_END
