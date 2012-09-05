Introduction
------------

elog can find and filter specified error logs from your applications, web servers and any other text based log files, store the logs into [MongoDB](http://mongodb.org). Then you can access the logs from MongoDB via a web interface with some filter options.

elog contains elog-client and elog-server,  elog-client can filter and push logs to elog-server via http requests, elog-server is a kind of web server with [expressjs](http://expressjs.com). 

Quick Start
-----------

### Installation

Before you start, you need to install [nodejs](http://nodejs.org) (&gt;= 0.8.8) and [CoffeeScript](http://coffeescript.org) (&gt;=1.3.3) in your Linux/Unix system, then install elog:

    $ [sudo] npm -g install elog

### Configuration: 

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
                "rules": {
                    "include": [ 
                        [["error", "i"], "LOG_ERROR"],
                        ["Notice", "LOG_WARN"]
                    ],
                    "exclude": ["Primary script unknown"]
                }
            },
            {
                "name": "nginx",
                "file": "/usr/local/nginx/logs/error.log",
                "interval_time": 5000,
                "position": 0,
                "rules": {
                    "include": [
                        ["error", "LOG_ERROR"],
                        ["alert", "LOG_WARN"]
                    ],
                    "exclude": []
                }
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
* rules: define some rules to filter logs, it contains "include" and "exclude": 
* rules['include']: it's an array, each element is also an array which contains 2 elements, the first one is for build regular expression, it could be a string or an array. The sedond parameter is log level (LOG\_FATAL, LOG\_ERROR, LOG\_WARN, LOG\_INFO, LOG\_DEBUG), logs will be processed if matched.
* rules['exclude']: it's an array, logs will be excluded if matched any rules (regular expression) list here.

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

### Run

**start client**
    
    $ nohup elog-client /etc/elog/client.json > /var/log/elog-client.log &

**start server**

    $ nohup elog-server /etc/elog/server.json > /var/log/elog-server.log &

If something went wrong, you can check the log files you specified such as above, otherwise, you can go and visit http://localhost:3339 to see error logs.

**reload client or server**

In case if you changed some configuration, we can reload the settings without shutdown the client or the server process, just reload it:

    $ elog-server reload  # server side
    $ elog-client reload  # client side

**stop client and server**

    $ elog-server stop
    $ elog-client stop

## Tips

**JSON configuration check**

    $ node /etc/elog/client.json
    No output if there is no errors.

**Read log files failed**

Please check if the log file is exists or the current user has read permission to read the file.

Development & Test
------------------

we are using mocha with should for the test, run test in the elog directory:

    $ mocha -r should --compilers coffee:coffee-script

Known issues:
* It doesn't work with logs with multiple bytes. 
* It only can process logs line by line.
* It's only tested on linux/unix system, especially for the reload and stop commands.

Tested Log files
----------------

* php, nginx and apache
