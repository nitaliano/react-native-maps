//
//  AirTile.m
//  Created by Nick Italiano on 11/6/16.
//

#import "AirTile.h"

@implementation AirTile

- (NSURL*)URLForTilePath:(MKTileOverlayPath)path
{
  NSString *url = _urlTemplate;

  // subdomains
  if ([self _hasSubdomains]) {
    url = [url stringByReplacingOccurrencesOfString:@"{s}" withString:[NSString stringWithFormat: @"%@", [self _getSubdomain:path]]];
  }

  // xyz
  url = [url stringByReplacingOccurrencesOfString:@"{x}" withString:[NSString stringWithFormat: @"%ld", (long)path.x]];
  url = [url stringByReplacingOccurrencesOfString:@"{y}" withString:[NSString stringWithFormat: @"%ld", (long)path.y]];
  url = [url stringByReplacingOccurrencesOfString:@"{z}" withString:[NSString stringWithFormat: @"%ld", (long)path.z]];

  return [NSURL URLWithString:url];
}

- (BOOL)_hasSubdomains
{
  return !(_subdomains == nil || _subdomains.count == 0);
}

- (NSString*)_getSubdomain:(MKTileOverlayPath)path
{
  int subdomainIndex = (int)ABS(path.x + path.y) % _subdomains.count;
  return _subdomains[subdomainIndex];
}

@end
