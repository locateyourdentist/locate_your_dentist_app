'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "ec77e8f62105e04345e59b83d1725072",
"assets/AssetManifest.bin.json": "681b68351ea3d617f110be93d789f6ec",
"assets/AssetManifest.json": "480ce0008f029c02bf16a51072109370",
"assets/assets/fonts/Roboto-Bold.ttf": "b2c24342409e47baaeb690d76cbd7df3",
"assets/assets/fonts/Roboto-Regular.ttf": "ac3f799d5bbaf5196fab15ab8de8431c",
"assets/assets/images/aboutt.jpg": "a445faed5d17ec89379278c6c788e7f2",
"assets/assets/images/addimg1.jpeg": "128d1ac53ea8497ad4376b0df93e5ad2",
"assets/assets/images/addimg2.jpg": "5b9d7ac90cd9d470125e2de9e118befb",
"assets/assets/images/addimg3.jpg": "d6307ec25f60fd3adb97e75d514d6b61",
"assets/assets/images/addimg4.jpg": "f67d65f48be62f4b00fc7fd0e1db0cab",
"assets/assets/images/addImg5.png": "4baeaaa27542307bb5c7fa07188cb286",
"assets/assets/images/Cad_Cam.png": "a8cc668f6dd5d6240ad761ccd8109b2c",
"assets/assets/images/call.png": "cd497fd53247e00cb06dd9775c7e139b",
"assets/assets/images/cc.jpg": "461270d258a3c99420a4b4d133ee4839",
"assets/assets/images/contactss.jpg": "d4705bbc4edf75d9a9cb0a5578523834",
"assets/assets/images/contactus.jpg": "35f17ecfefa1717f92692fe00388a96f",
"assets/assets/images/cs.jpg": "d97e60acb84739d0b5a8647c729d6fa4",
"assets/assets/images/Dental_clinic.jpg": "2a5bb1aa2bbe8d713aee18d34e7dbef6",
"assets/assets/images/dental_implants.jpg": "7970d9c8353f7849fc6b7ce9e1494f90",
"assets/assets/images/Dental_Lab02.jpg": "b85cff8099eaed8a2be3e461b6534ae8",
"assets/assets/images/Dental_Lab_certificate.jpeg": "dc4242476b3685e2ed04ab93608536b3",
"assets/assets/images/dental_shop.jpg": "852bb9c131241cd436ad27b7c5e44b58",
"assets/assets/images/doctor1.jpg": "dbd5547e7eb4730207c2dbe6da4cc0a2",
"assets/assets/images/doctor2.png": "76ccc299735a1e1af5e194dcba2e4e27",
"assets/assets/images/doctor4.jpg": "9850de9719306146483ea032f87353de",
"assets/assets/images/doctor5.jpg": "3d8bd32f309a776d060a6090f939119b",
"assets/assets/images/facebook.png": "60ace5feac0e51ee2c7a12455a651d19",
"assets/assets/images/hospital.jpg": "349db121615d8b5d7c9853f901669483",
"assets/assets/images/hospital2.png": "eab8149b4329ca5531109f88e255a084",
"assets/assets/images/instagram.png": "936188928614cc61b2f98c38fc31c3ab",
"assets/assets/images/ISO_certificate.jpg": "22ab7ed2e2b73fd4d5aff42b9137947c",
"assets/assets/images/job%2520poster.png": "fcd22f11accac540962223dd48899b21",
"assets/assets/images/job.jpg": "125b954f8a778ddb6390a12c92bb10ba",
"assets/assets/images/linkein.png": "60c260bd7867847a872ecac15de550ba",
"assets/assets/images/logo.jpg": "99fa821b509a3ff3121b20ed3c76a0e5",
"assets/assets/images/lp1.jpg": "f0babe9ecd7ccd792086f8aac4473cc0",
"assets/assets/images/lp2.jpg": "e76ef3dbc05983574cea8e503fb02b06",
"assets/assets/images/lp3.jpg": "e3e794a24916132eefd534660867afb8",
"assets/assets/images/plan.png": "f54b9c73fa0932f8525df3bad37e7b3d",
"assets/assets/images/switch_account.png": "78aabbcff284f84d59229b76cb14d5f9",
"assets/assets/images/Toothsets.webp": "6e8066c40c4d2a7324fe8cace7030169",
"assets/assets/images/watsapp.png": "5e9db47465485372889ec03358c50c29",
"assets/assets/images/web.png": "eae5ed94719c5d873f2945435205125b",
"assets/assets/images/welcome.png": "8af2a23f99aacb3b0f260fba06f8c406",
"assets/assets/images/welcome1.mp4": "a36c0bbd25ac5c876d93c4c207bff15d",
"assets/assets/images/welcomePage.png": "72324db8908f8a83ead813eb41feb0a9",
"assets/assets/images/whatsapp.gif": "29eafa01ed592a380e72e6f205e45e2c",
"assets/assets/images/whychoose.jpg": "20794a333e8a0eb38d5186c613677d5c",
"assets/assets/images/youtube.png": "f7ce52b0af126a4a9d7638a58a15e3dc",
"assets/assets/indian_states.json": "f95b4fe269194c591f3307e1a1f00ad6",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "2629e0f27ea29a40aa0885e353621603",
"assets/NOTICES": "882054a7051a3c38a6ebc89193e8e4c1",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "cc77562ceec95e1e294aa41085752b3d",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "88719448e21c042a9f036eb562a71433",
"/": "88719448e21c042a9f036eb562a71433",
"main.dart.js": "1d9be0fe88069584409389393488083f",
"manifest.json": "91cceb97c391074d89cd9578e6ce7443",
"version.json": "68968a91779356ff0c4c11149e502da3"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
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
        // Claim client to enable caching on first launch
        self.clients.claim();
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
      // Claim client to enable caching on first launch
      self.clients.claim();
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
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
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
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
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
  for (var resourceKey of Object.keys(RESOURCES)) {
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
