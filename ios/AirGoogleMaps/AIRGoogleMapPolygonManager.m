//
//  AIRGoogleMapPolylgoneManager.m
//
//  Created by Nick Italiano on 10/22/16.
//
#import "AIRGoogleMapPolygonManager.h"

#import "RCTBridge.h"
#import "RCTConvert.h"
#import "RCTConvert+CoreLocation.h"
#import "RCTConvert+MoreMapKit.h"
#import "RCTEventDispatcher.h"
#import "UIView+React.h"
#import "RCTViewManager.h"
#import "AIRGoogleMapPolygon.h"

@interface AIRGoogleMapPolygonManager()

@end

@implementation AIRGoogleMapPolygonManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
  AIRGoogleMapPolygon *polygon = [AIRGoogleMapPolygon new];
  polygon.bridge = self.bridge;
  return polygon;
}

RCT_EXPORT_VIEW_PROPERTY(coordinates, AIRMapCoordinateArray)
RCT_EXPORT_VIEW_PROPERTY(fillColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(strokeWidth, double)
RCT_EXPORT_VIEW_PROPERTY(strokeColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(geodesic, BOOL)
RCT_EXPORT_VIEW_PROPERTY(zIndex, int)
RCT_EXPORT_VIEW_PROPERTY(editable, BOOL)
RCT_EXPORT_VIEW_PROPERTY(markerImage, NSString)
RCT_EXPORT_VIEW_PROPERTY(midpointMarkerImage, NSString)

RCT_EXPORT_VIEW_PROPERTY(onVertexPress, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onEditStart, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onEditEnd, RCTDirectEventBlock)

@end
