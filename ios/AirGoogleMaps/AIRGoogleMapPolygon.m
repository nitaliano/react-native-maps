//
//  AIRGoogleMapPolygon.m
//
//  Created by Nick Italiano on 10/22/16.
//

#import "AIRGoogleMapMarker.h"
#import "AIRGoogleMapMarkerManager.h"
#import "AIRGMSPolygon.h"
#import "AIRGoogleMapPolygon.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation AIRGoogleMapPolygon

- (instancetype)init
{
  if (self = [super init]) {
    _markers = [NSMutableArray new];
    _polygon = [[AIRGMSPolygon alloc] init];
    _polygon.onAdd = [self onAdd];
    _polygon.onRemove = [self onRemove];
  }

  return self;
}

- (void)setEditable:(BOOL)editable
{
  _editable = editable;

  if (!editable) {
    [self clearMarkers];
  }
}

- (void)setCoordinates:(NSArray<AIRMapCoordinate *> *)coordinates
{
  _coordinates = coordinates;

  GMSMutablePath *path = [GMSMutablePath path];
  for(int i = 0; i < coordinates.count; i++)
  {
    [path addCoordinate:coordinates[i].coordinate];

    if (_editable) {
      AIRGoogleMapMarker *marker = [[AIRGoogleMapMarker alloc] init];
      marker.bridge = _bridge;
      marker.coordinate = coordinates[i].coordinate;
      marker.zIndex = _polygon.zIndex + 1;
      marker.draggable = YES;
      marker.imageSrc = _markerImage;
      marker.anchor = CGPointMake(0.5f, 0.5f);
      
      marker.onPress = ^(NSDictionary *e) {
        if (_onVertexPress) {
          NSMutableDictionary *updatedEvent = [e mutableCopy];
          updatedEvent[@"vertexPosition"] = [NSNumber numberWithInt:i];
          _onVertexPress(updatedEvent);
        }
      };
      
      marker.onDrag = ^(NSDictionary *e) {
        GMSMutablePath *path = [_polygon.path mutableCopy];
        double lat = [[e valueForKeyPath:@"coordinate.latitude"] doubleValue];
        double lng = [[e valueForKeyPath:@"coordinate.longitude"] doubleValue];
        [path removeCoordinateAtIndex:i];
        [path insertCoordinate:CLLocationCoordinate2DMake(lat, lng) atIndex:i];
        _polygon.path = path;
      };
      
      marker.onDragStart = ^(NSDictionary *e) {
        if (_onEditStart) {
          NSMutableDictionary *mutableEvt = [e mutableCopy];
          mutableEvt[@"vertexPosition"] = [NSNumber numberWithInt:i];
          _onEditStart(mutableEvt);
        }
      };
      
      marker.onDragEnd = ^(NSDictionary *e) {
        if (_onEditEnd) {
          NSMutableDictionary *mutableEvt = [e mutableCopy];
          mutableEvt[@"vertexPosition"] = [NSNumber numberWithInt:i];
          _onEditEnd(mutableEvt);
        }
      };
      
      [_markers addObject:marker];
    }
  }

  _polygon.path = path;
}

-(void)setMarkerImage:(NSString *)markerImage
{
  _markerImage = markerImage;
  
  for (int i = 0; i < _markers.count; i++) {
    AIRGoogleMapMarker *marker = (AIRGoogleMapMarker*)[_markers objectAtIndex:i];
    marker.imageSrc = _markerImage;
  }
}

-(void)setFillColor:(UIColor *)fillColor
{
  _fillColor = fillColor;
  _polygon.fillColor = fillColor;
}

-(void)setStrokeWidth:(double)strokeWidth
{
  _strokeWidth = strokeWidth;
  _polygon.strokeWidth = strokeWidth;
}

-(void)setStrokeColor:(UIColor *) strokeColor
{
  _strokeColor = strokeColor;
  _polygon.strokeColor = strokeColor;
}

-(void)setGeodesic:(BOOL)geodesic
{
  _geodesic = geodesic;
  _polygon.geodesic = geodesic;
}

-(void)setZIndex:(int)zIndex
{
  _zIndex = zIndex;
  _polygon.zIndex = zIndex;
}

-(void(^)(GMSMapView *map))onAdd
{
  return ^(GMSMapView *map) {
    for (int i = 0; i < _markers.count; i++) {
      AIRGoogleMapMarker *marker = (AIRGoogleMapMarker*)[_markers objectAtIndex:i];
      [map insertReactSubview:marker atIndex:0];
    }
  };
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
    [_polygon.map removeReactSubview:marker];
  }
  [_markers removeAllObjects];
}

@end
