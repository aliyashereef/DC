//
// DDPopoverBackgroundView.m
// https://github.com/ddebin/DDPopoverBackgroundView
//


//
//	ARC Helper
//
//	Version 2.2
//
//	Created by Nick Lockwood on 05/01/2012.
//	Copyright 2012 Charcoal Design
//
//	Distributed under the permissive zlib license
//	Get the latest version from here:
//
//	https://gist.github.com/1563325
//

#import <Availability.h>
#undef ah_retain
#undef ah_dealloc
#undef ah_autorelease
#undef ah_dealloc
#if __has_feature(objc_arc)
#define ah_retain self
#define ah_release self
#define ah_autorelease self
#define ah_dealloc self
#else
#define ah_retain retain
#define ah_release release
#define ah_autorelease autorelease
#define ah_dealloc dealloc
#endif

//	ARC Helper ends


#import <QuartzCore/QuartzCore.h>
#import "DDPopoverBackgroundView.h"


#define DEFAULT_ARROW_BASE 35.0f
static CGFloat s_ArrowBase = DEFAULT_ARROW_BASE;

#define DEFAULT_ARROW_HEIGHT 19.0f
static CGFloat s_ArrowHeight = DEFAULT_ARROW_HEIGHT;

#define BKG_IMAGE_SIZE 40.0f
#define BKG_IMAGE_CORNER_RADIUS 8.0f

static CGFloat s_BackgroundImageCornerRadius = BKG_IMAGE_CORNER_RADIUS;
#define BKG_IMAGE_CAPINSET (s_BackgroundImageCornerRadius * 2.0f)

#define TOP_CONTENT_INSET s_ContentInset
#define LEFT_CONTENT_INSET s_ContentInset
#define BOTTOM_CONTENT_INSET s_ContentInset
#define RIGHT_CONTENT_INSET s_ContentInset

#define DEFAULT_CONTENT_INSET 9.0f
static CGFloat s_ContentInset = DEFAULT_CONTENT_INSET;

#define DEFAULT_TINT_COLOR [UIColor colorWithRed:232.0f/255.0f green:247.0f/255.0f blue:255.0f/255.0f alpha:1.0]
static UIColor *s_TintColor = nil;

#define DEFAULT_SHADOW_ENABLED YES
static BOOL s_ShadowEnabled = DEFAULT_SHADOW_ENABLED;

static UIImage *s_DefaultTopArrowImage = nil;
static UIImage *s_DefaultLeftArrowImage = nil;
static UIImage *s_DefaultRightArrowImage = nil;
static UIImage *s_DefaultBottomArrowImage = nil;
static UIImage *s_DefaultBackgroundImage = nil;


#pragma mark - Implementation

@interface DDPopoverBackgroundView () {
    CAShapeLayer *arrowLayer;
    
}

@end

@implementation DDPopoverBackgroundView

@synthesize arrowOffset, arrowDirection;


#pragma mark - Overriden class methods

/**
 Return the width of the arrow triangle at its base.
 */
+ (CGFloat)arrowBase
{
	return s_ArrowBase;
}

/**
 Return the height of the arrow (measured in points) from its base to its tip.
 */
+ (CGFloat)arrowHeight
{
	return s_ArrowHeight;
}

/**
 Return the insets for the content portion of the popover.
 */
+ (UIEdgeInsets)contentViewInsets
{
	return UIEdgeInsetsMake(TOP_CONTENT_INSET, LEFT_CONTENT_INSET, BOTTOM_CONTENT_INSET, RIGHT_CONTENT_INSET);
}


#pragma mark - Custom setters for updating layout

/*
 Whenever arrow changes direction or position, layout subviews will be called
 in order to update arrow and background frames
 */

- (void)setArrowOffset:(CGFloat)_arrowOffset
{
	arrowOffset = _arrowOffset;
	[self setNeedsLayout];
}

- (void)setArrowDirection:(UIPopoverArrowDirection)_arrowDirection
{
	arrowDirection = _arrowDirection;
	[self setNeedsLayout];
}


#pragma mark - Global statics setters

+ (void)setBackgroundImageCornerRadius:(CGFloat)cornerRadius
{
    s_BackgroundImageCornerRadius = cornerRadius;
}

+ (void)setContentInset:(CGFloat)contentInset
{
	s_ContentInset = contentInset;
}

+ (void)setTintColor:(UIColor *)tintColor
{
	[s_TintColor ah_release];
	s_TintColor = [tintColor ah_retain];
}

+ (void)setShadowEnabled:(BOOL)shadowEnabled
{
	s_ShadowEnabled = shadowEnabled;
}

+ (void)setArrowBase:(CGFloat)arrowBase
{
	s_ArrowBase = arrowBase;
}

