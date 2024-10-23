import csv, json, sys, os
import requests
from datetime import datetime, timedelta

def getEnvironmentConfig():
    return { "GRAFANA_CLOUD_STACK_HOST": os.environ.get('GRAFANA_CLOUD_STACK_HOST', 'None'),
            "GRAFANA_CLOUD_STACK_API_KEY": os.environ.get('GRAFANA_CLOUD_STACK_API_KEY', 'None'),
            "QUERY_URL": os.environ.get('GRAFANA_METRICS_QUERY_URL', 'None'),
             "USER": os.environ.get('GRAFANA_METRICS_USERNAME', 'None'),
             "API_KEY": os.environ.get('GRAFANA_METRICS_API_KEY', 'None'),
             "METICS_HOST": os.environ.get('GRAFANA_METRICS_HOST', 'None'),
             "HTTP_PROTOCOL": os.environ.get('GRAFANA_HTTP_PROTOCOL', 'https'),
             "QUERY_API_PATH": os.environ.get('GRAFANA_METRICS_QUERY_PATH', 'api/prom/api/v1'),
             "SQLITE_DB_FILE": os.environ.get('GRAFANA_SQLITE_DB_PATH', './data/test.sqlite'),
             "keyLength": int( os.environ.get('KEY_LENGTH', 8)),
             "iterations": int( os.environ.get('N_ITERATIONS', 8)) }

def stackQueryURL(c, apiPath):
    return "{p}://{h}/{a}".format( 
        p=c["HTTP_PROTOCOL"], h=c["GRAFANA_CLOUD_STACK_HOST"], a=apiPath)

def grafanaQueryURL(c, apiPath):
    return "{p}://{u}:{k}@{h}/{q}/{a}".format( 
        p=c["HTTP_PROTOCOL"],  u=c['USER'], k=c["API_KEY"],
        h=c["METICS_HOST"], q=c["QUERY_API_PATH"], a=apiPath)

def queryFolders(c):
    q = stackQueryURL( c, "/api/folders" )
    headers = { "Accept": "application/json",
               "Content-Type": "application/json",
               "Authorization": "Bearer {}".format(c["GRAFANA_CLOUD_STACK_API_KEY"]) }
    r = requests.get(q, headers=headers)
    j1 = json.loads( r.content )
    return j1 # Array of fodlers objects

def queryFolderByTitle(c, folderTitle):
    j = queryFolders(c)
    fl = [ i for i in j if i['title'] == folderTitle ]
    return fl[0] # return only first


def queryDashboards(c, searchTerm="%"):
    q = stackQueryURL( c, "api/search" )
    print( q )
    headers = { "Accept": "application/json",
               "Content-Type": "application/json",
               "Authorization": "Bearer {}".format(c["GRAFANA_CLOUD_STACK_API_KEY"]) }
    data = { "query": searchTerm }
    r = requests.get(q, headers=headers, params=data)
    #print( r.content )
    j1 = json.loads( r.content )
    return j1 # Array of dashboard objects

def getDashboardFromUid(c, dashboardUid ):
    q = stackQueryURL( c, "api/dashboards/uid/{}".format( dashboardUid ) )
    print( q )
    headers = { "Accept": "application/json",
               "Content-Type": "application/json",
               "Authorization": "Bearer {}".format(c["GRAFANA_CLOUD_STACK_API_KEY"]) }
    r = requests.get(q, headers=headers)
    j1 = json.loads( r.content )
    return j1

def updateDashboard(c, newDashboard ):
    q = stackQueryURL( c, "api/dashboards/db" )
    headers = { "Accept": "application/json",
               "Content-Type": "application/json",
               "Authorization": "Bearer {}".format(c["GRAFANA_CLOUD_STACK_API_KEY"]) }
    r = requests.post(q, headers=headers, data=json.dumps( newDashboard ) ) 
    print( r )
    print( r.content )

envConfig = getEnvironmentConfig()

cmd = sys.argv[1] if len(sys.argv) > 1 else "unknown command"

config = {
    "startAfterHeader": "Use Case #",
    "stopOnHeader": "Use Case #",
    "convert": False,
    "headers": [],
    "lineCount": 0,
    "convertColumns": [ 'Use Case #', 'Name', 'Description', 'Evaluation Criteria', 'Value', 'Status', 'Resources' ],
    "covertColumnsIndex": [],
    "makeLinks": [ 'Resources' ],
    "color": { 'Use Case #': { 'nnn': 'blue', 'aaa': 'greeen' },
                'Status': { 'Complete': 'green', 'Review': 'yellow', 'Open': 'red' } },
    "htmlTable": []
}

if cmd == "status":
    print( "Dashboards: {}".format( len( queryDashboards( envConfig ))))
    print( "Folders: {}".format( len( queryFolders( envConfig ))))

elif cmd == "queryAll":
    j = queryDashboards( envConfig )
    print( j )

elif cmd == "getAllFolders":
    j = queryFolders( envConfig )
    for i in j:
        print( i )

elif cmd == "queryFolderByTitle":
    folderTitle = sys.argv[2] if len(sys.argv) > 2 else "None"
    j = queryFolderByTitle( envConfig, folderTitle )
    print( j )

elif cmd == "createTestDashboard1":
    # https://grafana.com/docs/grafana/latest/developers/http_api/dashboard/#create--update-dashboard
    fj = queryFolderByTitle( envConfig, "Test" )
    #with open("Test_Dashboard_1.json") as f:
    with open("dashboard-use-cases.json") as f:
        dj = json.load(f) 
        # Create new dashboard
        dj['id'] = None
        dj['uid'] = None
        dj['title'] = "Test_Dashboard_1"
        #print( dj )
        ct = datetime.now()
        newDashboard = {
            "dashboard": dj,
            "folderUid": fj['uid'],
            "message": "Created {}".format(ct),
            "overwrite": True # Update
            }
        updateDashboard( envConfig, newDashboard )

