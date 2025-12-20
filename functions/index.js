/**
 * Rafahiya Tourism - Firebase Cloud Functions (v2)
 * Purpose: Send OneSignal push notifications when a new SuperAdmin announcement is created
 */


//const { onDocumentCreated } = require("firebase-functions/v2/firestore");
//const { initializeApp } = require("firebase-admin/app");
//const { defineSecret } = require("firebase-functions/params");
//const { onSchedule } = require("firebase-functions/v2/scheduler");
//const { logger } = require("firebase-functions");
//const moment = require("moment-timezone");
//const admin = require("firebase-admin");
//const axios = require("axios");



//const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const {
  onDocumentCreated,
  onDocumentUpdated,
  onDocumentDeleted,
  onDocumentWritten
} = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp } = require("firebase-admin/app");
const { defineSecret } = require("firebase-functions/params");
const { logger } = require("firebase-functions");
const moment = require("moment-timezone");
const admin = require("firebase-admin");
const axios = require("axios");




// Initialize Firebase Admin SDK
initializeApp();

// Define OneSignal secrets
const ONESIGNAL_APP_ID = defineSecret("ONESIGNAL_APP_ID");
const ONESIGNAL_API_KEY = defineSecret("ONESIGNAL_API_KEY");



// Helper: store notification in Firestore
const storeNotification = async ({
  title,
  message,
  type,
  senderRole,
  receiverRole,
  receiverId,
  extraData = {}
}) => {
  const firestore = require("firebase-admin").firestore();
  try {
    await firestore.collection("notifications").add({
      title,
      message,
      type,
      senderRole,
      receiverRole,
      receiverId,
      extraData,
      timestamp: new Date(),
    });
    console.log("✅ Notification stored successfully");
  } catch (error) {
    console.error("❌ Error storing notification:", error);
  }
};

// small helper to get secret values
function getSecrets() {
  const app_id = ONESIGNAL_APP_ID.value();
  const api_key = ONESIGNAL_API_KEY.value();
  return { app_id, api_key };
}


// sendSuperAdminAnnouncement
exports.sendSuperAdminAnnouncement = onDocumentCreated({
  document: "super_admin_general_announcements/{docId}",
  secrets: [ONESIGNAL_APP_ID, ONESIGNAL_API_KEY],
}, async (event) => {
  const announcement = event.data.data();
  const { app_id, api_key } = getSecrets();
  if (!app_id || !api_key) {
    logger.error("OneSignal credentials missing.");
    return;
  }
  const title = announcement.title || "New Announcement";
  const message = announcement.message || "A new announcement has been posted.";

  const payload = {
    app_id,
    included_segments: ["All"],
    headings: { en: title },
    contents: { en: message },
    data: {
      type: "super_admin_general_announcements",
      announcementId: event.params.docId,
    },
  };

  try {
    const response = await axios.post("https://onesignal.com/api/v1/notifications", payload, {
      headers: { Authorization: `Basic ${api_key}`, "Content-Type": "application/json" },
    });
    logger.log("OneSignal response:", response.data);

    // store notification in Firestore (broadcast to users and subadmins and super_admins)
    await storeNotification({
      title,
      message,
      type: "super_admin_general_announcements",
      senderRole: "super_admin",
      receiverRole: null, // broadcast
      receiverId: null,
      extraData: { announcementId: event.params.docId }
    });
  } catch (err) {
    logger.error("Error sending OneSignal:", err.response?.data || err.message || err);
  }
});


// sendUpdateTimingRequestNotification - sends to subAdmin (user requested update)
exports.sendUpdateTimingRequestNotification = onDocumentCreated({
  document: "request_update_timings/{docId}",
  secrets: [ONESIGNAL_APP_ID, ONESIGNAL_API_KEY],
}, async (event) => {
  const requestData = event.data.data();
  const { app_id, api_key } = getSecrets();
  if (!app_id || !api_key) { logger.error("OneSignal credentials missing."); return; }

  const userId = requestData.userId; // this is subAdmin id in your function
  const title = requestData.title || "Update Request";
  const message = requestData.message || `${requestData.imamName || "Someone"} requested an update for Namaz timings.`;

  if (!userId) {
    logger.error("No userId found in document, cannot send notification.");
    return;
  }

  try {
    const adminSnapshot = await admin.firestore().collection("subAdmin").doc(userId).get();
    if (!adminSnapshot.exists) { logger.error("SubAdmin not found:", userId); return; }
    const adminData = adminSnapshot.data();
    const playerId = adminData?.playerId;
    if (!playerId) { logger.error("No playerId found for SubAdmin:", userId); return; }

    const payload = {
      app_id,
      include_player_ids: [playerId],
      headings: { en: title },
      contents: { en: message },
      data: { type: "request_update_timings", requestId: event.params.docId },
    };

    const response = await axios.post("https://onesignal.com/api/v1/notifications", payload, {
      headers: { Authorization: `Basic ${api_key}`, "Content-Type": "application/json" },
    });

    logger.log("Notification sent to SubAdmin:", playerId, response.data);

    // store notification (targeted)
    await storeNotification({
      title,
      message,
      type: "request_update_timings",
      senderRole: "user",
      receiverRole: "subadmin",
      receiverId: userId,
      extraData: { requestId: event.params.docId }
    });
  } catch (err) {
    logger.error("Error sending SubAdmin notification:", err.response?.data || err.message || err);
  }
});





