var path = require('path');
var webpack = require('webpack');
var merge = require('webpack-merge');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var ExtractTextPlugin = require('extract-text-webpack-plugin');
var CopyWebpackPlugin = require('copy-webpack-plugin');
var entryPath = path.join(__dirname, 'src/static/index.js');
var outputPath = path.join(__dirname, 'build/web');

console.log('WEBPACK GO!');

// determine build env
var TARGET_ENV = process.env.npm_lifecycle_event === 'build' ? 'production' : 'development';
var outputFilename = TARGET_ENV === 'production' ? '[name].js' : '[name].js';

// common webpack config
var commonConfig = {

  output: {
    path: outputPath,
    filename: path.join('static/js/', outputFilename),
    // publicPath: '/'
  },

  resolve: {
    extensions: ['.js', '.elm']
  },

  module: {
    rules: [{
        test: /\.(eot|ttf|woff|woff2|svg)$/,
        use: 'file-loader'
      },
      {
        test: /\.(json)$/,
        use: "file-loader?name=api/[name].[ext]"
      },
      {
        test: /Styling\/.*\.(elm)$/,
        use: [
          "style-loader",
          "css-loader",
          "elm-css-webpack-loader"
        ]
      }
    ]
  },

  plugins: [
    new HtmlWebpackPlugin({
      template: 'src/static/index.html',
      inject: 'body',
      filename: 'index.html'
    }),
  ],
};

// additional webpack settings for local env (when invoked by 'npm start')
if (TARGET_ENV === 'development') {
  console.log('Serving locally...');

  module.exports = merge(commonConfig, {

    entry: [
      'webpack-dev-server/client?http://localhost:8080',
      entryPath
    ],

    devServer: {
      // serve index.html in place of 404 responses
      historyApiFallback: true,
      contentBase: './src',
    },

    module: {
      rules: [{
          test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          use: [
            "elm-hot-loader",
            "elm-webpack-loader?verbose=true&warn=true&debug=true"
          ]
        },
        {
          test: /\.(css|scss)$/,
          use: [
            'style-loader',
            { loader: 'css-loader', options: { importLoaders: 1 } },
            'postcss-loader',
            'sass-loader'
          ]
        }
      ]
    }

  });
}

// additional webpack settings for prod env (when invoked via 'npm run build')
if (TARGET_ENV === 'production') {
  console.log('Building for prod...');

  module.exports = merge(commonConfig, {

    entry: entryPath,

    module: {
      rules: [{
          test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          use: 'elm-webpack-loader'
        },
        {
          test: /\.(css|scss)$/,
          use: ExtractTextPlugin.extract({
            fallback: 'style-loader',
            use: [
              'css-loader',
              'postcss-loader',
              'sass-loader'
            ]
          })
        }
      ]
    },

    plugins: [
      new CopyWebpackPlugin([
        {
          from: 'src/static/api/',
          to: 'static/api/'
        },
      ]),

    //   new webpack.optimize.OccurenceOrderPlugin(),

      // extract CSS into a separate file
      new ExtractTextPlugin('static/css/[name]-[hash].css'),

      // minify & mangle JS/CSS
      new webpack.optimize.UglifyJsPlugin({
        minimize: true,
        compressor: {
          warnings: false
        }
        // mangle:  true
      })
    ]

  });
}
