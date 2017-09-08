#!/usr/bin/env python
# coding: utf-8

from poster.encode import multipart_encode
from poster.streaminghttp import register_openers
import urllib2

if __name__ == '__main__':
    # Register streaming http handlers to urllib2 global object
    register_openers()

    with open("test.txt", "rb") as f:
        data = f.read()
        request = urllib2.Request("http://localhost:8000/upload", data)
        request.add_header('Content-Length', '%d' % len(data))
        request.add_header('Content-Type', 'application/octet-stream')
        request.add_header('Content-Type', 'application/json')
        response = urllib2.urlopen(request)

        print "---------- RESPONSE HEAD ----------"
        print response.info()
        print "---------- RESPONSE BODY ----------"
        print response.read()