// sendTimingUpdateNotification (created)
exports.sendTimingUpdateNotification = onDocumentCreated({
  document: "mosques/{mosqueId}/{timingType}/{timingId}",
  secrets: [ONESIGNAL_APP_ID, ONESIGNAL_API_KEY],
}, async (event) => {
  const timingData = event.data.data();
  const { app_id, api_key } = getSecrets();
  if (!timingData || !app_id || !api_key) { logger.error("Missing data/credentials"); return; }

  const imamId = timingData.imamId;
  const namazName = timingData.namazName || "Namaz";
  if (!imamId) { logger.error("No imamId found"); return; }

  try {
    const firestore = admin.firestore();
    const userSettingsSnap = await firestore.collection("user_mosque_settings").get();
    const matchedUserIds = [];
    userSettingsSnap.forEach((doc) => {
      const data = doc.data();
      let mosqueSelections = data.mosqueSelections || [];
      if (!Array.isArray(mosqueSelections) && typeof mosqueSelections === "object") {
        mosqueSelections = Object.values(mosqueSelections);
      }
      if (Array.isArray(mosqueSelections)) {
        const match = mosqueSelections.some((sel) => sel.uid === imamId);
        if (match) matchedUserIds.push(doc.id);
      }
    });

    if (matchedUserIds.length === 0) {
      logger.log("No users found linked with imamId:", imamId);
      return;
    }

    const playerIds = [];
    for (const userId of matchedUserIds) {
      const userDoc = await firestore.collection("users").doc(userId).get();
      if (userDoc.exists && userDoc.data().playerId) playerIds.push(userDoc.data().playerId);
    }

    if (playerIds.length === 0) {
      logger.log("No playerIds found for users of imamId:", imamId);
      return;
    }

    const payload = {
      app_id,
      include_player_ids: playerIds,
      headings: { en: `Update in ${namazName} Timing` },
      contents: { en: `Your selected mosque has updated ${namazName} timing.` },
      data: {
        type: "timing_update",
        imamId,
        namazName,
        mosqueId: event.params.mosqueId,
        timingType: event.params.timingType,
        timingId: event.params.timingId
      },
    };

    const response = await axios.post("https://onesignal.com/api/v1/notifications", payload, {
      headers: { Authorization: `Basic ${api_key}`, "Content-Type": "application/json" },
    });

    logger.log(`Notification sent to ${playerIds.length} users`, response.data);

    // store notification (broadcast to matched users)
    await storeNotification({
      title: `Update in ${namazName} Timing`,
      message: `Your selected mosque has updated ${namazName} timing.`,
      type: "timing_update",
      senderRole: "subadmin",
      receiverRole: "user",
      receiverId: matchedUserIds,
      extraData: {
        imamId, namazName, mosqueId: event.params.mosqueId, timingType: event.params.timingType, timingId: event.params.timingId
      }
    });

  } catch (err) {
    logger.error("Error sending timing update:", err.response?.data || err.message || err);
  }
});


// sendTimingUpdateNotificationUpdated (on update)
exports.sendTimingUpdateNotificationUpdated = onDocumentUpdated({
  document: "mosques/{mosqueId}/{timingType}/{timingId}",
  secrets: [ONESIGNAL_APP_ID, ONESIGNAL_API_KEY],
}, async (event) => {
  const afterData = event.data.after.data();
  const { app_id, api_key } = getSecrets();
  if (!afterData || !app_id || !api_key) { logger.error("Missing data/credentials"); return; }

  const imamId = afterData.imamId;
  const namazName = afterData.namazName || "Namaz";
  if (!imamId) { logger.error("No imamId found"); return; }

  try {
    const firestore = admin.firestore();
    const userSettingsSnap = await firestore.collection("user_mosque_settings").get();
    const matchedUserIds = [];
    userSettingsSnap.forEach((doc) => {
      const data = doc.data();
      let mosqueSelections = data.mosqueSelections || [];
      if (!Array.isArray(mosqueSelections) && typeof mosqueSelections === "object") {
        mosqueSelections = Object.values(mosqueSelections);
      }
      if (Array.isArray(mosqueSelections)) {
        const match = mosqueSelections.some((sel) => sel.uid === imamId);
        if (match) matchedUserIds.push(doc.id);
      }
    });

    if (matchedUserIds.length === 0) {
      logger.log("No users found linked with imamId:", imamId);
      return;
    }

    const playerIds = [];
    for (const userId of matchedUserIds) {
      const userDoc = await firestore.collection("users").doc(userId).get();
      if (userDoc.exists && userDoc.data().playerId) playerIds.push(userDoc.data().playerId);
    }

    if (playerIds.length === 0) {
      logger.log("No playerIds found for users of imamId:", imamId);
      return;
    }

    const payload = {
      app_id,
      include_player_ids: playerIds,
      headings: { en: `Update in ${namazName} Timing` },
      contents: { en: `Your selected mosque has updated ${namazName} timing.` },
      data: {
        type: "timing_update",
        imamId,
        namazName,
        mosqueId: event.params.mosqueId,
        timingType: event.params.timingType,
        timingId: event.params.timingId,
      }
    };

    const response = await axios.post("https://api.onesignal.com/api/v1/notifications", payload, {
      headers: { Authorization: `Basic ${api_key}`, "Content-Type": "application/json" },
    });

    logger.log(`Notification sent to ${playerIds.length} users (updated)`, response.data);

    // store notification
    await storeNotification({
      title: `Update in ${namazName} Timing`,
      message: `Your selected mosque has updated ${namazName} timing.`,
      type: "timing_update",
      senderRole: "subadmin",
      receiverRole: "user",
      receiverId: matchedUserIds,
      extraData: {
        imamId, namazName, mosqueId: event.params.mosqueId, timingType: event.params.timingType, timingId: event.params.timingId
      }
    });

  } catch (err) {
    logger.error("Error sending timing update (updated):", err.response?.data || err.message || err);
  }
});



