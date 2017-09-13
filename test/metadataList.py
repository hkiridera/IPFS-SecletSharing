#!/usr/bin/env python
# coding: utf-8

from poster.encode import multipart_encode
from poster.streaminghttp import register_openers
import urllib2

if __name__ == '__main__':
    # Register streaming http handlers to urllib2 global object
    register_openers()



    request = urllib2.Request("http://localhost:8000/metadataList", data)
    request.add_header('Content-Type', 'application/json')
    response = urllib2.urlopen(request)

    print "---------- RESPONSE HEAD ----------"
    print response.info()
    print "---------- RESPONSE BODY ----------"
    print response.read()