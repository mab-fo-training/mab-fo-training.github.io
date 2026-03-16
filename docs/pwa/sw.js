const CACHE_NAME = 'ioe-submit-v1';
const STATIC_ASSETS = [
    './',
    './index.html',
    './manifest.json',
    'https://alcdn.msauth.net/browser/2.38.1/js/msal-browser.min.js',
    'https://cdn.tailwindcss.com'
];

// Install: cache static assets
self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            return cache.addAll(STATIC_ASSETS).catch((err) => {
                console.log('[SW] Some assets failed to cache:', err);
            });
        })
    );
    self.skipWaiting();
});

// Activate: clean old caches
self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then((keys) => {
            return Promise.all(
                keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key))
            );
        })
    );
    self.clients.claim();
});

// Fetch: network-first for API calls, cache-first for static assets
self.addEventListener('fetch', (event) => {
    const url = new URL(event.request.url);

    // Network-only for API calls (SharePoint, Power Automate, MSAL)
    if (
        url.hostname.includes('sharepoint.com') ||
        url.hostname.includes('logic.azure.com') ||
        url.hostname.includes('microsoftonline.com') ||
        url.hostname.includes('msauth.net') ||
        url.hostname.includes('login.microsoft')
    ) {
        event.respondWith(fetch(event.request));
        return;
    }

    // Cache-first for everything else
    event.respondWith(
        caches.match(event.request).then((cached) => {
            return cached || fetch(event.request).then((response) => {
                // Cache successful GET responses
                if (event.request.method === 'GET' && response.status === 200) {
                    const clone = response.clone();
                    caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone));
                }
                return response;
            });
        }).catch(() => {
            // Offline fallback for navigation
            if (event.request.mode === 'navigate') {
                return caches.match('./index.html');
            }
        })
    );
});
