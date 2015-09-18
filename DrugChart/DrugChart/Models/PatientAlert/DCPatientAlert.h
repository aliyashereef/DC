//
//  DCPatientAlert.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 29/04/15.
//
//

#import <Foundation/Foundation.h>

#define SEVERITY_KEY @"isSevere"
#define ALERT_TEXT_KEY @"alertText"
#define ALERT_DATE_KEY @"alertDate"

#define WARNING_TEXT @"warningText"

@interface DCPatientAlert : NSObject

@property (nonatomic, strong) NSString *alertText;
//@property (nonatomic, strong) NSString *alertDateString;
@property (nonatomic, assign) BOOL isSevere;

- (DCPatientAlert *)initWithAlertDictionary:(NSDictionary *)alertDictionary;

@end
