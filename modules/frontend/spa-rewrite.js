function handler(event) {
    var request = event.request;
    var uri = request.uri;

    var isApi = uri === '/api' || uri.startsWith('/api/');
    var isAsset = uri.startsWith('/assets/');
    var isSpaRoute = uri.endsWith('/') || !uri.includes('.');

    if (!isApi && !isAsset && isSpaRoute) {
        request.uri = '/index.html';
    }

    return request;
}