exports.sendBayanNotification = onDocumentCreated(
  {
    document: "mosques/{uid}/bayan/{bayanId}",
    secrets: [ONESIGNAL_APP_ID, ONESIGNAL_API_KEY],
  },
  async (event) => {
    const bayanData = event.data.data();
    const app_id = ONESIGNAL_APP_ID.value();
    const api_key = ONESIGNAL_API_KEY.value();

    if (!bayanData) {
      console.error("❌ No Sub-Admin General Announcement data found.");
      return;
    }

    if (!app_id || !api_key) {
      console.error("❌ OneSignal credentials missing.");
      return;
    }

    const imamId = event.params.uid;
    const title = bayanData.title || "New Sub-Admin General Announcement";
    const firestore = require("firebase-admin").firestore();

    try {
      // Step 1: Find users linked to this imam
      const userSettingsSnap = await firestore.collection("user_mosque_settings").get();
      const matchedUserIds = [];

      userSettingsSnap.forEach((doc) => {
        const data = doc.data();
        let mosqueSelections = data.mosqueSelections || [];

        if (!Array.isArray(mosqueSelections) && typeof mosqueSelections === "object") {
          mosqueSelections = Object.values(mosqueSelections);
        }

        if (Array.isArray(mosqueSelections)) {
          const match = mosqueSelections.some((sel) => sel.uid === imamId);
          if (match) matchedUserIds.push(doc.id);
        }
      });

      if (matchedUserIds.length === 0) {
        console.log("ℹ️ No users found linked with imamId:", imamId);
        return;
      }

      // Step 2: Collect playerIds
      const playerIds = [];
      const axios = require("axios");

      for (const userId of matchedUserIds) {
        const userDoc = await firestore.collection("users").doc(userId).get();
        if (userDoc.exists && userDoc.data().playerId) {
          playerIds.push(userDoc.data().playerId);
        }
      }

      if (playerIds.length === 0) {
        console.log("ℹ️ No playerIds found.");
        return;
      }

      // Step 3: Send OneSignal Notification
      const payload = {
        app_id: app_id,
        include_player_ids: playerIds,
        headings: { en: "New Sub-Admin General Announcement Added" },
        contents: { en: `A new bayan has been posted: ${title}` },
        data: {
          type: "sub_admin_general_announcement_update",
          uid: imamId,
          bayanId: event.params.bayanId,
        },
      };

      const headers = {
        "Content-Type": "application/json",
        Authorization: `Basic ${api_key}`,
      };

      const response = await axios.post(
        "https://onesignal.com/api/v1/notifications",
        payload,
        { headers }
      );

      console.log(`✅ Bayan notification sent to ${playerIds.length} users.`);

      // Step 4: Store notification for all matched users
    for (const userId of matchedUserIds) {
        await storeNotification({
          title: "General Announcement 🎉",
          message: `A new bayan has been posted: ${title}`,
          type: "general_announcement",
          senderRole: "subadmin",
          receiverRole: "user",
          receiverId: userId,
          extraData: {
            bayanId: event.params.bayanId,
            mosqueId: imamId,
          },
        });
      }
    } catch (error) {
      console.error("❌ Error sending sub_admin_general_announcement notification:", error.message);
    }
  }
);