+ (void)setArrowHeight:(CGFloat)arrowHeight
{
	s_ArrowHeight = arrowHeight;
}

+ (void)setBackgroundImage:(UIImage *)background top:(UIImage *)top right:(UIImage *)right bottom:(UIImage *)bottom left:(UIImage *)left
{
	[s_DefaultBackgroundImage ah_release];
	s_DefaultBackgroundImage = [background ah_retain];

	[s_DefaultTopArrowImage ah_release];
	s_DefaultTopArrowImage = [top ah_retain];

	[s_DefaultRightArrowImage ah_release];
	s_DefaultRightArrowImage = [right ah_retain];

	[s_DefaultBottomArrowImage ah_release];
	s_DefaultBottomArrowImage = [bottom ah_retain];

	[s_DefaultLeftArrowImage ah_release];
	s_DefaultLeftArrowImage = [left ah_retain];
}


#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		if ((s_DefaultBackgroundImage == nil) || (s_DefaultTopArrowImage == nil) || (s_DefaultRightArrowImage == nil) || (s_DefaultBottomArrowImage == nil) || (s_DefaultLeftArrowImage == nil))
		{
			if (s_TintColor == nil) s_TintColor = [DEFAULT_TINT_COLOR ah_retain];
			[DDPopoverBackgroundView buildArrowImagesWithTintColor:s_TintColor];
		}

		[popoverBackgroundImageView ah_release];
		popoverBackgroundImageView = [[UIImageView alloc] initWithImage:s_DefaultBackgroundImage];
		[self addSubview:popoverBackgroundImageView];

		[arrowImageView ah_release];
		arrowImageView = [[UIImageView alloc] init];
		[self addSubview:arrowImageView];
        UIColor *backgroundColor = [UIColor colorWithRed:232.0f/255.0f green:247.0f/255.0f blue:255.0f/255.0f alpha:1.0];
       // arrowLayer = [arrowImageView layer];

		if (s_ShadowEnabled)
		{
			popoverBackgroundImageView.layer.shadowColor = backgroundColor.CGColor;
			//popoverBackgroundImageView.layer.shadowOpacity = 0.4f;
			//popoverBackgroundImageView.layer.shadowRadius = 2.0f;
			//popoverBackgroundImageView.layer.shadowOffset = CGSizeMake(0.0f, 1.5f);
            popoverBackgroundImageView.layer.borderWidth = 1.0f;
            popoverBackgroundImageView.layer.cornerRadius = 5.0f;
            popoverBackgroundImageView.layer.borderColor = [UIColor colorWithRed:191.0f/255.0f green:211.0f/255.0f blue:222.0f/255.0f alpha:1.0].CGColor;
            

			//arrowImageView.layer.shadowColor = backgroundColor.CGColor;
			//arrowImageView.layer.shadowOpacity = 0.4f;
			//arrowImageView.layer.shadowRadius = 2.0f;
			//arrowImageView.layer.shadowOffset = CGSizeMake(0.0f, 1.5f);
			arrowImageView.layer.masksToBounds = YES;
            //arrowImageView.layer.borderColor = [UIColor colorWithRed:191.0f/255.0f green:211.0f/255.0f blue:222.0f/255.0f alpha:1.0].CGColor;
           // arrowImageView.image = [UIImage imageNamed:@"UpArrowImage"];
           
		}
	}

	return self;
}

#if !__has_feature(objc_arc)
- (void)dealloc
{
	[arrowImageView release];
	[popoverBackgroundImageView release];
	[super dealloc];
}
#endif


#pragma mark - Arrow images build

+ (void)rebuildArrowImages
{
	[DDPopoverBackgroundView buildArrowImagesWithTintColor:s_TintColor];
}

