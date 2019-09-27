const path = require("path");
const webpack = require("webpack");
const merge = require("webpack-merge");
const elmMinify = require("elm-minify");

const CopyWebpackPlugin = require("copy-webpack-plugin");
const HTMLWebpackPlugin = require("html-webpack-plugin");
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
// to extract the css as a separate file
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

const MODE =
  process.env.npm_lifecycle_event === "prod" ? "production" : "development";
const withDebug = !process.env["npm_config_nodebug"];
// this may help for Yarn users
// var withDebug = !npmParams.includes("--nodebug");
console.log('\x1b[36m%s\x1b[0m', `** elm-webpack-starter: mode "${MODE}", withDebug: ${withDebug}\n`);

const common = {
  mode: MODE,
  entry: "./src/static/index.js",
  output: {
    path: path.join(__dirname, "build/webpack"),
    // publicPath: "/",
    filename: path.join('static/js/', MODE === "production" ? "[name]-[hash].js" : "[name].js")
  },
  plugins: [
    new HTMLWebpackPlugin({
      // Use this template to get basic responsive meta tags
      template: "src/static/index.html",
      // inject details of output file at end of body
      inject: "body"
    })
  ],
  resolve: {
    modules: [path.join(__dirname, "src/static"), "node_modules"],
    extensions: [".js", ".elm", ".scss", ".png"]
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader"
        }
      },
      {
        test: /\.scss$/,
        exclude: [/elm-stuff/, /node_modules/],
        // see https://github.com/webpack-contrib/css-loader#url
        loaders: ["style-loader", "css-loader?url=false", "sass-loader"]
      },
      {
        test: /\.css$/,
        exclude: [/elm-stuff/, /node_modules/],
        loaders: ["style-loader", "css-loader?url=false"]
      },
      {
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: "url-loader",
        options: {
          limit: 10000,
          mimetype: "application/font-woff"
        }
      },
      {
        test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: "file-loader"
      },
      {
        test: /\.(jpe?g|png|gif|svg)$/i,
        exclude: [/elm-stuff/, /node_modules/],
        loader: "file-loader"
      }
    ]
  }
};

if (MODE === "development") {
  module.exports = merge(common, {
    plugins: [
      // Suggested for hot-loading
      new webpack.NamedModulesPlugin(),
      // Prevents compilation errors causing the hot loader to lose state
      new webpack.NoEmitOnErrorsPlugin()
    ],
    module: {
      rules: [
        {
          test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          use: [
            { loader: "elm-hot-webpack-loader" },
            {
              loader: "elm-webpack-loader",
              options: {
                // add Elm's debug overlay to output
                debug: withDebug,
                //
                forceWatch: true
              }
            }
          ]
        }
      ]
    },
    devServer: {
      inline: true,
      stats: "errors-only",
      contentBase: path.join(__dirname, "src/static"),
      historyApiFallback: true,
      // feel free to delete this section if you don't need anything like this
      before(app) {
        // on port 3000
        app.get("/test", function(req, res) {
          res.json({ result: "OK" });
        });
      }
    }
  });
}
if (MODE === "production") {
  module.exports = merge(common, {
    plugins: [
      // Delete everything from output-path (/dist) and report to user
      new CleanWebpackPlugin({
        root: __dirname,
        exclude: [],
        verbose: true,
        dry: false
      }),
      // Minify elm code
      new elmMinify.WebpackPlugin(),
      // Copy static assets
      new CopyWebpackPlugin([
        {
          from: "src/static/api/",
          to: "static/api/"
        }
      ]),
      new MiniCssExtractPlugin({
        // Options similar to the same options in webpackOptions.output
        // both options are optional
        filename: "[name]-[hash].css"
      })
    ],
    module: {
      rules: [
        {
          test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          use: {
            loader: "elm-webpack-loader",
            options: {
              optimize: true
            }
          }
        },
        // {
        //   test: /\.css$/,
        //   exclude: [/elm-stuff/, /node_modules/],
        //   loaders: [
        //     MiniCssExtractPlugin.loader,
        //     "css-loader?url=false"
        //   ]
        // },
        {
          test: /\.scss$/,
          exclude: [/elm-stuff/, /node_modules/],
          loaders: [
            MiniCssExtractPlugin.loader,
            "css-loader?url=false",
            "sass-loader"
          ]
        }
      ]
    }
  });
}