exports.sendHadiyaCreatedNotification = onDocumentCreated(
  {
    document: "mosques/{mosqueId}/hadiyaDetails/{hadiyaId}",
    secrets: [ONESIGNAL_APP_ID, ONESIGNAL_API_KEY],
  },
  async (event) => {
    const hadiyaData = event.data.data();
    const app_id = ONESIGNAL_APP_ID.value();
    const api_key = ONESIGNAL_API_KEY.value();

    if (!hadiyaData) return console.error("❌ No hadiya data found.");
    if (!app_id || !api_key) return console.error("❌ OneSignal credentials missing.");

    const subAdminId = hadiyaData.subAdminId;
    const hadiyaType = hadiyaData.type || "Hadiya";
    const accountHolderName = hadiyaData.accountHolderName || "User";

    if (!subAdminId) return console.error("❌ No subAdminId found.");

    const firestore = require("firebase-admin").firestore();

    try {
      // Step 1: Find users linked to subAdmin
      const userSettingsSnap = await firestore.collection("user_mosque_settings").get();
      const matchedUserIds = [];

      userSettingsSnap.forEach((doc) => {
        const data = doc.data();
        let selections = data.mosqueSelections || [];

        if (!Array.isArray(selections) && typeof selections === "object") {
          selections = Object.values(selections);
        }

        const found = selections.some((sel) => sel.uid === subAdminId);
        if (found) matchedUserIds.push(doc.id);
      });

      // Step 2: Collect Player IDs
      const playerIds = [];
      const axios = require("axios");

      for (const userId of matchedUserIds) {
        const userDoc = await firestore.collection("users").doc(userId).get();
        if (userDoc.exists && userDoc.data().playerId) {
          playerIds.push(userDoc.data().playerId);
        }
      }

      // Step 3: Add super admin playerIds
      const superAdminSnap = await firestore.collection("super_admins").get();
      superAdminSnap.forEach((doc) => {
        if (doc.data().playerId) playerIds.push(doc.data().playerId);
      });

      if (playerIds.length === 0) {
        console.log("ℹ️ No playerIds found.");
        return;
      }

      // Step 4: Send OneSignal Notification
      const payload = {
        app_id: app_id,
        include_player_ids: playerIds,
        headings: { en: "New Hadiya Added" },
        contents: { en: `${accountHolderName} has created ${hadiyaType} hadiya.` },
        data: {
          type: "hadiya_added",
          subAdminId: subAdminId,
          hadiyaId: event.params.hadiyaId,
          mosqueId: event.params.mosqueId,
        },
      };

      const headers = {
        "Content-Type": "application/json",
        Authorization: `Basic ${api_key}`,
      };

      const response = await axios.post(
        "https://onesignal.com/api/v1/notifications",
        payload,
        { headers }
      );

      console.log(`✅ Hadiya notification sent to ${playerIds.length} users.`);

      // Step 5: Store Notification in Firestore
      for (const userId of matchedUserIds) {
        await storeNotification({
          title: "New Hadiya Request 🎉",
          message: `${accountHolderName} has created ${hadiyaType} hadiya.`,
          type: "Hadiya Created",
          senderRole: "subadmin",
          receiverRole: "user",
          receiverId: userId,
          extraData: {
            hadiyaId: event.params.hadiyaId,
            mosqueId: event.params.mosqueId,
          },
        });
      }

      // Also store notification for super admins
      superAdminSnap.forEach(async (doc) => {
        await storeNotification({
          title: "New Hadiya Request 🎉",
          message: `${accountHolderName} has created ${hadiyaType} hadiya.`,
          type: "Hadiya Created",
          senderRole: "subadmin",
          receiverRole: "super_admin",
          receiverId: doc.id,
          extraData: {
            hadiyaId: event.params.hadiyaId,
            mosqueId: event.params.mosqueId,
          },
        });
      });

    } catch (error) {
      console.error(
        "❌ Error sending Hadiya Created notification:",
        error.response?.data || error.message
      );
    }
  }
);




// sendCommunityServiceNotification
exports.sendCommunityServiceNotification = onDocumentCreated({
  document: "community_services/{docId}",
  region: "us-central1",
  secrets: [ONESIGNAL_APP_ID, ONESIGNAL_API_KEY]
}, async (event) => {
  const data = event.data.data();
  const { app_id, api_key } = getSecrets();
  if (!app_id || !api_key) { logger.error("Missing OneSignal credentials"); return; }

  const title = data.title || "New Community Service";
  const message = data.description || "A new community service has been posted.";

  try {
    const firestore = admin.firestore();
    const usersSnap = await firestore.collection("users").get();
    if (usersSnap.empty) { logger.log("No users found"); return; }

    const playerIds = [];
    const userIds = []; // <-- collect user IDs here

    usersSnap.forEach(doc => {
      const u = doc.data();
      userIds.push(doc.id);             // <-- store userId
      if (u.playerId) playerIds.push(u.playerId);
    });

    if (playerIds.length === 0) { logger.log("No playerIds found"); return; }

    const payload = {
      app_id,
      include_player_ids: playerIds,
      headings: { en: title },
      contents: { en: message },
      data: { type: "community_service", communityServiceId: event.params.docId }
    };

    const response = await axios.post(
      "https://onesignal.com/api/v1/notifications",
      payload,
      { headers: { Authorization: `Basic ${api_key}`, "Content-Type": "application/json" } }
    );

    logger.log("Community service notification sent:", response.data);

    await storeNotification({
      title,
      message,
      type: "community_service",
      senderRole: "super_admin",
      receiverRole: "user",
      receiverId: userIds, // <-- Added receiverId here
      extraData: { communityServiceId: event.params.docId }
    });

  } catch (err) {
    logger.error("Error sending community service:", err.response?.data || err.message || err);
  }
});


