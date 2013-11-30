//
//  PTVAlarmTableViewCell.h
//  PTV Alarm
//
//  Created by Kangbo Mo on 30/11/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Alarms.h"
@interface PTVAlarmTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *uiswitch;
@property (weak, nonatomic) IBOutlet UILabel *mainlabel;
@property (weak, nonatomic) IBOutlet UILabel *sublabel;
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak,nonatomic) Alarms * alarm;
@end
