Introduction
------------

elog can find specified error logs from your applications, web servers and any other text based log files, and store the logs into [MongoDB](http://mongodb.org). You can access the logs from MongoDB via a web interface with some filter options.

Quick Start
-----------

Before you start, you need to install [nodejs](http://nodejs.org) (&gt;= 0.8.8) and [CoffeeScript](http://coffeescript.org) (&gt;=1.3.3) in your Linux/Unix system, then:

    $ [sudo] npm -g install elog

elog contains elog-client and elog-server,  elog-client can find and push logs to elog-server via http requests, elog-server is a kind of web server with [expressjs](http://expressjs.com). 

**client settings: elog-client**

It's a standard JSON file, You need to specify the log files for each app and api like below.

_/etc/elog/client.json_:

```js
    {
        "apps": [
            {
                "name": "app name",
                "file": "/tmp/php_errors.log",
                "interval_time": 5000,
                "position": 0,
                "rules": [
                    ["error", "LOG_ERROR"],
                    ["Notice", "LOG_WARN"]
                ]
            },
            {
                "name": "nginx",
                "file": "/usr/local/nginx/logs/error.log",
                "interval_time": 5000,
                "position": 0,
                "rules": [
                    ["error", "LOG_ERROR"],
                    ["alert", "LOG_WARN"]
                ]
            }
        ],
        "api": {
            "key": "mykey",
            "url": "http://localhost:3339/api"
        }
    }
```

for each app, there are 5 parameters:
* name: name of your app, (Note: don't put comma ',' in it')
* file: log file path
* interval\_time: every number of seconds to check new logs
* position: read data from log file in the specified positon after elog-client is started
* rules: define some rules to filter logs, it's an array, each element in the array contains 2 elements, the first one is a regular expression, the sedond one is log level (LOG\_FATAL, LOG\_ERROR, LOG\_WARN, LOG\_INFO, LOG\_DEBUG)

Also, you need to define an api key and url like above, the api key is just a random string which need to match the server side api key settings.

**server settings: elog-server**

_/etc/elog/server.json_:

```js
{
    "api_key": "mykey",
    "http": {
        "host": "localhost",
        "port": 3339
    },
    "mongodb": {
        "port": 27017,
        "host": "localhost",
        "database": "elog",
        "collection": "logs"
    },
    "web": {
        "title": "elog",
        "limit_per_page": 100,
        "refresh_time": 10000
    }
}
```

The server side settings is also a standand JSON file:
* api\_key: api key for the authentication, elog-client should send the same api key to match this one when push logs.
* http: define a host and port to start a web server. 
* mongodb: mongodb related settings
* web: web page related settings 

**start client**
    
    $ nohup elog-client /etc/elog/client.json > /var/log/elog-client.log &

**start server**

    $ nohup elog-server /etc/elog/server.json > /var/log/elog-server.log &

If something went wrong, you can check the log files you specified such as above. 

Development & Test
------------------

we are using mocha with should for the test, run test in elo directory:

    $ mocha -r should --compilers coffee:coffee-script

Known issues:
* It doesn't work with logs with multiple bytes. 
* It only can process logs line by line.
