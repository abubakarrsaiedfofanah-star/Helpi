const CACHE_NAME = 'helpi-pwa-v1';
const APP_SHELL = ['./', './index.html', './manifest.json'];
const STATIC_FILE = /\.(?:avif|bin|css|font\.json|html|ico|jpeg|jpg|js|json|otf|png|svg|ttf|wasm|webp|woff2?)$/i;
const API_PATH = /\/(?:api|auth\/v1|rest\/v1|storage\/v1|functions\/v1|realtime\/v1)(?:\/|$)/i;
const MAX_CACHED_RESPONSE_BYTES = 25 * 1024 * 1024;
const MAX_CACHE_ENTRIES = 120;

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(APP_SHELL))
      .then(() => self.skipWaiting()),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(
        keys.filter((key) => key.startsWith('helpi-pwa-') && key !== CACHE_NAME)
          .map((key) => caches.delete(key)),
      ))
      .then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;

  const url = new URL(request.url);
  if (url.origin !== self.location.origin || API_PATH.test(url.pathname)) return;

  if (request.mode === 'navigate') {
    event.respondWith(fetch(request).then((response) => {
      if (response.ok) {
        return caches.open(CACHE_NAME)
          .then((cache) => cache.put('./index.html', response.clone()))
          .then(() => response);
      }
      return response;
    }).catch(async () => (await caches.match('./index.html')) || (await caches.match('./'))));
    return;
  }

  if (!STATIC_FILE.test(url.pathname)) return;
  event.respondWith(fetch(request).then(async (response) => {
    const size = Number(response.headers.get('content-length') || 0);
    if (response.ok && (!size || size <= MAX_CACHED_RESPONSE_BYTES)) {
      const cache = await caches.open(CACHE_NAME);
      await cache.put(request, response.clone());
      const keys = await cache.keys();
      if (keys.length > MAX_CACHE_ENTRIES) {
        const oldest = keys.find((key) => key.url !== new URL('./index.html', self.registration.scope).href);
        if (oldest) await cache.delete(oldest);
      }
    }
    return response;
  }).catch(async () => (await caches.match(request)) || Response.error()));
});
