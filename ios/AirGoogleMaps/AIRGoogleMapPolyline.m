//
//  AIRGoogleMapPolyline.m
//
//  Created by Nick Italiano on 10/22/16.
//
#import <UIKit/UIKit.h>
#import "AIRGoogleMapPolyline.h"
#import "AIRMapCoordinate.h"
#import "AIRGoogleMapMarker.h"
#import "AIRGoogleMapMarkerManager.h"
#import "AIRGMSPolyline.h"
#import <GoogleMaps/GoogleMaps.h>
#import "RCTUtils.h"

@implementation AIRGoogleMapPolyline

- (instancetype)init
{
  if (self = [super init]) {
    _markers = [NSMutableArray new];
    _polyline = [[AIRGMSPolyline alloc] init];
    _polyline.onRemove = [self onRemove];
  }
  return self;
}

-(void)setCoordinates:(NSArray<AIRMapCoordinate *> *)coordinates
{
  _coordinates = coordinates;
  
  GMSMutablePath *path = [GMSMutablePath path];
  for(int i = 0; i < coordinates.count; i++)
  {
    [path addCoordinate:coordinates[i].coordinate];

    if (_editable) {
      AIRGoogleMapMarker *marker = [[AIRGoogleMapMarker alloc] init];
      marker.coordinate = coordinates[i].coordinate;
      marker.realMarker.map = _polyline.map;
      
      marker.onPress = ^(NSDictionary *e) {
        if (_onVertexPress) {
          NSMutableDictionary *updatedEvent = [e mutableCopy];
          updatedEvent[@"vertexIndex"] = [NSNumber numberWithInt:i];
          _onVertexPress(updatedEvent);
        }
      };
      
      [_markers addObject:marker];
    }
  }
  
  _polyline.path = path;
}

-(void)setStrokeColor:(UIColor *)strokeColor
{
  _strokeColor = strokeColor;
  _polyline.strokeColor = strokeColor;
}

-(void)setStrokeWidth:(double)strokeWidth
{
  _strokeWidth = strokeWidth;
  _polyline.strokeWidth = strokeWidth;
}

-(void)setFillColor:(UIColor *)fillColor
{
  _fillColor = fillColor;
  _polyline.spans = @[[GMSStyleSpan spanWithColor:fillColor]];
}

-(void)setGeodesic:(BOOL)geodesic
{
  _geodesic = geodesic;
  _polyline.geodesic = geodesic;
}

-(void)setTitle:(NSString *)title
{
  _title = title;
  _polyline.title = _title;
}

-(void) setZIndex:(int)zIndex
{
  _zIndex = zIndex;
  _polyline.zIndex = zIndex;
}

-(void(^)(GMSMapView *map))onRemove
{
  return ^(GMSMapView *map) {
    [self clearMarkers];
  };
}

-(void)clearMarkers
{
  for (int i = 0; i < _markers.count; i++) {
    AIRGoogleMapMarker *marker = (AIRGoogleMapMarker*)[_markers objectAtIndex:i];
    marker.realMarker.map = nil;
  }
  [_markers removeAllObjects];
}

@end
