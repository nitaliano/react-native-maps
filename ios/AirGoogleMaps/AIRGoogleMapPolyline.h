//
//  AIRGoogleMapPolyline.h
//
//  Created by Nick Italiano on 10/22/16.
//
#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "AIRMapCoordinate.h"
#import "AIRGoogleMapMarker.h"
#import "AIRGMSPolyline.h"

@interface AIRGoogleMapPolyline : UIView

@property (nonatomic, strong) AIRGMSPolyline* polyline;
@property (nonatomic, strong) NSMutableArray<AIRGoogleMapMarker *> *markers;
@property (nonatomic, strong) NSArray<AIRMapCoordinate *> *coordinates;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) double strokeWidth;
@property (nonatomic, assign) UIColor *fillColor;
@property (nonatomic, assign) BOOL geodesic;
@property (nonatomic, assign) NSString *title;
@property (nonatomic, assign) int zIndex;
@property (nonatomic, assign) BOOL editable;

@property (nonatomic, copy) RCTBubblingEventBlock onVertexPress;

@end
