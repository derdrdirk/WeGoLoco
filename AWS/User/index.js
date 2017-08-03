'use strict';
//var mysql = require('mysql');
var mysql = require('promise-mysql');

var connection;
let host = "wegoloco-cluster.cluster-cb5jwvcwolur.eu-west-1.rds.amazonaws.com";
let user = "admin";
let password = "1269Y5$ST50j";
let database = 'wegoloco';

// var connection = mysql.createConnection({
//   host: "wegoloco-cluster.cluster-cb5jwvcwolur.eu-west-1.rds.amazonaws.com",
//   user: "admin",
//   password: "1269Y5$ST50j",
//   database : 'wegoloco'
// });
//
// connection.connect(function(err) {
//   console.log("inside Connect");
// });

function respond(context, statusCode, body) {
  let response = {
      statusCode: statusCode,
      headers: {
          "x-custom-header" : "custom header value"
      },
      body: body
  };

  context.succeed(response);
}

function isEmpty(obj) {
    for(var prop in obj) {
        if(obj.hasOwnProperty(prop))
            return false;
    }

    return JSON.stringify(obj) === JSON.stringify({});
}

exports.handler = (event, context, callback) => {
  console.log("Lambda started");

  // init params
  /////////////////////////////////////////////////////////////////////////////
  var requestBody, pathParams, queryStringParams, headerParams, stage,
  stageVariables, cognitoIdentityId, httpMethod, sourceIp, userAgent,
  requestId, resourcePath;
  console.log("Request: " + JSON.stringify(event));

  // Request Body
  requestBody = event.body;

  // Path Parameters
  pathParams = event.path;

  // Query String Parameters
  queryStringParams = event.queryStringParameters;

  // Header Parameters
  headerParams = event.headers;

  if (event.requestContext !== null && event.requestContext !== undefined) {

      var requestContext = event.requestContext;

      // API Gateway Stage
      stage = requestContext.stage;

      // Unique Request ID
      requestId = requestContext.requestId;

      // Resource Path
      resourcePath = requestContext.resourcePath;

      var identity = requestContext.identity;

      // Amazon Cognito User Identity
      cognitoIdentityId = identity.cognitoIdentityId;

      // Source IP
      sourceIp = identity.sourceIp;

      // User-Agent
      userAgent = identity.userAgent;
  }

  // API Gateway Stage Variables
  stageVariables = event.stageVariables;

  // HTTP Method (e.g., POST, GET, HEAD)
  httpMethod = event.httpMethod;

  // end init params
  /////////////////////////////////////////////////////////////////////////////

  console.log("HTTP method : ",httpMethod);
  switch (httpMethod) {
    case "GET":
      // get signedIn User
      console.log("CognitoId : ", cognitoIdentityId);

      mysql.createConnection({
          host: host,
          user: user,
          password: password,
          database: database
      }).then(function(conn){
          connection = conn;
          var result = conn.query("SELECT * FROM person "
                                  +"WHERE id = '"+cognitoIdentityId+"';");
          return result;
      }).then(function(rows) {
          let result = JSON.stringify(rows[0]);
          console.log("Success: User ", result);
          respond(context, 200, result);
      });
      break;
    case "POST":
      mysql.createConnection({
          host: host,
          user: user,
          password: password,
          database: database
      }).then(function(conn){
          connection = conn;
          var result = conn.query("SELECT * FROM person "
                                  +"WHERE id = '"+cognitoIdentityId+"';");
          return result;
      }).then(function(rows) {
        var user = JSON.parse(requestBody);
        user.id = "niceOne";
        // user["email"] = (user.hasOwnProperty("email") ? "'"+user["email"]+"'" : "NULL");
        // user["birthdate"] = (user.hasOwnProperty("birthdate") ? "'"+user["birthdate"]+"'" : "NULL");
        // user["gender"] = (user.hasOwnProperty("gender") ? "'"+user["gender"]+"'" : "NULL");

        if (rows.length > 0) {
          // User exists
          connection.end();
          respond(context, 405, "Error: User already exists");
        } else {
          var result = connection.query("INSERT INTO person SET ?", user);
          return result;
        }
      }).then(function(result) {
        connection.end();
        respond(context, 400, 'Success: Created User.');
      });
      break;
      case "PUT":
        mysql.createConnection({
            host: host,
            user: user,
            password: password,
            database: database
        }).then(function(conn){
            connection = conn;
            var result = conn.query("SELECT * FROM person "
                                    +"WHERE id = '"+cognitoIdentityId+"';");
            return result;
        }).then(function(rows) {
          console.log(JSON.parse(requestBody).email);

          var user = JSON.parse(requestBody);

          if (rows.length == 0) {
            // User does not exists
            connection.end();
            respond(context, 405, "Error: User does not exist");
          } else {
            var result = connection.query("UPDATE person "
                                    +"SET ? WHERE `id` = '"+cognitoIdentityId+"';", user);
            return result;
          }
        }).then(function(result) {
          connection.end();
          respond(context, 400, 'Success: Updated User.');
        });
        break;
    default:
      respond(context, 403, httpMethod+" is not an allowed HTTP method.")
  }
};