// sendPackageNotification
exports.sendPackageNotification = onDocumentCreated({
  document: "packages/{packageId}",
  secrets: [ONESIGNAL_APP_ID, ONESIGNAL_API_KEY]
}, async (event) => {
  const packageData = event.data.data();
  const { app_id, api_key } = getSecrets();
  if (!app_id || !api_key) { logger.error("Missing OneSignal credentials"); return; }

  const title = packageData.title || "New Package Available!";
  const price = packageData.price ? `Price: ${packageData.price}` : "";
  const note = packageData.note || "";
  const imageUrl = packageData.imageUrl || "";
  const startDate = packageData.startDate ? new Date(packageData.startDate._seconds * 1000).toDateString() : "";
  const endDate = packageData.endDate ? new Date(packageData.endDate._seconds * 1000).toDateString() : "";
  const message = `📦 ${title}\n${price}\n${note}\nDuration: ${startDate} - ${endDate}`;

  try {
    const firestore = admin.firestore();
    const usersSnap = await firestore.collection("users").get();
    if (usersSnap.empty) { logger.log("No users found"); return; }

    const playerIds = [];
    const userIds = []; // <-- collect receiver IDs

    usersSnap.forEach(doc => {
      const data = doc.data();
      userIds.push(doc.id);      // <-- add userId
      if (data.playerId) playerIds.push(data.playerId);
    });

    if (playerIds.length === 0) { logger.log("No playerIds found"); return; }

    const payload = {
      app_id,
      include_player_ids: playerIds,
      headings: { en: "🕋 New Umrah Package Added!" },
      contents: { en: message },
      big_picture: imageUrl,
      data: { type: "package_announcement", packageId: event.params.packageId }
    };

    const response = await axios.post(
      "https://onesignal.com/api/v1/notifications",
      payload,
      { headers: { Authorization: `Basic ${api_key}`, "Content-Type": "application/json" }}
    );

    logger.log("Package notification sent:", response.data);

    // Store notification
    await storeNotification({
      title: "New Umrah Package Added!",
      message,
      type: "package_announcement",
      senderRole: "super_admin",
      receiverRole: "user",
      receiverId: userIds, // <-- added receiverId here
      extraData: { packageId: event.params.packageId, imageUrl }
    });

  } catch (err) {
    logger.error("Error sending package notification:", err.response?.data || err.message || err);
  }
});



// sendTutorialVideoNotification
exports.sendTutorialVideoNotification = onDocumentCreated({
  document: "tutorial_videos/{videoId}",
  secrets: [ONESIGNAL_APP_ID, ONESIGNAL_API_KEY]
}, async (event) => {
  const videoData = event.data.data();
  const { app_id, api_key } = getSecrets();
  if (!app_id || !api_key) { logger.error("Missing OneSignal credentials"); return; }
  if (!videoData) { logger.error("No video data found."); return; }

  const title = videoData.title || "New Tutorial Video Available!";
  const description = videoData.description || "A new tutorial video has been added.";
  const videoUrl = videoData.videoUrl || "";

  try {
    const firestore = admin.firestore();
    const usersSnap = await firestore.collection("users").get();
    if (usersSnap.empty) { logger.log("No users found"); return; }

    const headers = { Authorization: `Basic ${api_key}`, "Content-Type": "application/json" };

    const receiverIds = []; // <-- collect all user IDs here

    for (const userDoc of usersSnap.docs) {
      const userData = userDoc.data();
      const playerId = userData.playerId;
      receiverIds.push(userDoc.id); // <-- add userId to receiver list

      if (!playerId) continue;

      const payload = {
        app_id,
        include_player_ids: [playerId],
        headings: { en: title },
        contents: { en: description },
        data: { type: "tutorial_video", videoId: event.params.videoId, videoUrl }
      };

      try {
        await axios.post("https://onesignal.com/api/v1/notifications", payload, { headers });
      } catch (err) {
        logger.error(`Error sending tutorial notification to ${userDoc.id}:`, err.response?.data || err.message || err);
      }
    }

    await storeNotification({
      title,
      message: description,
      type: "tutorial_video",
      senderRole: "super_admin",
      receiverRole: "user",
      receiverId: receiverIds,   // <-- added receiverId here
      extraData: { videoId: event.params.videoId, videoUrl }
    });

  } catch (err) {
    logger.error("Error in tutorial video notification:", err.response?.data || err.message || err);
  }
});


// notifyUserWalletUpdate
exports.notifyUserWalletUpdate = onDocumentCreated({
  document: "user_wallet/{walletId}",
  secrets: [ONESIGNAL_APP_ID, ONESIGNAL_API_KEY],
  region: "us-central1",
}, async (event) => {
  const newWallet = event.data;
  if (!newWallet) { logger.log("No data found"); return; }
  const newWalletData = newWallet.data();
  const userId = newWalletData.userId;
  if (!userId) { logger.log("No userId found"); return; }

  try {
    const userDoc = await admin.firestore().collection("users").doc(userId).get();
    if (!userDoc.exists) { logger.log("User not found:", userId); return; }
    const userData = userDoc.data();
    const playerId = userData.playerId;
    if (!playerId) { logger.log("No OneSignal playerId for user:", userId); return; }

    const { app_id, api_key } = getSecrets();
    const payload = {
      app_id,
      include_player_ids: [playerId],
      headings: { en: "Wallet Updated!" },
      contents: { en: `Hello ${userData.name || "User"}, your wallet has been updated.` },
      data: { type: "user_wallet_update", walletId: event.params.walletId },
    };

    const response = await axios.post("https://onesignal.com/api/v1/notifications", payload, { headers: { Authorization: `Basic ${api_key}`, "Content-Type": "application/json" }});
    logger.log("Wallet update notification sent", response.data);

    await storeNotification({
      title: "Wallet Updated!",
      message: `Hello ${userData.name || "User"}, your wallet has been updated.`,
      type: "user_wallet_update",
      senderRole: "system",
      receiverRole: "user",
      receiverId: userId,
      extraData: { walletId: event.params.walletId }
    });

  } catch (err) {
    logger.error("Error notifyUserWalletUpdate:", err.response?.data || err.message || err);
  }
});


