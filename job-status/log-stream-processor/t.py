# import flask module
from flask import Flask
 
import prometheus_client as pclient
# instance of flask application
app = Flask(__name__)
 
# home route that returns below text
# when root url is accessed
@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"

pclient.start_http_server(9010)
if __name__ == '__main__':
    pclient.start_http_server(9010)
    #app.run(debug=True, port=8001)

