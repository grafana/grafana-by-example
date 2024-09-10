// Example AWS Lambda function to ingest Kinesis records and write to Grafana Cloud Logs
// 
/
const https = require("https");

const lokiHost = process.env.GRAFANA_LOGS_HOST;
const lokiUser = process.env.GRAFANA_LOGS_USERNAME;
const lokiPwd = process.env.GRAFANA_LOGS_API_KEY;
const lokiAuth = "Basic " + Buffer.from(`${lokiUser}:${lokiPwd}`).toString("base64");

const postLoki = (logLabels, logMsg) => new Promise((resolve, reject) => {
  const nowSec = Math.floor(Date.now());
  const nowNs = `${nowSec}000000`;
  const dataJson = { streams: [ { stream: logLabels, values: [ [ nowNs, logMsg ] ] } ] };
  const dataStr = JSON.stringify(dataJson);
  console.log(`Loki ${dataStr}`);
  const postOptions = {
      hostname: lokiHost,
      port: 443,
      path: '/loki/api/v1/push',
      method: 'POST',
      headers: {
          'Content-Type': 'application/json',
          'Content-Length': dataStr.length,
          'Authorization': lokiAuth,
      },
  }
  
  const request = https.request(postOptions, (response) => {
      let data = '';
    
      response.on('data', (chunk) => {
        data += chunk.toString();
      });
    
      response.on('end', () => {
        console.log(`Status code: ${response.statusCode}`);
      });
    
      response.on('error', (error) => {
        throw error;
      });
  });

  request.write(dataStr);
  request.end();
});

exports.handler = async (event, context) => {
  for (const record of event.Records) {
    try {
      console.log(`Processed Kinesis Event - EventID: ${record.eventID}`);
      const recordData = await getRecordDataAsync(record.kinesis);
      console.log(`Record Data: ${recordData}`);

      // Post record to Grafana Cloud Logs  
      await postLoki( { job: "kinesis2" }, recordData );

    } catch (err) {
      console.error(`Error with record or post ${err}`);
      throw err;
    }
  }
  console.log(`Processed ${event.Records.length} records.`);
};

async function getRecordDataAsync(payload) {
  var data = Buffer.from(payload.data, "base64").toString("utf-8");
  await Promise.resolve(1);
  return data;
}


