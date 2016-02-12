.pragma library

function protocol(useHttps) {
    return useHttps ? 'https://' : 'http://'
}

function feedlySiteUrl(useHttps) {
     return protocol(useHttps) + 'feedly.com/'
}

function getUnreadCounts(token, useHttps, callback) {
    var url = protocol(useHttps) + 'cloud.feedly.com/v3/markers/counts'
    var http = new XMLHttpRequest()
    http.onreadystatechange = function() {
        if (http.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            //console.log('Headers -->\n' + http.getAllResponseHeaders ())
            //console.log('Last modified -->\n' + http.getResponseHeader ('Last-Modified'))
        } else if (http.readyState == XMLHttpRequest.DONE) {
            var newUnreadsCount = 0
            //console.log('Headers -->\n' + http.getAllResponseHeaders ())
            //console.log('Last modified -->' + http.getResponseHeader ('Last-Modified'))
            console.log('Status -->' + http.status)
            //console.log('responseText -->\n' + http.responseText)
            if (http.status == 200) {
                var responseObject = eval('new Object(' + http.responseText + ')')
                for (var i = 0; i < responseObject.unreadcounts.length; i++)
                {
                    var nextId = responseObject.unreadcounts[i].id
                    if (nextId.substring(0, 5) == 'feed/') {
                        newUnreadsCount += responseObject.unreadcounts[i].count
                    }
                }
            }
            console.log('newUnreadsCount: ' + newUnreadsCount)
            callback(newUnreadsCount)
        }
    }
    http.open('GET', url, true)
    http.setRequestHeader('Authorization', token)
    http.send('')
}