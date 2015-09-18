//
//  DCPatientGraphicalRepresentationView.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 09/06/15.
//
//

#import <UIKit/UIKit.h>
#import "DCPatient.h"
#import "DCBed.h"

@protocol DCPatientGraphicalRepresentationViewDelegate <NSObject>

- (void)goToPatientDetailView:(DCPatient *)currentPatient;

@end

typedef enum : NSUInteger {
    kDirectionUp,
    kDirectionDown,
    kDirectionLeft,
    kDirectionRight
} BedDirection;

@interface DCPatientGraphicalRepresentationView : UIView

@property (nonatomic, assign) id <DCPatientGraphicalRepresentationViewDelegate> delegate;

- (id)initWithBedDetails:(DCBed *)bedShown;
- (void)populateValuesToViewElements;
- (void)adjustViewFrame;

- (IBAction)gotoPatientDetails:(id)sender;

@end
