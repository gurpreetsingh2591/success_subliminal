'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"version.json": "86c5ddfb36dbaf13fec87649585d95da",
"index.html": "6c7110535e56ca69053fe37e58e8ee0c",
"/": "6c7110535e56ca69053fe37e58e8ee0c",
"purchase.js": "437efc167177f03082e9c11a3bf8b812",
"main.dart.js": "eb85e1523c3c51b2eb3b9efd6d4c4a07",
"addPaymentInfo.js": "0c64b4b8cb341624ae374fd723a49b6e",
"flutter.js": "6fef97aeca90b426343ba6c5c9dc5d4a",
"subscription.js": "06fdeb45ca9e2211cff129ee49ec78b1",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "88adb1f0df5a31096a058e008655343b",
"sitemap.xml": "5d2efced62686acc1210f3eef0445676",
"startTrial.js": "03b9d29e4dbfd29d1204ba353b33ec76",
"assets/AssetManifest.json": "ae04d2e9165921186b7010354995c4fa",
"assets/NOTICES": "f5f6fbce87ab6ec29c5d10e615f7fa98",
"assets/FontManifest.json": "ca3f9e80dc71818eff37945cd0062c40",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_AMS-Regular.ttf": "657a5353a553777e270827bd1630e467",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Script-Regular.ttf": "55d2dcd4778875a53ff09320a85a5296",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size3-Regular.ttf": "e87212c26bb86c21eb028aba2ac53ec3",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Typewriter-Regular.ttf": "87f56927f1ba726ce0591955c8b3b42d",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Caligraphic-Bold.ttf": "a9c8e437146ef63fcd6fae7cf65ca859",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_SansSerif-Bold.ttf": "ad0a28f28f736cf4c121bcb0e719b88a",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-Bold.ttf": "9eef86c1f9efa78ab93d41a0551948f7",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Fraktur-Regular.ttf": "dede6f2c7dad4402fa205644391b3a94",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-Regular.ttf": "5a5766c715ee765aa1398997643f1589",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_SansSerif-Italic.ttf": "d89b80e7bdd57d238eeaa80ed9a1013a",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Math-Italic.ttf": "a7732ecb5840a15be39e1eda377bc21d",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-Italic.ttf": "ac3b1882325add4f148f05db8cafd401",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Fraktur-Bold.ttf": "46b41c4de7a936d099575185a94855c4",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size2-Regular.ttf": "959972785387fe35f7d47dbfb0385bc4",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_SansSerif-Regular.ttf": "b5f967ed9e4933f1c3165a12fe3436df",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size1-Regular.ttf": "1e6a3368d660edc3a2fbbe72edfeaa85",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Caligraphic-Regular.ttf": "7ec92adfa4fe03eb8e9bfb60813df1fa",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size4-Regular.ttf": "85554307b465da7eb785fd3ce52ad282",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-BoldItalic.ttf": "e3c361ea8d1c215805439ce0941a1c8d",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Math-BoldItalic.ttf": "946a26954ab7fbd7ea78df07795a6cbc",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/wakelock_web/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"assets/shaders/ink_sparkle.frag": "f8b80e740d33eb157090be4e995febdf",
"assets/AssetManifest.bin": "44be04e46a236526dc16a51bd6dd31c0",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/assets/file/termsFile.html": "63577ad973771e9737660f5a06440a96",
"assets/assets/images/ic_delete_white.png": "42d9658f37c7a453d0206686178fb51c",
"assets/assets/images/ic_apple_pay.png": "4be1d4bcbbe77917cedd4922f870d923",
"assets/assets/images/ic_monthly_bg.png": "4686995215b88bdfe439c372c7a4b001",
"assets/assets/images/ic_shadow.png": "d82a36446f63f6cbfee667d9643dcf7e",
"assets/assets/images/ic_step.png": "64709aff227ea5508446121d332323f1",
"assets/assets/images/ic_discover_yellow.png": "c26fbd20906c1dc6f4adc97803c2ecc9",
"assets/assets/images/ic_trash.png": "49870f50de96e8feebcf7ab0a05907a8",
"assets/assets/images/ic_account_white.png": "4ca7dbdd514954e9846dab109babaf14",
"assets/assets/images/ic_arrow_left.png": "ae376dc41a137455eb68728375c94ea9",
"assets/assets/images/ic_empty_tick.png": "b76bce022ae6a387047c336c43f6a4b5",
"assets/assets/images/ic_text_button.png": "348108edf6374b833a1ba44dabf65e86",
"assets/assets/images/ic_account_yellow.png": "a18b37237b4fac64d00a5faaa1019e48",
"assets/assets/images/bg_web.png": "32456a7548a4b75659e99aa43e83daaf",
"assets/assets/images/ic_google_play_icon.png": "fcb6a74ef637ce361e53fc7700d15c6c",
"assets/assets/images/ic_button.png": "6824a402d205e79d66a32c392a06f6d2",
"assets/assets/images/ic_library_white.png": "c7ef716b5d3a5e001054dc01dea6ba3a",
"assets/assets/images/ic_play_icon.png": "4985aadf4ea51f7df0b1860adea19914",
"assets/assets/images/ic_discover_btn.png": "3448c034afd9395a95d3d926a22f5ddb",
"assets/assets/images/ic_close.png": "10673cdf31977886b308d6fea699f115",
"assets/assets/images/ic_convert.png": "6f475c43dddf3c1d2db626c25b9d73a7",
"assets/assets/images/ic_home.png": "2fe014525cc458c5db70080d2833c211",
"assets/assets/images/app_logo_mobile.png": "9dba5b78ee832902d3b3b3a4a495afec",
"assets/assets/images/ic_black_bg.png": "c30e8cd9297f54af0a6f8735f6842d34",
"assets/assets/images/ic_cards.png": "946680c55b16e423833271cf5777c05c",
"assets/assets/images/bg_logo_image.png": "8bb62958a987985e7dd105478e0f5f25",
"assets/assets/images/ic_stop.png": "40635090099485e91659f01e93f0947d",
"assets/assets/images/ic_stop_icon_white.png": "ef7977fb58a0496e22f878bd0f0542b0",
"assets/assets/images/ic_close_btn.png": "42d95e30459258e3aaec21a340d5236d",
"assets/assets/images/ic_grid_view.png": "70d446be997e893d8d603a66b664087c",
"assets/assets/images/ic_home_white.png": "a5b4c05f9279888116a66cb7a2540beb",
"assets/assets/images/bg_image.png": "e61699b0ee5a4066fee32d5572d5c917",
"assets/assets/images/ic_bg_dark_blue.png": "7630f9f5b9a17a872d3cb2b07b5424ce",
"assets/assets/images/ic_delete.png": "9c5497ae22a537cbcd06b284f3de012c",
"assets/assets/images/ic_bag_tick.png": "c8230db426008adfde003533d620189a",
"assets/assets/images/ic_sms.png": "097d4c7536d2e8fc064be7daff118aeb",
"assets/assets/images/ic_video.png": "994677e859b14a19ee8e621e813fb0e6",
"assets/assets/images/dummy_image.png": "5aad00245be7d45d1d76db886cfda6bd",
"assets/assets/images/ic_twitter.png": "9f6118f45fbb4b6e5ffd7ba45db77620",
"assets/assets/images/ic_send_email_bg_mobile.png": "e3c0a78adc251c3db37fa84eed94d402",
"assets/assets/images/ic_send_email_bg.png": "db306f89b8e354743c3ce9fc36e8792a",
"assets/assets/images/ic_discover_white.png": "d5550e8496b7bb2ac7ddcf7185b8e945",
"assets/assets/images/ic_heart_empty.png": "c61daa776a139b079d1640649bdf2aed",
"assets/assets/images/discover_dummy_img.png": "281bfdab9eac1ab8992b77b9fe953109",
"assets/assets/images/ic_annual_bg.png": "35ddb41b35506cec3407404fc2a76dde",
"assets/assets/images/ic_more.png": "955d552e6b903a2815acb5bee987f162",
"assets/assets/images/ic_cancel_subscription_btn.png": "8a127dbdd8b1e3a1e5f200c320064b5b",
"assets/assets/images/ic_pause_icon.png": "3a5139956bfb7540fd50bd0d1c0ba54b",
"assets/assets/images/ic_edit.png": "0b19d936aab6d4f79876451564d78669",
"assets/assets/images/ic_pause_white.png": "7a54ff6ca05ba1eba2eb997f77f4916d",
"assets/assets/images/ic_alert.png": "23460c5353c4bc91a552bb8f75e215cc",
"assets/assets/images/logout_web.png": "5901f1f65285d5c904f23f98d8d00b68",
"assets/assets/images/ic_dummy_home_web.png": "dd3fc6fb9cdf697033377dff701a3faa",
"assets/assets/images/ic_fb.png": "37d9ef6c19c671e6631c568ec0121edc",
"assets/assets/images/ic_discover.png": "d5550e8496b7bb2ac7ddcf7185b8e945",
"assets/assets/images/congrats.png": "c7634d607f3ecd90acbcf35b154a18e9",
"assets/assets/images/ic_discover_button.png": "da2a529f42dfa2799a659a2d087c9659",
"assets/assets/images/ic_save.png": "e537050bf89180c70b52c802a22b69df",
"assets/assets/images/ic_download.png": "9695b23dc2a41dbb62d84876a8642c79",
"assets/assets/images/ic_play_button_white.png": "308ceab63dc1f6dee7346e93bb8a6adc",
"assets/assets/images/ic_play.png": "da2d73719123c5222cbf3804c083ad8f",
"assets/assets/images/ic_home_yellow.png": "2fe014525cc458c5db70080d2833c211",
"assets/assets/images/ic_half_yearly_bg.png": "83b2fb8366b081bd37a65540e4df8e60",
"assets/assets/images/app_logo.png": "b4bd6f8af403476c53747f25a2ec4474",
"assets/assets/images/ic_export_button.png": "ecf6a1965912893c0f076d6f67cbfc7d",
"assets/assets/images/ic_close_icon.png": "f37186d35401dcb4b3b3f4f01e5db164",
"assets/assets/images/ic_heart_icon.png": "9500d21efc9ce64b23add72e62d97bdf",
"assets/assets/images/ic_tick_yellow.png": "16305491127cd6516c6582b1e3346cc0",
"assets/assets/images/ic_buy_subscription.png": "7d8967026db620b3df8fb85830026b77",
"assets/assets/images/ic_write_sub.png": "b79a55f9d0999e1f43ff4cb4f1690355",
"assets/assets/images/ic_list_view.png": "685ef61b17323f074374d401796adfcb",
"assets/assets/images/ic_library_yellow.png": "6462847af80fe503efb93c34b4a6918b",
"assets/assets/images/ic_stop_icon.png": "934f6011126b95543c385de03b527050",
"assets/assets/images/ic_close_bg.png": "d5724cd739ec9cc8c8ec0cb07e5e5d14",
"assets/assets/images/ic_push.png": "7ab65e21333bc3dbf09785c86c15f36c",
"assets/assets/images/ic_bottom_arrow.png": "881f1a82f4c7823625993450bf640d5b",
"assets/assets/images/ic_create_yellow.png": "ad55f570847f93ddbd976157b2656c37",
"assets/assets/images/ic_create_white.png": "66a51487fa535be8e70e0577dcad3660",
"assets/assets/images/ic_tick_circle.png": "aaec4e3d356eaabe40c9aae6fab37fab",
"assets/assets/images/ic_attachment.png": "299ef8d6a78771b32380377f57307c34",
"assets/assets/images/ic_gallery.png": "d6f62f1fb0262c98212c3306ea921605",
"assets/assets/images/ic_edit_pencil.png": "8a2a725f6ff8f05b5c87c9ef720b1383",
"assets/assets/fonts/dp_clear_medium.ttf": "8474cf260748a8894383fab045b17e92",
"assets/assets/fonts/dp_clear_regular.ttf": "2c37ea091f38e60804add093de642837",
"canvaskit/skwasm.js": "1df4d741f441fa1a4d10530ced463ef8",
"canvaskit/skwasm.wasm": "6711032e17bf49924b2b001cef0d3ea3",
"canvaskit/chromium/canvaskit.js": "8c8392ce4a4364cbb240aa09b5652e05",
"canvaskit/chromium/canvaskit.wasm": "fc18c3010856029414b70cae1afc5cd9",
"canvaskit/canvaskit.js": "76f7d822f42397160c5dfc69cbc9b2de",
"canvaskit/canvaskit.wasm": "f48eaf57cada79163ec6dec7929486ea",
"canvaskit/skwasm.worker.js": "19659053a277272607529ef87acf9d8a"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
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
