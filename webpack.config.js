var webpack = require('webpack');
var Clean = require('clean-webpack-plugin');

module.exports = {
  entry: {
    all: './source/javascripts/all.js',
    vendor: ['jquery', 'fastclick', 'babel/polyfill']
  },

  resolve: {
    root: __dirname + '/source/javascripts',
  },

  output: {
    path: __dirname + '/.tmp/dist',
    filename: 'javascripts/[name].js',
  },

  module: {
    loaders: [
      {
        test: /source\/javascripts\/.*\.js$/,
        exclude: /node_modules|\.tmp|vendor/,
        loaders: ['babel?stage=0'],
      }
    ]
  },

  node: {
    console: true
  },

  plugins: [
    new webpack.optimize.CommonsChunkPlugin(/* chunkName= */'vendor', /* filename= */'javascripts/vendor.js', Infinity),
    new Clean(['.tmp']),
  ],
};
