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
    _midpointMarkers = [NSMutableArray new];
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
    [self clearMidpointMarkers];
  } else {
    [self addMarkers];
    [self addMidpointMarkers];
  }
}

- (void)setCoordinates:(NSArray<AIRMapCoordinate *> *)coordinates
{
  _coordinates = [coordinates mutableCopy];

  GMSMutablePath *path = [GMSMutablePath path];
  for(int i = 0; i < coordinates.count; i++)
  {
    [path addCoordinate:coordinates[i].coordinate];
  }

  _polygon.path = path;
  [self addMarkers];
  [self addMidpointMarkers];
}

-(void)setMarkerImage:(NSString *)markerImage
{
  _markerImage = markerImage;
  
  for (int i = 0; i < _markers.count; i++) {
    AIRGoogleMapMarker *marker = (AIRGoogleMapMarker*)[_markers objectAtIndex:i];
    marker.imageSrc = _markerImage;
  }
  
  for (int i = 0; i < _midpointMarkers.count; i++) {
    AIRGoogleMapMarker *marker = (AIRGoogleMapMarker*)[_midpointMarkers objectAtIndex:i];
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
    for (int i = 0; i < _midpointMarkers.count; i++) {
      AIRGoogleMapMarker *marker = (AIRGoogleMapMarker*)[_midpointMarkers objectAtIndex:i];
      [map insertReactSubview:marker atIndex:0];
    }
  };
}

-(void(^)(GMSMapView *map))onRemove
{
  return ^(GMSMapView *map) {
    [self clearMarkers];
    [self clearMidpointMarkers];
  };
}