// notifySubAdminOnHadiyaApproval (onDocumentUpdated)
exports.notifySubAdminOnHadiyaApproval = onDocumentUpdated({
  document: "mosques/{mosqueId}/hadiyaDetails/{hadiyaId}",
  region: "us-central1",
  secrets: [ONESIGNAL_APP_ID, ONESIGNAL_API_KEY]
}, async (event) => {
  try {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (!before || !after) {
      logger.log("No before / after snapshot");
      return;
    }

    logger.log("Approval trigger check:", before.allowed, "->", after.allowed);

    // Only trigger when allowed: false → true
    if (before.allowed === false && after.allowed === true) {
      const subAdminId = after.subAdminId;
      const hadiyaType = after.type || "Hadiya";
      const accountHolderName = after.accountHolderName || "User";

      const firestore = admin.firestore();
      const subAdminDoc = await firestore.collection("subAdmin").doc(subAdminId).get();

      if (!subAdminDoc.exists) {
        logger.error("SubAdmin not found:", subAdminId);
        return;
      }

      const playerId = subAdminDoc.data()?.playerId;

      if (!playerId) {
        logger.error("No playerId for subAdmin:", subAdminId);
        return;
      }

      const payload = {
        app_id: ONESIGNAL_APP_ID.value(),
        include_player_ids: [playerId],
        headings: { en: "Hadiya Approved 🎉" },
        contents: {
          en: `${hadiyaType} for ${accountHolderName} has been approved by Super Admin.`
        },
        data: {
          type: "hadiya_approval",
          hadiyaId: event.params.hadiyaId,
          mosqueId: event.params.mosqueId,
          subAdminId
        }
      };

      const response = await axios.post(
        "https://api.onesignal.com/notifications",
        payload,
        {
          headers: {
            Authorization: `Basic ${ONESIGNAL_API_KEY.value()}`,
            "Content-Type": "application/json"
          }
        }
      );

      logger.log("Approval notification sent:", response.data);

      await storeNotification({
        title: "Hadiya Approved 🎉",
        message: `${hadiyaType} for ${accountHolderName} has been approved by Super Admin.`,
        type: "hadiya_approval",
        senderRole: "super_admin",
        receiverRole: "subadmin",
        receiverId: subAdminId,
        extraData: {
          hadiyaId: event.params.hadiyaId,
          mosqueId: event.params.mosqueId
        }
      });

    } else {
      logger.log("Approval condition not met, skipping.");
    }
  } catch (err) {
    logger.error("Approval notification error:", err.response?.data || err.message);
  }
});



exports.notifySubAdminOnHadiyaRejection = onDocumentWritten(
  {
    document: "mosques/{mosqueId}/hadiyaDetails/{hadiyaId}",
    region: "us-central1",
    secrets: [ONESIGNAL_APP_ID, ONESIGNAL_API_KEY],
  },
  async (event) => {
    try {
      const beforeSnap = event.data.before;
      const afterSnap = event.data.after;

      logger.log("Rejection Trigger - hadiya:", event.params.hadiyaId);
      logger.log("Before exists:", beforeSnap.exists, "After exists:", afterSnap.exists);

      // Only trigger when document is deleted (reject)
      if (beforeSnap.exists && !afterSnap.exists) {
        const deletedData = beforeSnap.data();
        const subAdminId = deletedData?.subAdminId;
        const hadiyaType = deletedData?.type || "Hadiya";
        const accountHolderName = deletedData?.accountHolderName || "User";

        if (!subAdminId) {
          logger.error("Missing subAdminId in deleted data");
          return;
        }

        const firestore = admin.firestore();
        const subAdminDoc = await firestore.collection("subAdmin").doc(subAdminId).get();

        if (!subAdminDoc.exists) {
          logger.error("SubAdmin not found:", subAdminId);
          return;
        }

        const playerId = subAdminDoc.data()?.playerId;

        if (!playerId) {
          logger.error("Missing playerId for subAdmin:", subAdminId);
          return;
        }

        const payload = {
          app_id: ONESIGNAL_APP_ID.value(),
          include_player_ids: [playerId],
          headings: { en: "Hadiya Rejected ❌" },
          contents: {
            en: `${hadiyaType} for ${accountHolderName} has been rejected by Super Admin.`
          },
          data: {
            type: "hadiya_rejection",
            hadiyaId: event.params.hadiyaId,
            mosqueId: event.params.mosqueId,
            subAdminId
          }
        };

        const response = await axios.post(
          "https://api.onesignal.com/notifications",
          payload,
          {
            headers: {
              Authorization: `Basic ${ONESIGNAL_API_KEY.value()}`,
              "Content-Type": "application/json"
            },
          }
        );

        logger.log("Rejection notification sent:", response.data);

        await storeNotification({
          title: "Hadiya Rejected ❌",
          message: `${hadiyaType} for ${accountHolderName} has been rejected by Super Admin.`,
          type: "hadiya_rejection",
          senderRole: "super_admin",
          receiverRole: "subadmin",
          receiverId: subAdminId,
          extraData: {
            hadiyaId: event.params.hadiyaId,
            mosqueId: event.params.mosqueId
          }
        });

      }
    } catch (err) {
      logger.error("Rejection notification error:", err.response?.data || err.message);
    }
  });




