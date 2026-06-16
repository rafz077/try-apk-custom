/* ═══════════════════════════════════════════════════════════════
   SERVICE WORKER — The 1975 - rafztry
   Provides offline caching and PWA support
   ═══════════════════════════════════════════════════════════════ */
const CACHE_NAME = 'the1975-rafztry-v1';
const ASSETS_TO_CACHE = [
  '/',
  '/index.html',
  '/manifest.json',
  '/assets/icons/icon-192x192.png',
  '/assets/icons/icon-512x512.png',
  '/assets/covers/the-1975-2013.png',
  '/assets/covers/iliwys-2016.png',
  '/assets/covers/abiior-2018.png',
  '/assets/covers/noacf-2020.png',
  '/assets/covers/bfiafl-2022.png',
  '/assets/covers/playlist-essentials.png',
  '/assets/covers/playlist-late-night.png',
  '/assets/covers/playlist-night-drive.png',
  '/assets/covers/playlist-sad-songs.png'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(ASSETS_TO_CACHE))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request).then(cached => {
      if (cached) return cached;
      return fetch(event.request).then(response => {
        if (!response || response.status !== 200 || response.type !== 'basic') return response;
        const clone = response.clone();
        caches.open(CACHE_NAME).then(cache => cache.put(event.request, clone));
        return response;
      }).catch(() => {
        if (event.request.destination === 'audio') {
          return new Response('', { status: 404, statusText: 'Audio not cached' });
        }
        return caches.match('/index.html');
      });
    })
  );
});