+ (void)buildArrowImagesWithTintColor:(UIColor *)tintColor
{
	UIBezierPath *arrowPath;

	// top arrow

	UIGraphicsBeginImageContextWithOptions(CGSizeMake(s_ArrowBase, s_ArrowHeight), NO, 0.0f);

	arrowPath = [UIBezierPath bezierPath];
    UIColor *stokeColor = [UIColor colorWithRed:191.0f/255.0f green:211.0f/255.0f blue:222.0f/255.0f alpha:1.0];
    [stokeColor setStroke];
	[arrowPath moveToPoint:	  CGPointMake(s_ArrowBase/2.0f, 0.0f)];
	[arrowPath addLineToPoint:CGPointMake(s_ArrowBase, s_ArrowHeight)];
	[arrowPath addLineToPoint:CGPointMake(0.0f, s_ArrowHeight)];
	[arrowPath addLineToPoint:CGPointMake(s_ArrowBase/2.0f, 0.0f)];

	[tintColor setFill];    

	[arrowPath fill];
    [arrowPath stroke];
    
   


	[s_DefaultTopArrowImage ah_release];
	s_DefaultTopArrowImage = [UIGraphicsGetImageFromCurrentImageContext() ah_retain];

	UIGraphicsEndImageContext();
    
    

	// bottom arrow

	UIGraphicsBeginImageContextWithOptions(CGSizeMake(s_ArrowBase, s_ArrowHeight), NO, 0.0f);

	arrowPath = [UIBezierPath bezierPath];
    [stokeColor setStroke];
	[arrowPath moveToPoint:	  CGPointMake(0.0f, 0.0f)];
	[arrowPath addLineToPoint:CGPointMake(s_ArrowBase, 0.0f)];
	[arrowPath addLineToPoint:CGPointMake(s_ArrowBase/2.0f, s_ArrowHeight)];
	[arrowPath addLineToPoint:CGPointMake(0.0f, 0.0f)];

	[tintColor setFill];
	[arrowPath fill];
    [arrowPath stroke];


	[s_DefaultBottomArrowImage ah_release];
	s_DefaultBottomArrowImage = [UIGraphicsGetImageFromCurrentImageContext() ah_retain];

	UIGraphicsEndImageContext();

	// left arrow

	UIGraphicsBeginImageContextWithOptions(CGSizeMake(s_ArrowHeight, s_ArrowBase), NO, 0.0f);

	arrowPath = [UIBezierPath bezierPath];
    [stokeColor setStroke];
	[arrowPath moveToPoint:	  CGPointMake(s_ArrowHeight, 0.0f)];
	[arrowPath addLineToPoint:CGPointMake(s_ArrowHeight, s_ArrowBase)];
	[arrowPath addLineToPoint:CGPointMake(0.0f, s_ArrowBase/2.0f)];
	[arrowPath addLineToPoint:CGPointMake(s_ArrowHeight, 0.0f)];

	[tintColor setFill];
	[arrowPath fill];
    [arrowPath stroke];

	[s_DefaultLeftArrowImage ah_release];
	s_DefaultLeftArrowImage = [UIGraphicsGetImageFromCurrentImageContext() ah_retain];

	UIGraphicsEndImageContext();

	// right arrow

	UIGraphicsBeginImageContextWithOptions(CGSizeMake(s_ArrowHeight, s_ArrowBase), NO, 0.0f);

	arrowPath = [UIBezierPath bezierPath];
    [stokeColor setStroke];
	[arrowPath moveToPoint:	  CGPointMake(0.0f, 0.0f)];
	[arrowPath addLineToPoint:CGPointMake(s_ArrowHeight, s_ArrowBase/2.0f)];
	[arrowPath addLineToPoint:CGPointMake(0.0f, s_ArrowBase)];
	[arrowPath addLineToPoint:CGPointMake(0.0f, 0.0f)];

	[tintColor setFill];
	[arrowPath fill];
    [arrowPath stroke];

	[s_DefaultRightArrowImage ah_release];
	s_DefaultRightArrowImage = [UIGraphicsGetImageFromCurrentImageContext() ah_retain];
    

	UIGraphicsEndImageContext();

	// background

	UIGraphicsBeginImageContextWithOptions(CGSizeMake(BKG_IMAGE_SIZE, BKG_IMAGE_SIZE), NO, 0.0f);

	UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0.0f, 0.0f, BKG_IMAGE_SIZE, BKG_IMAGE_SIZE)
														  cornerRadius:s_BackgroundImageCornerRadius];
	[tintColor setFill];
	[borderPath fill];

	UIEdgeInsets capInsets = UIEdgeInsetsMake(BKG_IMAGE_CAPINSET, BKG_IMAGE_CAPINSET, BKG_IMAGE_CAPINSET, BKG_IMAGE_CAPINSET);

	[s_DefaultBackgroundImage ah_release];
	s_DefaultBackgroundImage = [[UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:capInsets] ah_retain];

	UIGraphicsEndImageContext();
}


#pragma mark - Layout subviews

