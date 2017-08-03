'use strict';
var mysql = require('mysql');

var connection = mysql.createConnection({
  host: "wegoloco-cluster.cluster-cb5jwvcwolur.eu-west-1.rds.amazonaws.com",
  user: "admin",
  password: "1269Y5$ST50j",
  database : 'wegoloco'
});

connection.connect(function(err) {
  console.log("inside Connect");
});

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

      connection.query("SELECT * FROM person "
                      +"WHERE id = 'test';"
                      , function (error, results, fields) {
        if (error) {
          console.log("Error : ", error);
          respond(context, 503, "Something went wrong with the QUERY");
        } else {
          console.log("GET person success : ", results);
          respond(context, 200, JSON.stringify(results));
        }

        // connection.end();
      });
      break;
    default:
      respond(context, 403, httpMethod+" is not an allowed HTTP method.")
  }
};
