//
//  DCWarning.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 7/22/15.
//
//

#import "DCWarning.h"

static NSString *const kCommentKey           =       @"comment";
static NSString *const kResourceTypeKey      =       @"resourceType";
static NSString *const kDetailKey            =       @"detail";
static NSString *const kSeverityKey          =       @"severity";
static NSString *const kExtensionKey         =       @"extension";
static NSString *const kEventTypeUrl         =       @"http://openapi.e-mis.com/fhir/extensions/contra-indication-event-type";
static NSString *const kTargetConditionUrl   =       @"http://openapi.e-mis.com/fhir/extensions/target-condition";
static NSString *const kTargetPreparationUrl =       @"http://openapi.e-mis.com/fhir/extensions/target-preparation";
static NSString *const kUrl                  =       @"url";
static NSString *const kValueString          =       @"valueString";

#define DRUG_TO_DRUG_INTERACTION @"Drug To Drug Interaction"

@implementation DCWarning

- (DCWarning *)initWithDictionary:(NSDictionary*)warningDictionary {
    
    if (self == [super init]) {
        NSMutableString *titleValue = [[NSMutableString alloc] init];
        if ([warningDictionary valueForKey:kExtensionKey]) {
            NSArray *extensionArray = [warningDictionary valueForKey:kExtensionKey];
            for (NSDictionary *extensionDict in extensionArray) {
                if ([[extensionDict valueForKey:kUrl] isEqualToString:kEventTypeUrl]) {
                    //value corresponding to event type is first word of title
                    [titleValue appendString:[extensionDict valueForKey:kValueString]];
                }
                if ([titleValue isEqualToString:DRUG_TO_DRUG_INTERACTION]) {
                    if ([[extensionDict valueForKey:kUrl] isEqualToString:kTargetPreparationUrl]) {
                        self.detail = [extensionDict valueForKey:kValueString];
                    }
                } else {
                    if ([[extensionDict valueForKey:kUrl] isEqualToString:kTargetConditionUrl]) {
                        self.detail = [extensionDict valueForKey:kValueString];
                    }
                }
            }
        }
        if ([warningDictionary valueForKey:kDetailKey]) {
            [titleValue appendFormat:@"  %@", [warningDictionary valueForKey:kDetailKey]];
        }
        if ([warningDictionary valueForKey:kResourceTypeKey]) {
            self.resourceType = [warningDictionary valueForKey:kResourceTypeKey];
        }
        if ([warningDictionary valueForKey:kSeverityKey]) {
            self.severity = [warningDictionary valueForKey:kSeverityKey];
        }
        self.title = titleValue;
    }
    return self;
}

@end
