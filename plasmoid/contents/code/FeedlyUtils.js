.pragma library

var FEEDLY_URL = 'feedly.com/'
var FEEDLY_API_URL = 'sandbox.feedly.com/'
var FEEDLY_API_ENDPOINT = 'http://localhost'
var FEEDLY_API_ENDPOINT_REGEX = /http:\/\/localhost\/\?code\=(.*?)&state\=/
var FEEDLY_API_CLIENT_ID = 'sandbox'
var FEEDLY_API_CLIENT_SECRET = 'CS2CQZIFRB8ZVMH95ID0'

var PROJECT_URL = 'https://github.com/lassana/feedly-plasmoid'

function protocol(useHttps) {
    return useHttps ? 'https://' : 'http://'
}

function feedlySiteUrl(useHttps) {
     return protocol(useHttps) + FEEDLY_URL
}

function feedlyBaseApiUrl(useHttps) {
    return protocol(useHttps) + FEEDLY_API_URL
}

function feedlyRedirectUrl() {
    return FEEDLY_API_ENDPOINT
}

function getHtmlAuth(useHttps, callback) {
    var url = feedlyBaseApiUrl(useHttps)
            + '/v3/auth/auth' 
            + '?client_id=' + FEEDLY_API_CLIENT_ID
            + '&redirect_uri=' + feedlyRedirectUrl()
            + '&response_type=' + 'code'
            + '&scope=' + 'https://cloud.feedly.com/subscriptions'
            + '' 
    var http = new XMLHttpRequest()
    http.open('GET', url, true)
    http.onreadystatechange = function() {
        if (http.readyState == XMLHttpRequest.DONE) {
            //console.log('Headers -->\n' + http.getAllResponseHeaders ())
            //console.log('Last modified -->\n' + http.getResponseHeader ('Last-Modified'))
            //console.log('Status -->\n' + http.status)
            //console.log('responseText -->\n' + http.responseText)
            if (http.status == 200) {
                callback(http.responseText)
            }
        }
    }
    http.send(null)
}

function getTokens(code, useHttps, callback) {
    var url = feedlyBaseApiUrl(useHttps)
                + '/v3/auth/token'
                + '?code=' + code
                + '&client_id=' + FEEDLY_API_CLIENT_ID
                + '&client_secret=' + FEEDLY_API_CLIENT_SECRET
                + '&redirect_uri=' + feedlyRedirectUrl()
                + '&grant_type=' + 'authorization_code'
    var http = new XMLHttpRequest()
    http.onreadystatechange = function() {
        if (http.readyState == XMLHttpRequest.DONE) {
            //console.log('Status -->\n' + http.status)
            //console.log('responseText -->\n' + http.responseText)
            if (http.status == 200) {
                var responseObject = eval('new Object(' + http.responseText + ')')
                callback(responseObject.access_token, responseObject.refresh_token, responseObject.expires_in)
            }
            
        }
    }
    http.open('POST', url, true)
    http.send('')
}

function updateTokens(useHttps, refreshToken, callback) {
    var url = feedlyBaseApiUrl(useHttps)
                + '/v3/auth/token'
                + '?refresh_token=' + refreshToken
                + '&client_id=' + FEEDLY_API_CLIENT_ID
                + '&client_secret=' + FEEDLY_API_CLIENT_SECRET
                + '&grant_type=' + 'refresh_token'
                var http = new XMLHttpRequest()
    http.onreadystatechange = function() {
        if (http.readyState == XMLHttpRequest.DONE) {
            //console.log('Status -->\n' + http.status)
            //console.log('responseText -->\n' + http.responseText)
            if (http.status == 200) {
                var responseObject = JSON.parse(http.responseText)
                callback(responseObject.access_token, responseObject.expires_in)
            }
        }
    }
    http.open('POST', url, true)
    http.send('')
}

function getMostPopular(token, useHttps, streamId, callback) {
    var mostPopular = null
    var url = protocol(useHttps) + FEEDLY_API_URL + 'v3/mixes/contents?streamId=' + streamId + '&unreadOnly=true&count=' + 5
    var http = new XMLHttpRequest()
    http.onreadystatechange = function() {
        if (http.readyState == XMLHttpRequest.DONE) {
            if (http.status == 200) {
                //console.log('responseText -->\n' + http.responseText)
                var responseObject = JSON.parse(http.responseText)
                for (var i=0, len=responseObject.items.length; i<len; i++) {
                    if (!responseObject.items[i].unread) {
                        continue
                    }
                    if (mostPopular == null || mostPopular.image == null || responseObject.items[i].engagement > mostPopular.engagement) {
                        var thumbnail = responseObject.items[i].thumbnail != null 
                                        ? responseObject.items[i].thumbnail[0].url 
                                        : (responseObject.items[i].thumbnail != null && responseObject.items[i].thumbnail[0] != null)
                                            ? responseObject.items[i].thumbnail[0]
                                            : null
                        mostPopular = {
                            engagement: responseObject.items[i].engagement == null ? 0 : responseObject.items[i].engagement,
                            title: responseObject.items[i].title,
                            url: responseObject.items[i].originId,
                            image: thumbnail,
                            from: responseObject.items[i].origin.title,
                            date: responseObject.items[i].published
                        }
                    }
                }
                callback(mostPopular)
            }
        }
    }
    http.open('GET', url, true)
    http.setRequestHeader('Authorization', token)
    http.send(null)
}

function getUnreadCounts(token, useHttps, callback) {
    var newUnreadsCount = 0
    var mainStreamId = ''
    var url = protocol(useHttps) + FEEDLY_API_URL + 'v3/markers/counts'
    var http = new XMLHttpRequest()
    var listener = function() {
        if (http.readyState == XMLHttpRequest.DONE) {
            //console.log('Status -->\n' + http.status)
            //console.log('responseText -->\n' + http.responseText)
            if (http.status == 200) {
                var responseObject = eval('new Object(' + http.responseText + ')')
                for (var i = 0; i < responseObject.unreadcounts.length; i++)
                {
                    var nextId = responseObject.unreadcounts[i].id
                    var nextIdType = nextId.substring(0, 5)
                    if (nextIdType == 'feed/') {
                        newUnreadsCount += responseObject.unreadcounts[i].count
                    } else if(nextIdType == 'user/' && nextId.indexOf('global.all') > -1) {
                        mainStreamId = nextId
                    }
                }
                if (mainStreamId != '') {
                    getMostPopular(token, useHttps, mainStreamId, function(mostPopular) {
                        callback(newUnreadsCount, mostPopular)
                    })
                } else {
                    callback(newUnreadsCount, null)
                }
            }
        }
    }
    http.onreadystatechange = listener
    http.open('GET', url, true)
    http.setRequestHeader('Authorization', token)
    http.send('')
}