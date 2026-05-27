importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyD0lcg8qsEarpbjiWJkUODu53EF7lT9ajU",
  authDomain: "locateyourdentist-5c2ca.firebaseapp.com",
  projectId: "locateyourdentist-5c2ca",
  storageBucket: "locateyourdentist-5c2ca.firebasestorage.app",
  messagingSenderId: "831601657278",
  appId: "1:831601657278:web:d39cd0bca707c6b917a5ef",
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
