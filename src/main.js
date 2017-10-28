'use strict';

// アプリケーションをコントロールするモジュール
var electron = require('electron');
var app = electron.app;
const Menu = electron.Menu;
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
  //メニュー
  initWindowMenu(); 

  //ウィンドウが閉じられたらアプリも終了
  mainWindow.on('closed', function() {
    mainWindow = null;
  });
  mainWindow.openDevTools();
});



function initWindowMenu(){
  const template = [
      {
          label: 'menu',
          submenu: [
              {
                  label: '開発者メニュー',
                  click () { mainWindow.openDevTools(); }
              }
          ]
      }
  ]

  const menu = Menu.buildFromTemplate(template)
  Menu.setApplicationMenu(menu)
}