const request = require('request');
const fs = require('fs')

const options = {
   url: `https://[${process.argv[2]}]:443/`,
   ca: fs.readFileSync('rootCA.crt'),
   strictSSL: true,
};
request(options, function (error, response, body) {
    if (error) {
        console.log('error:', error.message); // Print the error if one occurred
    }
    console.log('statusCode:', response && response.statusCode); // Print the response status code if a response was received
    console.log('body:', body); // Print the HTML for the Google homepage.
});