-(void)addMarkers
{
  if (!_editable) {
    return;
  }
  
  [self clearMarkers];
  for(int i = 0; i < _coordinates.count; i++)
  {
    AIRGoogleMapMarker *marker = [self makeMarker:_coordinates[i].coordinate isMidpoint:NO];

    marker.onPress = ^(NSDictionary *e) {
      if (_onVertexPress) {
        NSMutableDictionary *updatedEvent = [e mutableCopy];
        updatedEvent[@"vertexIndex"] = [NSNumber numberWithInt:i];
        _onVertexPress(updatedEvent);
      }
    };
    
    marker.onDrag = ^(NSDictionary *e) {
      double lat = [[e valueForKeyPath:@"coordinate.latitude"] doubleValue];
      double lng = [[e valueForKeyPath:@"coordinate.longitude"] doubleValue];
      CLLocationCoordinate2D updatedCoord = CLLocationCoordinate2DMake(lat, lng);
      
      // update internal ref to coordinate
      AIRMapCoordinate *oldCoordinate = (AIRMapCoordinate*)[_coordinates objectAtIndex:i];
      oldCoordinate.coordinate = updatedCoord;
      [_coordinates replaceObjectAtIndex:i withObject:oldCoordinate];
      
      // update polygon
      GMSMutablePath *path = [_polygon.path mutableCopy];
      [path removeCoordinateAtIndex:i];
      [path insertCoordinate:updatedCoord atIndex:i];
      _polygon.path = path;

      // update midpoint markers
      if (_midpointMarkers.count < 2) {
        return;
      }
      
      
      // find midpoint markers that need to be updated
      AIRGoogleMapMarker *lowerBoundMarker;
      AIRGoogleMapMarker *upperBoundMarker;
      if (i == 0) {
        lowerBoundMarker = [self getMidpointMarkerAtIndex:_midpointMarkers.count - 1];
        upperBoundMarker = [self getMidpointMarkerAtIndex:0];
      } else {
        lowerBoundMarker = [self getMidpointMarkerAtIndex:i - 1];
        upperBoundMarker = [self getMidpointMarkerAtIndex:i];
      }
      
      // calculate new midpoint
      AIRMapCoordinate *previous;
      AIRMapCoordinate *next;
      AIRMapCoordinate *current = (AIRMapCoordinate*)[_coordinates objectAtIndex:i];
      
      if (i == 0) {
        previous = (AIRMapCoordinate*)[_coordinates objectAtIndex:_markers.count - 1];
        next = (AIRMapCoordinate*)[_coordinates objectAtIndex:i + 1];
      } else if (i == _coordinates.count - 1) {
        previous = (AIRMapCoordinate*)[_coordinates objectAtIndex:i - 1];
        next = (AIRMapCoordinate*)[_coordinates objectAtIndex:0];
      } else {
        previous = (AIRMapCoordinate*)[_coordinates objectAtIndex:i - 1];
        next = (AIRMapCoordinate*)[_coordinates objectAtIndex:i + 1];
      }
      
      lowerBoundMarker.coordinate = [self calculateMidpointBetweenCoordinates:previous to:current];
      upperBoundMarker.coordinate = [self calculateMidpointBetweenCoordinates:current to:next];
    };
    
    marker.onDragStart = ^(NSDictionary *e) {
      if (_onEditStart) {
        _onEditStart(e);
      }
    };
    
    marker.onDragEnd = ^(NSDictionary *e) {
      if (_onEditEnd) {
        _onEditEnd(e);
      }
    };
    
    [_markers addObject:marker];
  }
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

-(void)addMidpointMarkers
{
  if (!_editable) {
    return;
  }

  [self clearMidpointMarkers];
  for (int i = 0; i < _coordinates.count; i++)
  {
    // find midpoint coordinate
    AIRMapCoordinate *cur = (AIRMapCoordinate *)[_coordinates objectAtIndex:i];

    AIRMapCoordinate *next;
    if (i == _coordinates.count - 1) {
      next = (AIRMapCoordinate *)[_coordinates objectAtIndex:0];
    } else {
      next = (AIRMapCoordinate *)[_coordinates objectAtIndex:i + 1];
    }
    
    CLLocationCoordinate2D midpointCoord = [self calculateMidpointBetweenCoordinates:cur to:next];
    
    // add to map
    AIRGoogleMapMarker *marker = [self makeMarker:midpointCoord isMidpoint:YES];
    
    // Steps:
    // 1 - Add coordinate to (GMSPath)path on screen at position i + 1 (our current midpoint marker position) right before drag starts
    // 2 - Update our midpoint marker and path(i + 1) while dragging
    // 3 - Reinit shape with new coordinates

    marker.onDragStart = ^(NSDictionary *e) {
      double lat = [[e valueForKeyPath:@"coordinate.latitude"] doubleValue];
      double lng = [[e valueForKeyPath:@"coordinate.longitude"] doubleValue];
      CLLocationCoordinate2D updatedCoord = CLLocationCoordinate2DMake(lat, lng);
      
      // update polygon
      GMSMutablePath *path = [_polygon.path mutableCopy];
      [path insertCoordinate:updatedCoord atIndex:i + 1];
      _polygon.path = path;
    };
    
    __weak AIRGoogleMapMarker *weakMaker = marker;
    marker.onDrag = ^(NSDictionary *e) {
      double lat = [[e valueForKeyPath:@"coordinate.latitude"] doubleValue];
      double lng = [[e valueForKeyPath:@"coordinate.longitude"] doubleValue];
      CLLocationCoordinate2D updatedCoord = CLLocationCoordinate2DMake(lat, lng);
      
      // update polygon
      GMSMutablePath *path = [_polygon.path mutableCopy];
      [path replaceCoordinateAtIndex:i + 1 withCoordinate:updatedCoord];
      _polygon.path = path;
      
      // update marker
      weakMaker.coordinate = updatedCoord;
    };
    
    marker.onDragEnd = ^(NSDictionary* e) {
      double lat = [[e valueForKeyPath:@"coordinate.latitude"] doubleValue];
      double lng = [[e valueForKeyPath:@"coordinate.longitude"] doubleValue];
      
      AIRMapCoordinate *airMapCoord = [[AIRMapCoordinate alloc] init];
      airMapCoord.coordinate = CLLocationCoordinate2DMake(lat, lng);
      
      // reset coords
      NSMutableArray<AIRMapCoordinate *> *coordinates = [_coordinates mutableCopy];
      [coordinates insertObject:airMapCoord atIndex:i + 1];
      [self setCoordinates:coordinates];
    };
    
    [_midpointMarkers addObject:marker];
  }
}

-(void)clearMidpointMarkers
{
  for (int i = 0; i < _midpointMarkers.count; i++) {
    AIRGoogleMapMarker *marker = (AIRGoogleMapMarker*)[_midpointMarkers objectAtIndex:i];
    marker.realMarker.map = nil;
    [_polygon.map removeReactSubview:marker];
  }
  [_midpointMarkers removeAllObjects];
}

-(AIRGoogleMapMarker*)makeMarker:(CLLocationCoordinate2D)coordinate isMidpoint:(BOOL)midpoint
{
  AIRGoogleMapMarker *marker = [[AIRGoogleMapMarker alloc] init];
  marker.bridge = _bridge;
  marker.coordinate = coordinate;
  marker.zIndex = _polygon.zIndex + 1;
  marker.draggable = YES;
  marker.imageSrc = midpoint ? _midpointMarkerImage : _markerImage;
  marker.realMarker.map = _polygon.map;
  marker.anchor = CGPointMake(0.5f, 0.5f);
  return marker;
}

-(AIRGoogleMapMarker*)getMidpointMarkerAtIndex:(int)markerIndex
{
  return (AIRGoogleMapMarker*)[_midpointMarkers objectAtIndex:markerIndex];
}

-(CLLocationCoordinate2D)calculateMidpointBetweenCoordinates:(AIRMapCoordinate*)a to:(AIRMapCoordinate*)b
{
  GMSMapPoint midpoint = GMSMapPointInterpolate(GMSProject(a.coordinate), GMSProject(b.coordinate), 0.5);
  return GMSUnproject(midpoint);
}

@end
