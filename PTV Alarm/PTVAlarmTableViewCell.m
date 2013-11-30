//
//  PTVAlarmTableViewCell.m
//  PTV Alarm
//
//  Created by Kangbo Mo on 30/11/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import "PTVAlarmTableViewCell.h"

@implementation PTVAlarmTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)switchAction:(id)sender {
    UISwitch * uis=(UISwitch *) sender;
    self.alarm.state=[NSNumber numberWithBool:uis.on];
}

@end
