#!/bin/bash

mongo router:27017/cloud << !

use cloud

function makeMessage(length) {
  var text = "";
  var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

  for (var i = 0; i < length; i++)
    text += possible.charAt(Math.floor(Math.random() * possible.length));

  return text;
}


var n = 1000000;
var p = n / 10;

for (var i = 1; i <= n; i++) {

  if (i % p == 0) {
    system.out.printf("step");
  }
  
  db.messages.insert( 
    { 
      _id : i,
      message: makeMessage(100) 
    } 
  ) 
}



!
