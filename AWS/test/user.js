exports.handler = (event, context, callback) => {

  var mysql = require('mysql');

  var con = mysql.createConnection({
    host: "wegoloco-cluster-1.cluster-cb5jwvcwolur.eu-west-1.rds.amazonaws.com",
    user: "admin",
    password: "6626@OQ6PX!c"
  });

  con.connect(function(err) {
    if (err) throw err;
    console.log("Connected!");
  });

};
