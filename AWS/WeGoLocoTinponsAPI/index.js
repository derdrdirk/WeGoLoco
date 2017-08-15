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
  switch(pathParams) {
    case "/tinpons" :
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

            var query = connection.query("SELECT * FROM tinpon");
            return query;
          })
          .then( function(rows) {
            respond(context, 200, JSON.stringify(rows));
          })
        break;
        case "POST":
          console.log("POST case");

          console.log(requestBody);
          tinpon = JSON.parse(requestBody);
          productVariations = tinpon.productVariations;
          delete tinpon.productVariations;



          mysql.createConnection({
              host: host,
              user: user,
              password: password,
              database: database,
              charset: charset
          }).then(function(conn){
              // insert Tinpon
              connection = conn;

              var query = connection.query("INSERT INTO tinpon SET ?", tinpon);
              console.log("SQL QUERY : ", query.sql);
              return query;
          }).then( function(result) {
            // insert product Variations
            tinponId = result.insertId;

            var values = "";
            for (var color in productVariations) {
              for (var sizeVariation of productVariations[color].sizeVariation) {
                let size = sizeVariation.size
                let quantity = sizeVariation.quantity

                values = values.concat("('"+tinponId+"', '"+color+"', '"+size+"', '"+quantity+"'),");
              }
            }

            if (values != "") {
              values = values.slice(0, -1);

              var query = connection.query("INSERT INTO tinpon_variation(tinpon_id, color, size, quantity)"
                          +"VALUES "+values+";");
              return query;
            } else {
                connection.end();
                respond(context, 200, 'Success: Created Tinpon WITHOUT variations?.');
            }



          }).then(function(result) {

            var jsonResponse = {}
            jsonResponse.tinponId = tinponId;

            connection.end();
            respond(context, 200, JSON.stringify(jsonResponse));
          });
          // .then(function(rows) {
          //   if (rows.length > 0) {
          //     // User exists
          //     connection.end();
          //     respond(context, 405, "Error: User already exists");
          //   } else {
          //     var result = connection.query("INSERT INTO person SET ?", person);
          //     return result;
          //   }
          // }).then(function(result) {
          //   // insert categories
          //
          //   var values = "";
          //   for (var category of categories) {
          //     values = values.concat("('"+category+"', '"+cognitoIdentityId+"'),");
          //   }
          //   if (values != "") {
          //     values = values.slice(0, -1);
          //
          //     var query = connection.query("INSERT INTO person_category(category_id, person_id)"
          //                 +"VALUES "+values+";");
          //     return query;
          //   } else {
          //       connection.end();
          //       respond(context, 200, 'Success: Created User.');
          //   }
          // }).then(function(result) {
          //   connection.end();
          //   respond(context, 200, 'Success: Created User.');
          // }).catch(function(error) {
          //   console.log("ERROR : ", error);
          // });
          break;
        }
        break;
    default :
      respond(context, 500, "Not a valid resoucrce called");
  }
};
