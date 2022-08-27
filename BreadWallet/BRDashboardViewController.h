//
//  BRDashboardViewController.h
//  WoodcoinWallet
//
//  Created by Renat Gafarov on 03/08/2022.
//  Copyright © 2022 Aaron Voisine. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface BRDashboardViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *fiatBalanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *cryptoBalanceLabel;
@property (strong, nonatomic) IBOutlet UITableView *transactionsTable;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

NS_ASSUME_NONNULL_END
