//
//  DCPatientAlert.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 29/04/15.
//
//

#import "DCPatientAlert.h"

@implementation DCPatientAlert

- (DCPatientAlert *)initWithAlertDictionary:(NSDictionary *)alertDictionary {
    
    if (self = [super init]) {
//        self.alertText = [alertDictionary objectForKey:ALERT_TEXT_KEY];
//        self.alertDateString = [alertDictionary objectForKey:ALERT_DATE_KEY];
        self.isSevere = NO; // TODO: need to change as per the actual API response.
        self.alertText = [alertDictionary objectForKey:WARNING_TEXT];
    }
    return self;
}

@end
