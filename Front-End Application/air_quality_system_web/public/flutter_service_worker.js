'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "assets/AssetManifest.json": "9d9a85030dc31de2f4fbb4b28e5b5538",
"assets/assets/images/bg.png": "11d722121a23198ac3f916f10c6c9167",
"assets/assets/images/delete.png": "6de05df02ead1400f83799d851d06faa",
"assets/assets/images/legend_AQI.png": "a1a70bb998d7f85bfdf6c60137444e0b",
"assets/assets/images/legend_Humidity.png": "8345946d2e8ae0e96888e212ca224b77",
"assets/assets/images/legend_PM10.png": "14831785899c5fffc4baff9544f026a1",
"assets/assets/images/legend_PM2.5.png": "c91021bf0e0ebb6260b9a2ea84a88731",
"assets/assets/images/legend_Pressure.png": "5ab1d31b50c4bdaaff837efd5c694f93",
"assets/assets/images/legend_Temperature.png": "79b81611841fb5abf09380ad17a744ff",
"assets/assets/images/otp-icon.png": "f83650bec916c0955adb8d15296d549f",
"assets/assets/images/shape_hexagon.png": "f6c86eb0555f732dded626d92fecbeb0",
"assets/assets/images/success.png": "ddfced56f97627ebb7b0803f881981e6",
"assets/assets/img/d1s.png": "e5e5bfb095fba4f2d500de466a2d8078",
"assets/assets/img/d2s.png": "3fa54698e0b5f6c7e1f0746a1d933634",
"assets/assets/img/d3s.png": "e893c7515466d54ff742331ce4ca89a2",
"assets/assets/img/d4s.png": "c67a957deeda53108b452eafbbc4bf8e",
"assets/assets/img/d5s.png": "bcf54f3d7d4cdbec323d0c9ba21830e6",
"assets/assets/img/d6s.png": "bf444b15b444e135eefc2c56bbceddc1",
"assets/assets/img/d7s.png": "7e22986dbde6c07774688ac41f2acb04",
"assets/assets/img/d8s.png": "5809798989839d6501dc63643c1e03d8",
"assets/assets/img/d9s.png": "85fa39ea9f39c5783533b47d2e7a52ab",
"assets/assets/img/dotBlueishFull.png": "1a8752902ff0fa05b41afed723ad2b80",
"assets/assets/img/dotEmpty.png": "ad6349a453982d0af50c330c196e2060",
"assets/assets/img/n1s.png": "8c6a7578ef1b48753847613ba974ac68",
"assets/assets/img/n2s.png": "fc2f82a7bb3db0bab59c99bcd696a3ac",
"assets/assets/img/pres.png": "094f8bdfafe433468256c831ccb58fdf",
"assets/assets/img/temperature.png": "358450dfac337d88ec3c288a6451038a",
"assets/assets/img/water.png": "8a41a8622dbb20096923a9244c45aa67",
"assets/assets/img/wind.png": "856c882261c36dd8a119dbdc9090d6f3",
"assets/FontManifest.json": "6a84e6c28a318c1ef29352d8cf66d39c",
"assets/fonts/MaterialIcons-Regular.otf": "1288c9e28052e028aba623321f7826ac",
"assets/NOTICES": "8e61c6585c3dbbe159b4cfc182b9094d",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "831eb40a2d76095849ba4aecd4340f19",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "a126c025bab9a1b4d8ac5534af76a208",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "d80ca32233940ebadc5ae5372ccd67f9",
"assets/packages/material_design_icons_flutter/lib/fonts/materialdesignicons-webfont.ttf": "51c686b86bc12382579d8283b7e76b6b",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"index.html": "c7311d79aeba011b185002c279d2ee8b",
"/": "c7311d79aeba011b185002c279d2ee8b",
"main.dart.js": "d3c34988d56cf5cacfa727e61a2aec41",
"manifest.json": "9b7f9188e073bce9157b9d7625f7f7d6"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value + '?revision=' + RESOURCES[value], {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list, skip the cache.
  if (!RESOURCES[key]) {
    return event.respondWith(fetch(event.request));
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    return self.skipWaiting();
  }
  if (event.message === 'downloadOffline') {
    downloadOffline();
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey in Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
