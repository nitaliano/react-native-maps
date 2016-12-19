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
    [self clearMidpointMarkers];
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
      AIRGoogleMapMarker *marker = [self createVertex:coordinates[i] atPosition:[NSNumber numberWithInt:i] isMidpoint:NO];
      [_markers addObject:marker];
      
      if (i < _coordinates.count - 1) {
        AIRMapCoordinate *midpointCoord = [self calculateMidpointBetweenVertices:coordinates[i] to:coordinates[i + 1]];
        AIRGoogleMapMarker *midpointMarker = [self createVertex:midpointCoord atPosition:[NSNumber numberWithInt:i] isMidpoint:YES];
        [_midpointMarkers addObject:midpointMarker];
      } else {
        AIRMapCoordinate *midpointCoord = [self calculateMidpointBetweenVertices:coordinates[i] to:coordinates[0]];
        AIRGoogleMapMarker *midpointMarker = [self createVertex:midpointCoord atPosition:[NSNumber numberWithInt:i] isMidpoint:YES];
        [_midpointMarkers addObject:midpointMarker];
      }
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

-(void)setMidpointMarkerImage:(NSString *)midpointMarkerImage
{
  _midpointMarkerImage = midpointMarkerImage;
  
  for (int i = 0; i < _midpointMarkers.count; i++) {
    AIRGoogleMapMarker *marker = (AIRGoogleMapMarker*)[_midpointMarkers objectAtIndex:i];
    marker.imageSrc = _midpointMarkerImage;
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
    [self clearMidpointMarkers];
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

-(void)clearMidpointMarkers
{
  for (int i = 0; i < _midpointMarkers.count; i++) {
    AIRGoogleMapMarker *marker = (AIRGoogleMapMarker*)[_midpointMarkers objectAtIndex:i];
    marker.realMarker.map = nil;
    [_polygon.map removeReactSubview:marker];
  }
  [_midpointMarkers removeAllObjects];
}

-(AIRGoogleMapMarker*)createVertex:(AIRMapCoordinate*)airMapCoord atPosition:(NSNumber*)vertexPosition isMidpoint:(BOOL)midpoint
{
  AIRGoogleMapMarker *marker = [[AIRGoogleMapMarker alloc] init];
  marker.bridge = _bridge;
  marker.realMarker.tracksViewChanges = YES;
  marker.coordinate = airMapCoord.coordinate;
  marker.zIndex = _polygon.zIndex + 1;
  marker.draggable = YES;
  marker.imageSrc = midpoint ? _midpointMarkerImage : _markerImage;
  marker.anchor = CGPointMake(0.5f, 0.5f);
  
  if (!midpoint) {
    [self setOnDeleteVertex:marker atPosition:vertexPosition];
  }
  
  [self setOnVertexDragStart:marker atPosition:vertexPosition isMidpoint:midpoint];
  [self setOnVertexDrag:marker atPosition:vertexPosition isMidpoint:midpoint];
  [self setOnVertexDragEnd:marker atPosition:vertexPosition isMidpoint:midpoint];
  
  return marker;
}

-(void)setOnDeleteVertex:(AIRGoogleMapMarker*)marker atPosition:(NSNumber*)vertexPosition
{
  marker.onPress = ^(NSDictionary *e) {
    if (_onEditEnd) {
      if (_markers.count <= 3) {
        return;
      }
      NSMutableDictionary *mutableEvt = [[self eventFromVertex:e atPosition:vertexPosition isMidpoint:NO] mutableCopy];
      NSMutableArray<NSDictionary*> *coords = [mutableEvt objectForKey:@"coordinates"];
      [coords removeObjectAtIndex:[vertexPosition integerValue]];
      _onEditEnd(mutableEvt);
    }
  };
}

-(void)setOnVertexDragStart:(AIRGoogleMapMarker*)marker atPosition:(NSNumber*)vertexPosition isMidpoint:(BOOL)midpoint
{
  __weak AIRGoogleMapMarker *weakMarker = marker;
  marker.onDragStart = ^(NSDictionary *e) {
    long pos = [vertexPosition integerValue];
    
    if (midpoint) {
      GMSMutablePath *path = [[GMSMutablePath alloc] init];
      
      for (int i = 0; i < _polygon.path.count; i++) {
        [path addCoordinate:[_polygon.path coordinateAtIndex:i]];
        
        if (i == pos) {
          [path addCoordinate:weakMarker.coordinate];
        }
      }
      
      _polygon.path = path;
    } else {
      AIRGoogleMapMarker *lowerMidpointMarker;
      AIRGoogleMapMarker *upperMidpointMarker;
      if (pos > 0) {
        lowerMidpointMarker = [_midpointMarkers objectAtIndex:pos - 1];
        upperMidpointMarker = [_midpointMarkers objectAtIndex:pos];
      } else {
        lowerMidpointMarker = [_midpointMarkers objectAtIndex:0];
        upperMidpointMarker = [_midpointMarkers objectAtIndex:_midpointMarkers.count - 1];
      }
      lowerMidpointMarker.realMarker.opacity = 0;
      upperMidpointMarker.realMarker.opacity = 0;
    }
    
    if (_onEditStart) {
      _onEditStart([self eventFromVertex:e atPosition:vertexPosition isMidpoint:midpoint]);
    }
  };
}

-(void)setOnVertexDrag:(AIRGoogleMapMarker*)marker atPosition:(NSNumber*)vertexPosition isMidpoint:(BOOL)midpoint
{
  marker.onDrag = ^(NSDictionary *e) {
    long pos = [vertexPosition integerValue];
    
    if (midpoint) {
      pos++;
    }
    
    GMSMutablePath *path = [_polygon.path mutableCopy];
    double lat = [[e valueForKeyPath:@"coordinate.latitude"] doubleValue];
    double lng = [[e valueForKeyPath:@"coordinate.longitude"] doubleValue];
    [path replaceCoordinateAtIndex:pos withCoordinate:CLLocationCoordinate2DMake(lat, lng)];
    _polygon.path = path;
  };
}

-(void)setOnVertexDragEnd:(AIRGoogleMapMarker*)marker atPosition:(NSNumber*)vertexPosition isMidpoint:(BOOL)midpoint
{
  marker.onDragEnd = ^(NSDictionary *e) {
    if (_onEditEnd) {
      _onEditEnd([self eventFromVertex:e atPosition:vertexPosition isMidpoint:midpoint]);
    }
  };
}

-(NSDictionary*)eventFromVertex:(NSDictionary*)e atPosition:(NSNumber*)vertexPosition isMidpoint:(BOOL)midpoint
{
  NSMutableDictionary *mutableEvt = [e mutableCopy];
  mutableEvt[@"vertexPosition"] = vertexPosition;
  
  // add all current coords
  NSMutableArray<NSDictionary *> *coords = [NSMutableArray new];
  for (int i = 0; i < _coordinates.count; i++) {
    NSDictionary *coord = @{
                            @"latitude": [NSNumber numberWithDouble:_coordinates[i].coordinate.latitude],
                            @"longitude": [NSNumber numberWithDouble:_coordinates[i].coordinate.longitude],
                            };
    [coords addObject:coord];
  }
  
  long pos = [vertexPosition integerValue];
  if (midpoint) { // update midpoint coord
    AIRGoogleMapMarker *marker = (AIRGoogleMapMarker*)[_midpointMarkers objectAtIndex:pos];
    NSDictionary *coord = @{
                            @"latitude": [NSNumber numberWithDouble:marker.coordinate.latitude],
                            @"longitude": [NSNumber numberWithDouble:marker.coordinate.longitude],
                            };
    [coords insertObject:coord atIndex:pos + 1];
  } else {
    AIRGoogleMapMarker *marker = (AIRGoogleMapMarker*)[_markers objectAtIndex:pos];
    NSDictionary *coord = @{
                            @"latitude": [NSNumber numberWithDouble:marker.coordinate.latitude],
                            @"longitude": [NSNumber numberWithDouble:marker.coordinate.longitude],
                            };
    [coords replaceObjectAtIndex:pos withObject:coord];
  }
  
  mutableEvt[@"coordinates"] = coords;
  return mutableEvt;
}

-(AIRMapCoordinate*)calculateMidpointBetweenVertices:(AIRMapCoordinate*)a to:(AIRMapCoordinate*)b
{
  AIRMapCoordinate *airMapCoord = [[AIRMapCoordinate alloc] init];
  GMSMapPoint midpoint = GMSMapPointInterpolate(GMSProject(a.coordinate), GMSProject(b.coordinate), 0.5);
  airMapCoord.coordinate = GMSUnproject(midpoint);
  return airMapCoord;
}

@end
