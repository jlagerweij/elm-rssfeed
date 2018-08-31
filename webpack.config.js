const path = require('path');
const merge = require('webpack-merge');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const CopyWebpackPlugin = require('copy-webpack-plugin');
const entryPath = path.join(__dirname, 'src/static/index.js');
const outputPath = path.join(__dirname, 'build/web');

// determine build env
const TARGET_ENV = process.env.npm_lifecycle_event === 'build' ? 'production' : 'development';
const outputFilename = TARGET_ENV === 'production' ? '[name].js' : '[name].js';

console.log('WEBPACK GO! (' + TARGET_ENV + ')');

// common webpack config
const commonConfig = {
  output : {
    path : outputPath,
    filename : path.join('static/js/', outputFilename)
  },

  resolve : {
    extensions : ['.js', '.elm']
  },

  plugins : [
    new HtmlWebpackPlugin({
      template : 'src/static/index.html',
      inject : 'body',
      filename : 'index.html'
    })
  ]
};

// additional webpack settings for local env (when invoked by 'npm start')
if (TARGET_ENV === 'development') {
  console.log('Serving locally...');

  module.exports = merge(commonConfig, {

    entry : [
      'webpack-dev-server/client?http://localhost:8080',
      entryPath
    ],

    devServer : {
      inline : true,
      hot : true,
      stats : 'errors-only',
      // serve index.html in place of 404 responses
      historyApiFallback : true,
      contentBase : './src/static'
    },

    module : {
      rules : [
        {
          test : /\.elm$/,
          exclude : [/elm-stuff/, /node_modules/],
          use : [
            {loader : 'elm-hot-webpack-loader'},
            {
              loader : 'elm-webpack-loader',
              options : {
                cwd : __dirname,
                verbose : true,
                debug : true
              }
            }
          ]
        },
        {
          test : /\.(css)$/,
          use : [
            {loader : 'style-loader'},
            {loader : 'css-loader', options : {importLoaders : 1}}
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

    entry : entryPath,

    module : {
      rules : [
        {
          test : /\.elm$/,
          exclude : [/elm-stuff/, /node_modules/],
          use : 'elm-webpack-loader'
        },
        {
          test : /\.(css)$/,
          use : [
            {
              loader : MiniCssExtractPlugin.loader,
              options : {
                // you can specify a publicPath here
                // by default it use publicPath in webpackOptions.output
                publicPath : '../'
              }
            },
            {loader : 'css-loader'}
          ]
        }
      ]
    },

    plugins : [
      new CopyWebpackPlugin([
        {
          from : 'src/static/api/',
          to : 'static/api/'
        }
      ]),

      //   new webpack.optimize.OccurenceOrderPlugin(),

      // extract CSS into a separate file
      new MiniCssExtractPlugin({
        // Options similar to the same options in webpackOptions.output
        // both options are optional
        filename : "static/css/[name].[hash].css",
        chunkFilename : "[id].[hash].css"
      })

      // minify & mangle JS/CSS
      // new webpack.optimize.UglifyJsPlugin({
      //   minimize: true,
      //   compressor: {
      //     warnings: false
      //   }
      // })
    ]

  });
}
