importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyAXxg4D1aX6vQg1s19r5Pb_uO9OuIAvNNk",
  authDomain: "locate-your-dentist.firebaseapp.com",
  projectId: "locate-your-dentist",
  storageBucket: "locate-your-dentist.firebasestorage.app",
  messagingSenderId: "540179202432",
  appId: "1:540179202432:web:aa86d1a145377eae3b8165",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log("onBackgroundMessage", payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png",
  };

  return self.registration.showNotification(
    notificationTitle,
    notificationOptions
  );
});
