const CACHE_NAME = 'word-generator-v1';
const CACHE_URLS = [
    '/',
    '/static/index.html',
    '/static/manifest.json',
    '/static/icon-192.png',
    '/static/icon-512.png'
];

self.addEventListener('install', event => {
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then(cache => cache.addAll(CACHE_URLS))
    );
});

self.addEventListener('fetch', event => {
    event.respondWith(
        caches.match(event.request)
            .then(response => response || fetch(event.request))
    );
}); 