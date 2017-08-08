'use strict';
//var mysql = require('mysql');
var mysql = require('promise-mysql');

var connection, person, categories;
let host = "wegoloco-cluster.cluster-cb5jwvcwolur.eu-west-1.rds.amazonaws.com";
let user = "admin";
let password = "1269Y5$ST50j";
let database = 'wegoloco';
let charset = 'utf8mb4';

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
  console.log("Path params : ", pathParams);
  switch(pathParams) {
    case "/users" :
      switch (httpMethod) {
        case "GET":
          // get signedIn User
          console.log("CognitoId : ", cognitoIdentityId);
          console.log("queryStringParams : ", queryStringParams);

          //let id = queryStringParams.id;
          //let id = 'eu-west-1:328d76e7-e18e-4e8a-a5f4-a711e19c058d';
          let id = cognitoIdentityId

          mysql.createConnection({
              host: host,
              user: user,
              password: password,
              database: database,
              charset: charset
          }).then(function(conn){
              connection = conn;
              var result = conn.query("SELECT * FROM person "
                                      +"WHERE id = '"+id+"';");
              return result;
          }).then(function(rows) {
            person = rows[0];
            var query = connection.query("SELECT category_id FROM person_category WHERE person_id = '"+id+"';");
            return query
          }).then(function(rows) {
            console.log("rows : ", rows);
              categories = rows;
              person["categories"] = [];

              person["categories"] = [];
              for (var category of categories) {
                person["categories"].push(category["category_id"])
              }



              console.log("Success: User ", JSON.stringify(person));
              respond(context, 200, JSON.stringify(person));
          });
          break;
        case "POST":
          console.log("POST case");
          person = JSON.parse(requestBody);
          person.id = cognitoIdentityId
          console.log("Person : ", person);
          categories = person.categories;
          delete person.categories;


          mysql.createConnection({
              host: host,
              user: user,
              password: password,
              database: database,
              charset: charset
          }).then(function(conn){
              // insert User
              connection = conn;

              var query = connection.query("SELECT * FROM person "
                                      +"WHERE id = '"+cognitoIdentityId+"';");
              console.log("SQL QUERY : ", query.sql);
              return query;
          }).then(function(rows) {
            if (rows.length > 0) {
              // User exists
              connection.end();
              respond(context, 405, "Error: User already exists");
            } else {
              var result = connection.query("INSERT INTO person SET ?", person);
              return result;
            }
          }).then(function(result) {
            // insert categories

            var values = "";
            for (var category of categories) {
              values = values.concat("('"+category+"', '"+cognitoIdentityId+"'),");
            }
            if (values != "") {
              values = values.slice(0, -1);

              var query = connection.query("INSERT INTO person_category(category_id, person_id)"
                          +"VALUES "+values+";");
              return query;
            } else {
                connection.end();
                respond(context, 200, 'Success: Created User.');
            }
          }).then(function(result) {
            connection.end();
            respond(context, 200, 'Success: Created User.');
          }).catch(function(error) {
            console.log("ERROR : ", error);
          });
          break;
          case "PUT":
            person = JSON.parse(requestBody);
            person.id = cognitoIdentityId
            console.log("Person : ", person);
            categories = person.categories;
            delete person.categories;


            mysql.createConnection({
                host: host,
                user: user,
                password: password,
                database: database,
                charset: charset
            }).then(function(conn){
                connection = conn;

                var query = connection.query("SELECT * FROM person "
                                        +"WHERE id = '"+cognitoIdentityId+"';");
                return query;
            }).then(function(rows) {
              console.log(JSON.parse(requestBody).gender)

              if (rows.length === 0) {
                // User does not exists
                connection.end();
                respond(context, 405, "Error: User does not exist");
              } else {
                var result = connection.query("UPDATE person "
                                        +"SET ? WHERE `id` = '"+cognitoIdentityId+"';", person);
                return result;
              }
            }).then(function(result) {
              // delete previous categories
              var query = connection.query("DELETE FROM person_category WHERE person_id = '"+cognitoIdentityId+"';");
              return query;
            }).then(function(result) {
              // update categories
              console.log("Categories : ", person.categories);
              var values = "";
              for (var category of categories) {
                values = values.concat("('"+category+"', '"+cognitoIdentityId+"'),");
              }
              console.log("VALUES :", values);
              if (values != "") {
                values = values.slice(0, -1);
                console.log("VALUES2 :", values);
                var query = connection.query("INSERT INTO person_category (category_id, person_id) VALUES "+values+";");

                console.log("SQL QUERY : ", query.sql);
                return query;
              } else {
                  connection.end();
                  respond(context, 200, 'Success: Updated User.');
              }
            }).then(function(result) {
              connection.end();
              respond(context, 200, 'Success: Updated User.');
            }).catch(function(error) {
              if (connection && connection.end) connection.end();
              console.log("PUT User Error : ", error);
            });
            break;
        default:
          respond(context, 403, httpMethod+" is not an allowed HTTP method.")
      }
      break;
    case "/users/is-email-available" :
      let email = JSON.parse(requestBody).email;

      mysql.createConnection({
          host: host,
          user: user,
          password: password,
          database: database,
          charset: charset
      }).then(function(conn){
          connection = conn;


          var query = conn.query("SELECT * FROM person "
                                  +"WHERE email = '"+email+"';");
          return query;
      }).then(function(rows) {
        if(rows.length > 0) {
          respond(context, 200, "false");
        } else {
          respond(context, 200, "true");
        }
      })
      break;
    default :
      respond(context, 500, "Not a valid resoucrce called");
    }
}
