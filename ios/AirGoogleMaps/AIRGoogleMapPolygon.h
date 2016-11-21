//
//  AIRGoogleMapPolygon.h
//
//  Created by Nick Italiano on 10/22/16.
//

#import "AIRGMSPolygon.h"
#import <GoogleMaps/GoogleMaps.h>
#import "AIRMapCoordinate.h"
#import "AIRGMSMarker.h"

@interface AIRGoogleMapPolygon : UIView

@property (nonatomic, weak) RCTBridge *bridge;
@property (nonatomic, strong) AIRGMSPolygon *polygon;
@property (nonatomic, strong) NSMutableArray<AIRGoogleMapMarker *> *markers;
@property (nonatomic, strong) NSArray<AIRMapCoordinate *> *coordinates;

@property (nonatomic, copy) RCTBubblingEventBlock onVertexPress;
@property (nonatomic, copy) RCTDirectEventBlock onEditStart;
@property (nonatomic, copy) RCTDirectEventBlock onEditEnd;
@property (nonatomic, copy) NSString *markerImage;

@property (nonatomic, assign) UIColor *fillColor;
@property (nonatomic, assign) double strokeWidth;
@property (nonatomic, assign) UIColor *strokeColor;
@property (nonatomic, assign) BOOL geodesic;
@property (nonatomic, assign) int zIndex;
@property (nonatomic, assign) BOOL editable;

@end
