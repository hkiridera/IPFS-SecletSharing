'use strict';

// アプリケーションをコントロールするモジュール
var electron = require('electron');
var app = electron.app;
var BrowserWindow = electron.BrowserWindow;

// メインウィンドウはGCされないようにグローバル宣言
let mainWindow;

// 全てのウィンドウが閉じたら終了
app.on('window-all-closed', function() {
  if (process.platform != 'darwin') {
    app.quit();
  }
});

// Electronの初期化完了後に実行
app.on('ready', function() {
  // メイン画面の表示
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 900,
    webPreferences: {
      nodeIntegration: false
    }
  });
  mainWindow.loadURL('file://' + __dirname + '/html/download.html');
  // APIサーバー起動
  var subpy = require('child_process').spawn('python',['./api.py']);

  //ウィンドウが閉じられたらアプリも終了
  mainWindow.on('closed', function() {
    mainWindow = null;
  });
  mainWindow.openDevTools();
});