// notifySuperAdminOnNewSubAdmin
exports.notifySuperAdminOnNewSubAdmin = onDocumentCreated({
  document: "subAdmin/{subAdminId}",
  region: "us-central1",
  secrets: [ONESIGNAL_APP_ID, ONESIGNAL_API_KEY]
}, async (event) => {
  try {
    const newSubAdminData = event.data.data();
    if (!newSubAdminData) { logger.log("No subAdmin data"); return; }

    const imamName = newSubAdminData.imamName || "New SubAdmin";
    const masjidName = newSubAdminData.masjidName || "Unknown Mosque";
    const city = newSubAdminData.city || "Unknown City";

    const firestore = admin.firestore();
    const superAdminsSnapshot = await firestore.collection("super_admins").get();
    if (superAdminsSnapshot.empty) { logger.log("No super admins"); return; }

    const superAdminPlayerIds = [];
    const superAdminIds = []; // <-- collect receiver IDs

    superAdminsSnapshot.forEach((doc) => {
      const d = doc.data();
      superAdminIds.push(doc.id); // <-- add user ID
      if (d.playerId) superAdminPlayerIds.push(d.playerId);
    });

    if (superAdminPlayerIds.length === 0) { logger.log("No super admin playerIds"); return; }

    const payload = {
      app_id: ONESIGNAL_APP_ID.value(),
      include_player_ids: superAdminPlayerIds,
      headings: { en: "New SubAdmin Registered 🎉" },
      contents: {
        en: `${imamName} from ${masjidName} (${city}) has registered as a new subAdmin.`
      },
      data: {
        type: "new_subadmin_registered",
        subAdminId: event.params.subAdminId,
        imamName,
        masjidName,
        city
      }
    };

    const response = await axios.post(
      "https://onesignal.com/api/v1/notifications",
      payload,
      {
        headers: {
          Authorization: `Basic ${ONESIGNAL_API_KEY.value()}`,
          "Content-Type": "application/json"
        },
      }
    );

    logger.log("Super admins notified:", response.data);

    await firestore.collection("notification_logs").add({
      type: "new_subadmin_registered",
      subAdminId: event.params.subAdminId,
      subAdminName: imamName,
      masjidName,
      notifiedSuperAdmins: superAdminPlayerIds.length,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      onesignalResponse: response.data
    });

    await storeNotification({
      title: "New SubAdmin Registered 🎉",
      message: `${imamName} from ${masjidName} (${city}) has registered as a new subAdmin.`,
      type: "new_subadmin_registered",
      senderRole: "system",
      receiverRole: "super_admin",
      receiverId: superAdminIds,    // <-- added receiverId here
      extraData: { subAdminId: event.params.subAdminId, imamName, masjidName, city }
    });

  } catch (err) {
    logger.error("Error notifySuperAdminOnNewSubAdmin:", err.response?.data || err.message || err);
  }
});







// Make sure these imports exist at the top of index.js:
// const { onSchedule } = require("firebase-functions/v2/scheduler");
// const { logger } = require("firebase-functions");
// const { defineSecret } = require("firebase-functions/params"); // already present earlier
// const axios = require("axios");
// const moment = require("moment-timezone");
// const admin = require("firebase-admin");
// admin.initializeApp();
// Also ensure ONESIGNAL_APP_ID and ONESIGNAL_API_KEY are defined with defineSecret(...) earlier.

