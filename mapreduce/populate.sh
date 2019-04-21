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


for (var i = 1; i <= 1000000; i++) {    
  db.messages.insert( 
    { 
      _id : i,
      message: makeMessage(100) 
    } 
  ) 
}



!