- (void)layoutSubviews
{
	CGFloat popoverImageOriginX = 0.0f;
	CGFloat popoverImageOriginY = 0.0f;

	CGFloat popoverImageWidth = self.bounds.size.width;
	CGFloat popoverImageHeight = self.bounds.size.height;

	CGFloat arrowImageOriginX = 0.0f;
	CGFloat arrowImageOriginY = 0.0f;

	CGFloat arrowImageWidth = s_ArrowBase;
	CGFloat arrowImageHeight = s_ArrowHeight;

	switch (self.arrowDirection)
	{
		case UIPopoverArrowDirectionUp:

			popoverImageOriginY = s_ArrowHeight;
			popoverImageHeight = self.bounds.size.height - s_ArrowHeight;

			// Calculating arrow x position using arrow offset, arrow width and popover width
			arrowImageOriginX = roundf((self.bounds.size.width - s_ArrowBase) / 2.0f + self.arrowOffset);

			// If arrow image exceeds rounded corner arrow image x postion is adjusted
			if ((arrowImageOriginX + s_ArrowBase) > (self.bounds.size.width - s_BackgroundImageCornerRadius))
			{
				arrowImageOriginX -= s_BackgroundImageCornerRadius;
			}

			if (arrowImageOriginX < s_BackgroundImageCornerRadius)
			{
				arrowImageOriginX += s_BackgroundImageCornerRadius;
			}

			// Setting arrow image for current arrow direction
			arrowImageView.image = s_DefaultTopArrowImage;
            arrowImageView.image = [UIImage imageNamed:@"UpArrowImage"];
            arrowImageView.frame = CGRectMake(arrowImageOriginX + 5, arrowImageOriginY +2 , 21, 18.0);

			break;

		case UIPopoverArrowDirectionDown:

			popoverImageHeight = self.bounds.size.height - s_ArrowHeight;

			arrowImageOriginX = roundf((self.bounds.size.width - s_ArrowBase) / 2.0f + self.arrowOffset);

			if ((arrowImageOriginX + s_ArrowBase) > (self.bounds.size.width - s_BackgroundImageCornerRadius))
			{
				arrowImageOriginX -= s_BackgroundImageCornerRadius;
			}

			if (arrowImageOriginX < s_BackgroundImageCornerRadius)
			{
				arrowImageOriginX += s_BackgroundImageCornerRadius;
			}

			arrowImageOriginY = popoverImageHeight;

			arrowImageView.image = s_DefaultBottomArrowImage;
            arrowImageView.image = [UIImage imageNamed:@"BottomArrow"];
            arrowImageView.frame = CGRectMake(arrowImageOriginX + 5, arrowImageOriginY - 1 , 21, 18.0);

			break;

		case UIPopoverArrowDirectionLeft:

			popoverImageOriginX = s_ArrowHeight;
			popoverImageWidth = self.bounds.size.width - s_ArrowHeight;

			arrowImageOriginY = roundf((self.bounds.size.height - s_ArrowBase) / 2.0f + self.arrowOffset);

			if ((arrowImageOriginY + s_ArrowBase) > (self.bounds.size.height - s_BackgroundImageCornerRadius))
			{
				arrowImageOriginY -= s_BackgroundImageCornerRadius;
			}

			if (arrowImageOriginY < s_BackgroundImageCornerRadius)
			{
				arrowImageOriginY += s_BackgroundImageCornerRadius;
			}

			arrowImageWidth = s_ArrowHeight;
			arrowImageHeight = s_ArrowBase;

			arrowImageView.image = s_DefaultLeftArrowImage;

			break;

		case UIPopoverArrowDirectionRight:

			popoverImageWidth = self.bounds.size.width - s_ArrowHeight;

			arrowImageOriginX = popoverImageWidth;
			arrowImageOriginY = roundf((self.bounds.size.height - s_ArrowBase) / 2.0f + self.arrowOffset);

			if ((arrowImageOriginY + s_ArrowBase) > (self.bounds.size.height - s_BackgroundImageCornerRadius))
			{
				arrowImageOriginY -= s_BackgroundImageCornerRadius;
			}

			if (arrowImageOriginY < s_BackgroundImageCornerRadius)
			{
				arrowImageOriginY += s_BackgroundImageCornerRadius;
			}

			arrowImageWidth = s_ArrowHeight;
			arrowImageHeight = s_ArrowBase;

			arrowImageView.image = s_DefaultRightArrowImage;
            arrowImageView.image = [UIImage imageNamed:@"RightArrow"];
            arrowImageView.frame = CGRectMake(arrowImageOriginX - 1, arrowImageOriginY + 5, 21, 18.0);
 
			break;

		default:
			break;
	}

	popoverBackgroundImageView.frame = CGRectMake(popoverImageOriginX, popoverImageOriginY, popoverImageWidth, popoverImageHeight);
	//arrowImageView.frame = CGRectMake(arrowImageOriginX + 5, arrowImageOriginY +2 , 21, 18.0);
    //arrowImageView.frame = CGRectMake(arrowImageOriginX, arrowImageOriginY, arrowImageWidth, arrowImageHeight);
    
   // arrowImageView.image = [UIImage imageNamed:@"UpArrowImage"];
    
}

@end