exports.scheduleNamazNotifications = onSchedule(
  {
    schedule: "every 5 minutes",
    timeZone: "UTC",
    region: "us-central1",
    secrets: [ONESIGNAL_APP_ID, ONESIGNAL_API_KEY],
    memory: "512MiB",
    timeoutSeconds: 300,
  },
  async (event) => {
    const firestore = admin.firestore();
    const app_id = ONESIGNAL_APP_ID.value();
    const api_key = ONESIGNAL_API_KEY.value();

    if (!app_id || !api_key) {
      logger.error("❌ OneSignal secrets missing for scheduled function.");
      return;
    }

    try {
      // STEP 1️⃣: Get all user mosque settings
      const userSettingsSnap = await firestore.collection("user_mosque_settings").get();
      if (userSettingsSnap.empty) {
        logger.info("⚠️ No user mosque settings found.");
        return;
      }

      // STEP 2️⃣: Loop through all users
      for (const userDoc of userSettingsSnap.docs) {
        const userData = userDoc.data() || {};
        const userId = userData.userId || userDoc.id;

        // normalize mosqueSelections (map or array)
        let mosqueSelections = userData.mosqueSelections || [];
        if (!Array.isArray(mosqueSelections) && typeof mosqueSelections === "object") {
          mosqueSelections = Object.values(mosqueSelections);
        }

        if (!mosqueSelections || mosqueSelections.length === 0) continue;

        // normalize selectedDays
        let selectedDays = userData.selectedDays || {};
        if (Array.isArray(selectedDays)) {
          const mapDays = {};
          for (const d of selectedDays) mapDays[d] = true;
          selectedDays = mapDays;
        }

        const today = moment().tz("Asia/Karachi").format("dddd"); // Adjust per user later if needed
        if (selectedDays[today] === false) continue;

        // normalize notificationSettings
        let notificationSettings = userData.notificationSettings || {};
        if (!Array.isArray(notificationSettings) && typeof notificationSettings === "object") {
          notificationSettings = Object.values(notificationSettings)[0] || {};
        } else if (Array.isArray(notificationSettings) && notificationSettings.length > 0) {
          notificationSettings = notificationSettings[0] || {};
        }

        // get OneSignal playerId from users collection
        const userRef = await firestore.collection("users").doc(userId).get();
        const playerId = userRef.exists ? userRef.data()?.playerId : null;
        if (!playerId) continue;

        // STEP 3️⃣: For each mosque selected by this user
        for (const selection of mosqueSelections) {
          const imamId = selection.uid;
          const mosqueName = selection.name || "Unnamed Mosque";
          if (!imamId) continue;

          // STEP 4️⃣: Search all mosques/*/* subcollections for this imamId
          const mosqueSnap = await firestore.collection("mosques").get();
          if (mosqueSnap.empty) continue;

          for (const mosqueDoc of mosqueSnap.docs) {
            const mosqueId = mosqueDoc.id;
            const mosqueData = mosqueDoc.data() || {};
            const tz = mosqueData.timezone || "Asia/Karachi";
            const now = moment.tz(tz);

            const subcols = await firestore.collection("mosques").doc(mosqueId).listCollections();
            for (const subcolRef of subcols) {
              const subcolName = subcolRef.id;
              const docsSnap = await subcolRef.get();
              if (docsSnap.empty) continue;

              for (const timingDoc of docsSnap.docs) {
                const timing = timingDoc.data() || {};
                if (timing.imamId !== imamId) continue;

                const namazName = timing.namazName || timingDoc.id;
                const azaanTime =
                  timing.azaanTime || timing.azanTime || timing.azan || timing.azan_time;
                const jamatTime =
                  timing.jammatTime ||
                  timing.jamatTime ||
                  timing.jamaatTime ||
                  timing.jamat ||
                  timing.jumajammatTime;
                const khutbaTime = timing.khutbaTime || timing.khutba;

                // Helper: check if current time matches within ±1 min
                const timeMatchesNow = (timeStr) => {
                  if (!timeStr || typeof timeStr !== "string") return false;
                  const target = moment.tz(
                    timeStr.trim(),
                    ["h:mm A", "hh:mm A", "H:mm", "HH:mm"],
                    tz
                  );
                  if (!target.isValid()) return false;
                  const targetToday = moment.tz(
                    `${now.format("YYYY-MM-DD")} ${target.format("HH:mm")}`,
                    "YYYY-MM-DD HH:mm",
                    tz
                  );
                  return Math.abs(now.diff(targetToday, "minutes")) <= 1;
                };

                const azanNow = timeMatchesNow(azaanTime);
                const jamatNow = timeMatchesNow(jamatTime);
                const khutbaNow = timeMatchesNow(khutbaTime);

                if (!azanNow && !jamatNow && !khutbaNow) continue;

                // get user preferences for this namaz
                const prefForNamaz =
                  notificationSettings[namazName] ||
                  notificationSettings[namazName?.toLowerCase()] ||
                  notificationSettings[namazName?.toUpperCase()] ||
                  {};

                let shouldSend = false;
                let audioFlag = false;
                let title = "";
                let body = "";

                if (azanNow && prefForNamaz?.AzanText) {
                  shouldSend = true;
                  audioFlag = !!prefForNamaz?.AzanAudio;
                  title = `Azan: ${namazName} - ${mosqueName}`;
                  body = `${mosqueName} - Azan time for ${namazName}`;
                }

                if (jamatNow && prefForNamaz?.JamatText) {
                  shouldSend = true;
                  audioFlag = audioFlag || !!prefForNamaz?.JamatAudio;
                  title = `Jamat: ${namazName} - ${mosqueName}`;
                  body = `${mosqueName} - Jamat time for ${namazName}`;
                }

                if (khutbaNow && (prefForNamaz?.KhutbaText || prefForNamaz?.JumuahText)) {
                  shouldSend = true;
                  audioFlag = audioFlag || !!prefForNamaz?.KhutbaAudio;
                  title = `Khutba: ${namazName} - ${mosqueName}`;
                  body = `${mosqueName} - Khutba for ${namazName}`;
                }

                if (!shouldSend) continue;

                // Prepare OneSignal payload
                const headers = {
                  "Content-Type": "application/json",
                  Authorization: `Basic ${api_key}`,
                };

                const payload = {
                  app_id: app_id,
                  include_player_ids: [playerId],
                  headings: { en: title },
                  contents: { en: body },
                  data: {
                    type: "timing_notification",
                    mosqueId,
                    subcollection: subcolName,
                    namazName,
                    imamId,
                    audio: audioFlag,
                  },
                };

                try {
                  await axios.post("https://onesignal.com/api/v1/notifications", payload, { headers });
                  logger.info(`✅ Sent to ${userId} (${playerId}) - ${title}`);
                } catch (sendErr) {
                  logger.error(
                    "❌ OneSignal send error:",
                    sendErr.response?.data || sendErr.message
                  );
                }
              }
            }
          }
        }
      }
    } catch (err) {
      logger.error("❌ scheduleNamazNotifications error:", err.message || err);
    }
  }
);



