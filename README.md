HighScalability-Proxy
=====================

A simple proxy for highscalability.com.

It has two main features:

1. Full text output without Advertisements and Sponsored Posts for browsers.
2. Full text output for RSS readers.

The proxy is hosted on CloudFoundry.com which is an opensource PaaS.

You can visit [http://highscalability-proxy.cloudfoundry.com](http://highscalability-proxy.cloudfoundry.com) to read the latest articles. 

Your RSS reader can use this link - [http://highscalability-proxy.cloudfoundry.com/rss](http://highscalability-proxy.cloudfoundry.com/rss). You can also get the original RSS contents at [http://highscalability-proxy.cloudfoundry.com/origin_rss](http://highscalability-proxy.cloudfoundry.com/origin_rss).

2012-01-03: Add a new router which takes full advantage of EventMachine. It can only be used with thin web server. Please make sure you are using the right sinatra application in config.ru.