import React, { PropTypes } from 'react';

import {
  View,
} from 'react-native';

import decorateMapComponent, {
  USES_DEFAULT_IMPLEMENTATION,
  SUPPORTED,
} from './decorateMapComponent';

const propTypes = {
  ...View.propTypes,

  /**
   * The url template of the tile server. The patterns {s} {x} {y} {z} will be replaced at runtime
   * For example, http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png
   */
  urlTemplate: PropTypes.string.isRequired,

  /**
   * The order in which this tile overlay is drawn with respect to other overlays. An overlay
   * with a larger z-index is drawn over overlays with smaller z-indices. The order of overlays
   * with the same z-index is arbitrary. The default zIndex is -1.
   *
   * @platform android
   */
  zIndex: PropTypes.number,

  /**
   * The subdomains to be used as {s} in urlTemplate
   *
   */
  subdomains: PropTypes.array,
};

class MapUrlTile extends React.Component {
  render() {
    const AIRMapUrlTile = this.getAirComponent();
    return (
      <AIRMapUrlTile
        {...this.props}
      />
    );
  }
}

MapUrlTile.propTypes = propTypes;

module.exports = decorateMapComponent(MapUrlTile, {
  componentType: 'UrlTile',
  providers: {
    google: {
      ios: SUPPORTED,
      android: USES_DEFAULT_IMPLEMENTATION,
    },
  },
});