elif cmd == "queryByTitle":
    title = "UC 0000 - Use Cases - New Version"
    title = "Test1"
    dl = queryDashboards( envConfig )
    for i in dl:
        print(i)
        if i['type'] == 'dashb-folder':
            print( i['id'], i['title'], i['uid'], i['folderUid'] )
        elif i['type'] == 'dashb-db':
            print( i['id'], i['title'], i['uid'] )
    d = [ i for i in dl if i['title'] == title ]
    print( "d", d )
    dashboardUid = d[0]['uid']
    folderUid = d[0]['folderUid']
    dj = getDashboardFromUid( envConfig, dashboardUid )
    #print( dj )
    #print( dj['dashboard'] )
    ct = datetime.now()
    newDashboard = {
        "dashboard": dj['dashboard'],
        "folderUid": folderUid,
        "message": "Udated {}".format(ct),
        "overwrite": True
        }
    #print( newDashboard )
    #updateDashboard( envConfig, newDashboard )

elif cmd == "upload":
     # Title of dashboard to update
    title = "UC 9999 - Use Cases - New Version"
    newDashboardFile = "dashboard-use-cases.json"
    dl = queryDashboards( envConfig )
    d = [ i for i in dl if i['title'] == title ]
    if len(d) == 0:
        print( "Dashboard does not exist: {}".format(title))
        exit()
    elif len(d) > 1:
        print( "Multiple reponses returned for ({}) ({})".format(title, d) )
    elif len(d) == 1:
        print(d)
        dashboard = getDashboardFromUid( envConfig, d[0]['uid'] )
        currentDashboard = {
            "uid": d[0]['uid'],
            "folderUid": d[0]['folderUid'],
            "dashboard": dashboard,
            "id": dashboard['dashboard']['id'],
            "version": dashboard['dashboard']['version']
        }
        with open(newDashboardFile, 'r') as f:
            j = json.load(f)
            j['id'] = currentDashboard['id']
            j['uid'] = currentDashboard['uid']
            j['version'] = currentDashboard['version']
            j['tite'] = title
            newDashboard = {
                "dashboard": j,
                "folderUid": currentDashboard['folderUid'],
                "message": "Udated {}".format( datetime.now() ),
                "overwrite": True
                }
            #print( newDashboard )
            updateDashboard( envConfig, newDashboard )
    else:
        print( "Unknown error")

elif cmd == "create":
    csvFile = sys.argv[2] if len(sys.argv) > 2 else "test.csv"
    print( "Opening: {}".format(csvFile))
    with open(csvFile, mode ='r')as file:
        csvFile = csv.reader(file)
        config['htmlTable'].append('<table>')
        for l in csvFile:
            if l[0] == config['startAfterHeader'] and config["convert"] == False:
                config["convert"] =  True
                config['headers'] = l
                config['covertColumnsIndex'] = [ 
                    {   'header': cc,
                        'ci': config['headers'].index( cc ),
                        'makeLink': cc in config['makeLinks'],
                        'color': cc in config['color'],
                    } for cc in config["convertColumns"] ]
                config['htmlTable'].append('<tr>')
                #print( config['covertColumnsIndex']  )
                for hi in config['covertColumnsIndex']:
                    config['htmlTable'].append('<th>{}</th>'.format(config['headers'][hi['ci']]))
                config['htmlTable'].append('</tr>')
                # this is the header line
            elif l[0] == config['stopOnHeader'] and config["convert"] == True:
                config["convert"] =  False
                # this is the last line
            else:
                #print(config["convert"], l)
                if config["convert"]:
                    nl = [ l[ cci['ci'] ] for cci in config["covertColumnsIndex"] ]
                    #print( "nl ", nl )
                    config['htmlTable'].append('<tr>') # Start of table row
                    for cci in config["covertColumnsIndex"]:
                        headerName = cci['header']
                        v = l[ cci['ci'] ] # Get the value from the Column
                        if cci['makeLink'] and v != "":
                            config['htmlTable'].append("<td><a href='{}' target='_blank'>Link</a></td>".format(v))
                        elif headerName in config['color'].keys(): 
                            if v in config['color'][headerName].keys():
                                color = config['color'][headerName][v]
                                h = "<td style='color:{}'>{}</td>".format(color, v)
                                print( "Header color", headerName, v, h )
                                config['htmlTable'].append(h)
                            else: # No matching value
                                config['htmlTable'].append('<td>{}</td>'.format(v))
                        else:
                            config['htmlTable'].append('<td>{}</td>'.format(v))
                    config['htmlTable'].append('</tr>') # End of table row
                    #print( "nl ", nl)
        config['htmlTable'].append('</table>')      
                
        for i in config:
            print( i, str( config[i] )[:256])

        print( "Creating: test.html")
        f = open("test.html","w+")
        for line in config['htmlTable']:
            f.write(line)
        f.close()


        # Insert table HTML into JSON dashboard
        htmlTableContent = '\n'.join(config['htmlTable'])
        f = open("template-use-case-dashboard.json")
        j = json.load(f)
        print( "Inserting at: ", j['panels'][0]['options']['content'] )
        j['panels'][0]['options']['content'] = htmlTableContent
        #print( j['panels'][0]['options']['content'] )

        print( "Creating: dashboard-use-cases.json")
        with open('dashboard-use-cases.json', 'w') as f:
            json.dump(j, f, ensure_ascii=False, indent=4)

elif cmd == "test":
    print("test")
else:
    print("Unknown Commands: [{}]\n".format(cmd))
    print( "Commands are:")
    print("  create <source csv file>")
    print("  test")

exit()