import sleep from 'k6';
import loki from 'k6/x/loki';

/**
 * URL used for push and query requests
 * Path is automatically appended by the client
 * @constant {string}
 */
const BASE_URL = `http://loki:3100`; 
/** const BASE_URL = `http://grafan1.local:3100`; **/

/**
 * Client timeout for read and write in milliseconds
 * @constant {number}
 */
const timeout = 5000;

/**
 * Ratio between Protobuf and JSON encoded payloads when pushing logs to Loki
 * @constant {number}
 */
const ratio = 0.5;

/**
 * Cardinality for labels
 * @constant {object}
 */
const cardinality = {
  "app": 10,
  "namespace": 5
};

/**
 * Execution options
 */
export const options = {
  vus: 10,
  iterations: 10,
};

/**
 * Create configuration object
 */
const conf = new loki.Config(BASE_URL, timeout, ratio, cardinality);

/**
 * Create Loki client
 */
const client = new loki.Client(conf);

export default () => {
  // Push a batch of 2 streams with a payload size between 500KB and 1MB
  let res = client.pushParameterized(2, 512 * 1024, 1024 * 1024);
  // A successful push request returns HTTP status 204
  check(res, { 'successful write': (res) => res.status == 204 });
  sleep(1);
}
