var http = require('http');
var MongoClient = require('mongodb').MongoClient;
var url = "mongodb://admin:MA3Z9uhLK44Z@ec2-52-213-254-143.eu-west-1.compute.amazonaws.com";

MongoClient.connecmv t(url, function(err, db) {
  if (err) throw err;
  var query = { address: "Park Lane 38" };
  db.collection("customers").find(query).toArray(function(err, result) {
    if (err) throw err;
    console.log(result);
    db.close();
  });
});
