'use strict';
var mysql = require('promise-mysql');

var connection, tinpon, productVariations, tinponId;
let host = "wegoloco-cluster.cluster-cb5jwvcwolur.eu-west-1.rds.amazonaws.com";
let user = "admin";
let password = "1269Y5$ST50j";
let database = 'wegoloco';
let charset = 'utf8mb4';
// git test
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

exports.handler = (event, context, callback) =>  {
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
  console.log("Path params : ", pathParams);
    switch (httpMethod) {
      case "GET":
        console.log("GET case");
        mysql.createConnection({
            host: host,
            user: user,
            password: password,
            database: database,
            charset: charset
        })
        .then( function(conn) {
          connection = conn;
            //const person_id = 'eu-west-1:b1630ba6-92ac-4d29-8338-eb04b24eb3b4';
            const person_id = cognitoIdentityId;
            var query = connection.query("SELECT * FROM tinpon WHERE NOT EXISTS (SELECT * FROM tinpon_swiped WHERE tinpon_swiped.person_id = '"+person_id+"' AND tinpon_swiped.tinpon_id = tinpon.id) LIMIT 10;");
            // could exclude ids like : AND ID NOT IN ('1', '2', '3', '4', '5', '6', '7', '8', '9', '10')
          return query;
        })
        .then( function(rows) {
          connection.end()
          respond(context, 200, JSON.stringify(rows));
        })
      break;
      case "POST":
        console.log(requestBody);

        var swipedTinpon = JSON.parse(requestBody);
        swipedTinpon["person_id"] = cognitoIdentityId

        mysql.createConnection({
            host: host,
            user: user,
            password: password,
            database: database,
            charset: charset
        }).then(function(conn){
          connection = conn

          var query = connection.query("INSERT INTO tinpon_swiped SET ?", swipedTinpon);
        }).then( function(result) {
          connection.end()
          respond(context, 200, "SUCCESS: saved swipe");
        }).catch( function(error) {
          respond(context, 500, error );
        });
        break;
      default :
        respond(context, 500, "Not a valid HTTP Mehthd called : ", httpMethod);
  }
};
